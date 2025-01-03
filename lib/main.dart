import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for rootBundle
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';

import 'package:simple_frame_app/simple_frame_app.dart';
import 'package:simple_frame_app/tx/plain_text.dart';
import 'package:simple_frame_app/rx/tap.dart';
import 'package:simple_frame_app/tx/code.dart';

void main() => runApp(const MainApp());

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

  String? _lastSentTime;
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
          _lockedTaps = false;
        } else if (taps == 2) {
          _lockedTaps = true;
          await frame!.sendMessage(
            TxPlainText(msgCode: 0x14, text: "Double Tap - Navigation"),
          );
          _log.info('Double tap detected, navigation initiated.');

          await Future.delayed(const Duration(seconds: 3));
          await frame!.sendMessage(TxPlainText(msgCode: 0x14, text: "  "));
          _lockedTaps = false;
        } else {
          _lockedTaps = true;
          await frame!.sendMessage(
            TxPlainText(msgCode: 0x14, text: "Multiple taps detected"),
          );
          _log.info('Multiple taps detected.');

          await Future.delayed(const Duration(seconds: 3));
          _run = true;
          _lockedTaps = false;
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      _log.severe('Error handling tap: $e');
    }
  }

  @override
  Future<void> run() async {
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
