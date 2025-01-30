import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for rootBundle
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';

import 'package:opencv_dart/opencv.dart' as cv;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:simple_frame_app/simple_frame_app.dart';
import 'package:simple_frame_app/tx/plain_text.dart';
import 'package:simple_frame_app/rx/tap.dart';
import 'package:simple_frame_app/tx/code.dart';
import 'package:simple_frame_app/tx/image_sprite_block.dart';
import 'package:simple_frame_app/tx/sprite.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };

  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MainApp());
}

final _log = Logger("MainApp");

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => MainAppState();
}

/// SimpleFrameAppState mixin helps to manage the lifecycle of the Frame connection outside of this file
class MainAppState extends State<MainApp> with SimpleFrameAppState {
  MainAppState() {
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      debugPrint(
          '${record.level.name}: [${record.loggerName}] ${record.time}: ${record.message}');
    });

    try {
      processImage();
    } catch (e, stacktrace) {
      print("Error during processing: $e");
      print(stacktrace);
    }
  }

  // ---------------------------------------------------------------------------

  List<String> _filterLuaFiles(List<String> assets) {
    return assets.where((asset) => asset.endsWith('.lua')).toList();
  }

  List<String> _filterSpriteAssets(List<String> assets) {
    return assets.where((asset) => asset.contains('/sprites/')).toList();
  }

  Future<void> _uploadSprites(List<String> spriteFiles) async {
    for (var sprite in spriteFiles) {
      String fileName = sprite.split('/').last;
      await frame!.uploadScript(fileName, sprite);
    }
  }

  // String? _lastSentTime;
  bool _isRunning = false;
  StreamSubscription<int>? _tapSubs;
  bool _lockedTaps = false;

  bool _run = true;

  // ---------------------------------------------------------------------------

  Future<void> clearDisplay(int x, int y, int width, int height) async {
    _log.info("Sending clearDisplay with coordinates");
    final command =
        'frame.display.bitmap($x, $y, $width, $height, 1, string.rep("\\x00", $width * $height)) frame.display.show()';
    await frame!.sendString(command, awaitResponse: false, log: true);
    await Future.delayed(const Duration(milliseconds: 100));
    await frame!.sendMessage(
      TxPlainText(msgCode: 0x14, text: ''),
    );
  }

  // ---------------------------------------------------------------------------

  @override
  List<Widget> getFooterButtonsWidget() {
    // work out the states of the footer buttons based on the app state
    List<Widget> pfb = [];

    switch (currentState) {
      case ApplicationState.disconnected:
        pfb.add(TextButton(
            onPressed: scanOrReconnectFrame, child: const Text('Connect')));
        pfb.add(const TextButton(onPressed: null, child: Text('Start')));
        pfb.add(const TextButton(onPressed: null, child: Text('Stop')));
        pfb.add(const TextButton(onPressed: null, child: Text('Disconnect')));
        break;

      case ApplicationState.initializing:
      case ApplicationState.scanning:
      case ApplicationState.connecting:
      case ApplicationState.starting:
      case ApplicationState.canceling:
      case ApplicationState.stopping:
      case ApplicationState.disconnecting:
        pfb.add(const TextButton(onPressed: null, child: Text('Connect')));
        pfb.add(const TextButton(onPressed: null, child: Text('Start')));
        pfb.add(const TextButton(onPressed: null, child: Text('Stop')));
        pfb.add(const TextButton(onPressed: null, child: Text('Disconnect')));
        break;

      case ApplicationState.connected:
        pfb.add(const TextButton(onPressed: null, child: Text('Connect')));
        pfb.add(TextButton(
            onPressed: startApplication, child: const Text('Start')));
        pfb.add(const TextButton(onPressed: null, child: Text('Stop')));
        pfb.add(TextButton(
            onPressed: disconnectFrame, child: const Text('Disconnect')));
        break;

      case ApplicationState.running:
      case ApplicationState.ready:
        pfb.add(const TextButton(onPressed: null, child: Text('Connect')));
        pfb.add(const TextButton(onPressed: null, child: Text('Start')));
        pfb.add(
            TextButton(onPressed: stopApplication, child: const Text('Stop')));
        pfb.add(const TextButton(onPressed: null, child: Text('Disconnect')));
        break;
    }
    return pfb;
  }

  @override
  Future<void> startApplication() async {
    currentState = ApplicationState.starting;
    if (mounted) setState(() {});

    // Ensure no previous loop is running
    frame!.sendBreakSignal();
    await Future.delayed(const Duration(milliseconds: 500));

    // Display a loading screen while preparing resources
    await showLoadingScreen();
    await Future.delayed(const Duration(milliseconds: 100));

    // Load and send Lua scripts
    List<String> luaFiles = _filterLuaFiles(
        (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets());

    if (luaFiles.isNotEmpty) {
      for (var pathFile in luaFiles) {
        String fileName = pathFile.split('/').last;
        await frame!.uploadScript(fileName, pathFile);
      }

      if (luaFiles.length == 1) {
        String fileName = luaFiles[0].split('/').last;
        int lastDotIndex = fileName.lastIndexOf(".lua");
        String bareFileName = fileName.substring(0, lastDotIndex);
        await frame!
            .sendString('require("$bareFileName")', awaitResponse: true);
      } else if (luaFiles.contains('assets/frame_app.min.lua')) {
        await frame!
            .sendString('require("frame_app.min")', awaitResponse: true);
      } else if (luaFiles.contains('assets/frame_app.lua')) {
        await frame!.sendString('require("frame_app")', awaitResponse: true);
      }

      await _uploadSprites(_filterSpriteAssets(
          (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets()));
    } else {
      await frame!.clearDisplay();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    currentState = ApplicationState.running;
    if (mounted) setState(() {});
    run(); // Automatically start the main loop
  }

  @override
  Future<void> stopApplication() async {
    currentState = ApplicationState.stopping;
    if (mounted) setState(() {});

    await frame!.clearDisplay();

    // send a break to stop the Lua app loop on Frame
    await frame!.sendBreakSignal();
    await Future.delayed(const Duration(milliseconds: 500));

    // only if there are lua files uploaded to Frame (e.g. frame_app.lua companion app, other helper functions, minified versions)
    List<String> luaFiles = _filterLuaFiles(
        (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets());

    if (luaFiles.isNotEmpty) {
      // clean up by deregistering any handler
      await frame!.sendString('frame.bluetooth.receive_callback(nil);print(0)',
          awaitResponse: true);

      for (var file in luaFiles) {
        // delete any prior scripts
        await frame!.sendString(
            'frame.file.remove("${file.split('/').last}");print(0)',
            awaitResponse: true);
      }
    }

    currentState = ApplicationState.connected;
    if (mounted) setState(() {});
  }

  Future<void> onTap(int taps) async {
    try {
      _log.info('current state of locking: $_lockedTaps and $_run');
      if (!_lockedTaps){
        if (taps == 1) {
          _lockedTaps = true;
          final currentTime = DateFormat('hh:mm a').format(DateTime.now());
          await frame!.sendMessage(
            TxPlainText(msgCode: 0x14, text: '$currentTime~$batteryLevel%'),
          );
          _log.info('Displayed time and battery: $currentTime, $batteryLevel%');

          await Future.delayed(const Duration(seconds: 3));
          await frame!.sendMessage(TxPlainText(msgCode: 0x14, text: '  '));
        } else if (taps == 2) {
          _lockedTaps = true;
          // await frame!.sendMessage(
          //   TxPlainText(msgCode: 0x14, text: "Double Tap - Navigation"),
          // );

          // Get and convert image
          final cv.Mat display = await processImage();

          final gray = await cv.cvtColorAsync(display, cv.COLOR_RGB2GRAY);

          // Convert the Mat to a PNG-encoded Uint8List
          final (bool success, Uint8List pngBytes) = await cv.imencodeAsync('.png', gray);

          // Validate the encoded image data
          if (!success) {
            throw Exception("Failed to encode image as PNG");
          }

          // Create sprite from the PNG-encoded bytes
          final sprite = TxSprite.fromImageBytes(
            msgCode: 0x20,
            imageBytes: pngBytes,
          );

          // Send to device
          final isb = TxImageSpriteBlock(
            msgCode: 0x20,
            image: sprite,
            spriteLineHeight: 20,
            progressiveRender: true,
          );

          await frame!.sendMessage(isb);
          for (final spriteLine in isb.spriteLines) {
            await frame!.sendMessage(spriteLine);
          }

          _log.info('Double tap detected, navigation initiated.');

          await Future.delayed(const Duration(seconds: 3));
          await frame!.sendMessage(TxPlainText(msgCode: 0x14, text: "  "));
        } else {
          _lockedTaps = true;
          await frame!.sendMessage(
            TxPlainText(msgCode: 0x14, text: "Multiple taps detected"),
          );
          _log.info('Multiple taps detected.');

          await Future.delayed(const Duration(seconds: 3));
          _run = true;
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      _log.severe('Error handling tap: $e');
    }
    finally {
      _lockedTaps = false;
    }
  }

  Uint8List convertMatToUint8List(cv.Mat mat) {
    // Check if the Mat is continuous in memory
    if (mat.isContinus) {
      // Directly use the built-in data getter for continuous Mats
      return mat.data;
    } else {
      // Clone the Mat to ensure continuity and access its data
      final clonedMat = cv.Mat.fromMat(mat, copy: true);
      final data = clonedMat.data;
      // Note: Dispose clonedMat after use if your library requires manual cleanup
      return data;
    }
  }

  Future<cv.Mat> getImage(String assetPath, {int cropX = 0, int cropY = 413, int cropWidth = 840, int cropHeight = 1533}) async {
    try {
      // Load the image as bytes from the asset bundle
      final ByteData imageData = await rootBundle.load(assetPath);
      final Uint8List bytes = imageData.buffer.asUint8List();

      // Decode the image bytes into an OpenCV Mat
      final cv.Mat image = cv.imdecode(bytes, cv.IMREAD_COLOR);

      // Check if the image is valid
      if (image.isEmpty) {
        throw Exception("Failed to load image from assets: $assetPath");
      }

      // Define the cropping region using the `region` method
      final cv.Rect cropRect = cv.Rect(cropX, cropY, cropWidth, cropHeight);

      // Crop the image
      final cv.Mat croppedImage = image.region(cropRect);

      // Convert the cropped image to RGB
      final cv.Mat rgbImage = await cv.cvtColorAsync(croppedImage, cv.COLOR_BGR2RGB);
      // final cv.Mat bgrImage = croppedImage.clone(); // Keep original BGR

      // Dispose of intermediate objects to free memory
      croppedImage.dispose();
      image.dispose();

      return rgbImage;
    } catch (e) {
      print("Error in getImage: $e");
      throw Exception("Failed to process the image from assets.");
    }
  }

  Future<void> saveImage(cv.Mat image, String fileName) async {
    try {
      // Check if we already have permissions
      var storageStatus = await Permission.storage.status;
      var manageStatus = await Permission.manageExternalStorage.status;

      // If not granted, request permissions
      if (!storageStatus.isGranted) {
        _log.info('Requesting storage permission...');
        storageStatus = await Permission.storage.request();
      }

      if (!manageStatus.isGranted) {
        _log.info('Requesting manage external storage permission...');
        manageStatus = await Permission.manageExternalStorage.request();
      }

      // If either permission is permanently denied, we need to open settings
      if (storageStatus.isPermanentlyDenied || manageStatus.isPermanentlyDenied) {
        _log.info('Opening settings for permissions...');
        await openAppSettings();
        throw Exception('Please grant storage permissions from settings');
      }

      // Check if we have the permissions we need
      if (storageStatus.isGranted || manageStatus.isGranted) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('Unable to get external storage directory');
        }

        await directory.create(recursive: true);
        final String filePath = '${directory.path}/$fileName';
        _log.info('Saving image to: $filePath');

        await cv.imwriteAsync(filePath, image);
        _log.info('Image successfully saved to: $filePath');
      } else {
        throw Exception('Required storage permissions were not granted');
      }
    } catch (e) {
      _log.severe('Error saving image: $e');
      rethrow;
    }
  }

  Future<cv.Mat> removeSmallComponents(cv.Mat mask, {int minArea = 100}) async {
    final stats = cv.Mat.empty();
    final centroids = cv.Mat.empty();
    final labels = cv.Mat.empty();

    final numLabels = await cv.connectedComponentsWithStatsAsync(
        mask,
        labels,
        stats,
        centroids,
        8,
        4,
        0
    );

    final filteredMask = cv.Mat.zeros(mask.rows, mask.cols, cv.MatType.CV_8UC1);

    for (int i = 1; i < numLabels; i++) {
      final area = stats.at<int>(i, cv.CC_STAT_AREA);
      if (area >= minArea) {
        // Create a 1x1 matrix of type CV_32SC1 containing the label value
        final scalarMat = cv.Mat.fromScalar(
            1,                      // rows
            1,                      // cols
            cv.MatType.CV_32SC1,    // type (matches labels matrix type)
            cv.Scalar(i.toDouble()) // value (convert to double for Scalar)
        );

        final componentMask = await cv.compareAsync(
            labels,
            scalarMat,
            cv.CMP_EQ
        );

        await cv.bitwiseORAsync(filteredMask, componentMask, dst: filteredMask);

        // Cleanup
        scalarMat.dispose();
        componentMask.dispose();
      }
    }

    stats.dispose();
    centroids.dispose();
    labels.dispose();
    return filteredMask;
  }

  Future<cv.Mat> processMask(cv.Mat mask, cv.Mat rgbImage, List<int> color) async {
    final kernel = cv.getStructuringElement(cv.MORPH_RECT, (5, 5));
    final dilatedMask = await cv.dilateAsync(mask, kernel, iterations: 1);

    final floodFilledMask = dilatedMask.clone();
    final maskFloodfill = cv.Mat.zeros(floodFilledMask.rows + 2, floodFilledMask.cols + 2, cv.MatType.CV_8UC1);

    if (floodFilledMask.at<int>(0, 0) & 0xFF > 0){
      await cv.floodFillAsync(
        floodFilledMask,
        cv.Point(0, 0),
        cv.Scalar(255, 255, 255),
        mask: maskFloodfill,
      );
    }

    final connectedMask = await cv.bitwiseORAsync(mask, floodFilledMask);
    final filledImage = cv.Mat.zeros(rgbImage.rows, rgbImage.cols, rgbImage.type);
    filledImage.setTo(cv.Scalar(color[0].toDouble(), color[1].toDouble(), color[2].toDouble()), mask: connectedMask);

    // Cleanup
    kernel.dispose();
    dilatedMask.dispose();
    floodFilledMask.dispose();
    maskFloodfill.dispose();
    connectedMask.dispose();

    return filledImage;
  }

  Future<cv.Mat> getNavLineMask(List<int> lineColorLower, List<int> lineColorUpper, List<int> borderColorLower, List<int> borderColorUpper, cv.Mat rgbImage,) async {

    final lineMask = await cv.inRangeAsync(
      rgbImage,
      cv.Mat.fromScalar(1, 1, cv.MatType.CV_8UC3, cv.Scalar(
        lineColorLower[0].toDouble(),
        lineColorLower[1].toDouble(),
        lineColorLower[2].toDouble(),
      )),
      cv.Mat.fromScalar(1, 1, cv.MatType.CV_8UC3, cv.Scalar(
        lineColorUpper[0].toDouble(),
        lineColorUpper[1].toDouble(),
        lineColorUpper[2].toDouble(),
      )),
    );

    final borderMask = await cv.inRangeAsync(
      rgbImage,
      cv.Mat.fromScalar(1, 1, cv.MatType.CV_8UC3, cv.Scalar(
        borderColorLower[0].toDouble(),
        borderColorLower[1].toDouble(),
        borderColorLower[2].toDouble(),
      )),
      cv.Mat.fromScalar(1, 1, cv.MatType.CV_8UC3, cv.Scalar(
        borderColorUpper[0].toDouble(),
        borderColorUpper[1].toDouble(),
        borderColorUpper[2].toDouble(),
      )),
    );

    final combinedMask = await cv.bitwiseORAsync(lineMask, borderMask);
    final filteredMask = await removeSmallComponents(combinedMask, minArea: 100);
    final processedMask = await processMask(filteredMask, rgbImage, [10, 50, 200]);

    // Cleanup
    lineMask.dispose();
    borderMask.dispose();
    combinedMask.dispose();
    filteredMask.dispose();

    return processedMask;
  }

  Future<cv.Mat> getRedsMask(List<int> colorLower, List<int> colorUpper, cv.Mat rgbImage) async {

    // Convert to BGR color space for OpenCV operations
    final bgrImage = await cv.cvtColorAsync(rgbImage, cv.COLOR_RGB2BGR);

    final redsMask = await cv.inRangeAsync(
      bgrImage,
      cv.Mat.fromScalar(1, 1, cv.MatType.CV_8UC3, cv.Scalar(
        colorLower[0].toDouble(), // B channel (from RGB input)
        colorLower[1].toDouble(), // G channel
        colorLower[2].toDouble(), // R channel
      )),
      cv.Mat.fromScalar(1, 1, cv.MatType.CV_8UC3, cv.Scalar(
        colorUpper[0].toDouble(), // B channel (from RGB input)
        colorUpper[1].toDouble(), // G channel
        colorUpper[2].toDouble(), // R channel
      )),
    );

    await saveImage(redsMask, 'red_mask_raw.jpg');

    final processedMask = await processMask(redsMask, rgbImage, [216, 48, 39]);
    redsMask.dispose();

    return processedMask;
  }

  Future<cv.Mat> getSimplifiedMap(cv.Mat rgbImage) async {
    final gray = await cv.cvtColorAsync(rgbImage, cv.COLOR_RGB2GRAY);
    final edges = await cv.cannyAsync(gray, 100, 200);
    gray.dispose();
    return edges;
  }

  Future<cv.Mat> combineMasks(List<cv.Mat> masks) async {
    cv.Mat? combined;

    for (final mask in masks) {
      cv.Mat currentMask = mask;
      if (currentMask.channels == 1) {
        currentMask = await cv.cvtColorAsync(currentMask, cv.COLOR_GRAY2BGR);
      }

      if (combined == null) {
        combined = currentMask.clone();
      } else {
        final temp = await cv.bitwiseORAsync(combined, currentMask);
        combined.dispose();
        combined = temp;
      }

      if (currentMask != mask) currentMask.dispose();
    }

    final result = await cv.cvtColorAsync(combined ?? cv.Mat.empty(), cv.COLOR_BGR2RGB);
    combined?.dispose();

    return result;
  }

  Future<cv.Mat> processImage() async {
    cv.Mat? rgbImage, navMask, redMask, edgesMask, combinedMasks, resizedOutput;
    try {
      final tStart = DateTime.now();

      rgbImage = await getImage('assets/maps_route_easy.jpg');

      // navMask = await getNavLineMask([10, 60, 240], [20, 80, 255], [0, 20, 210], [10, 30, 220], rgbImage);
      // await saveImage(navMask, 'nav.jpg');
      //
      // redMask = await getRedsMask([180, 0, 0], [255, 100, 50], rgbImage);
      // await saveImage(redMask, 'red.jpg');

      edgesMask = await getSimplifiedMap(rgbImage);
      await saveImage(edgesMask, 'edge.jpg');

      // combinedMasks = await combineMasks([edgesMask, navMask, redMask]);
      combinedMasks = await combineMasks([edgesMask]);

      resizedOutput = await cv.resizeAsync(
        combinedMasks,
        (300, 300),
        interpolation: cv.INTER_AREA,
      );

      await saveImage(resizedOutput, 'edges.jpg');
      _log.info('Processing completed in ${DateTime.now().difference(tStart).inSeconds} seconds');

      return resizedOutput;
    } finally {
      // Ensure proper cleanup even if errors occur
      rgbImage?.dispose();
      // navMask?.dispose();
      // redMask?.dispose();
      edgesMask?.dispose();
      combinedMasks?.dispose();
      // resizedOutput?.dispose();
    }
  }

  @override
  Future<void> run() async {
    _log.info("Reached here: Start Application State");

    _isRunning = true;
    currentState = ApplicationState.running;
    if (mounted) setState(() {});

    await frame!.sendMessage(TxPlainText(msgCode: 0x12, text: "")); // Clear the display initially

    _tapSubs = RxTap().attach(frame!.dataResponse).listen((int taps) async {
      onTap(taps);
    });

    await frame!
        .sendMessage(TxCode(msgCode: 0x16, value: 1)); // Start sending taps

    try {
      while (_isRunning) {
        if (_run){
          _lockedTaps = true;
          await frame!.sendMessage(TxPlainText(msgCode: 0x14, text: "  "));
          await Future.delayed(const Duration(milliseconds: 100));

          final now = DateTime.now();
          await frame!.sendMessage(
            TxPlainText(
                msgCode: 0x12, text: "Custom Visual: ${now.second} seconds"),
          );

          await Future.delayed(const Duration(seconds: 3));
          await frame!.sendMessage(TxPlainText(msgCode: 0x12, text: "  "));

          _run = false;
          _lockedTaps = false;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }

      currentState = ApplicationState.ready;
      if (mounted) setState(() {});
    } catch (e) {
      _log.severe('Error during run loop: $e');
      currentState = ApplicationState.ready;
      if (mounted) setState(() {});
    }
  }

  @override
  Future<void> cancel() async {
    _isRunning = false;
    await frame!
        .sendMessage(TxCode(msgCode: 0x16, value: 0)); // Stop sending taps
    _tapSubs?.cancel();
    _tapSubs = null;

    currentState = ApplicationState.ready;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Frame App Template',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simple Frame App Template'),
          actions: [getBatteryWidget()],
        ),
        body: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(),
            ],
          ),
        ),
        persistentFooterButtons: getFooterButtonsWidget(),
      ),
    );
  }
}
