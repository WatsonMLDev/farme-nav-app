import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for rootBundle
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';

import 'package:simple_frame_app/simple_frame_app.dart';
import 'package:simple_frame_app/tx/plain_text.dart';

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
        await frame!.sendString('require("$bareFileName")', awaitResponse: true);
      } else if (luaFiles.contains('assets/frame_app.min.lua')) {
        await frame!.sendString('require("frame_app.min")', awaitResponse: true);
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

  @override
  Future<void> run() async {
    _isRunning = true;
    currentState = ApplicationState.running;
    if (mounted) setState(() {});

    try {
      await frame!.sendMessage(TxPlainText( msgCode:0x12, text:"" ));
      while (_isRunning) {
        final currentTime = DateFormat('hh:mm a').format(DateTime.now());
        if (_lastSentTime != currentTime) {
          await frame!.sendMessage(TxPlainText( msgCode: 0x14, text: '$currentTime~$batteryLevel%',));
          _lastSentTime = currentTime;
          _log.info('Sent new time: $currentTime');
        }


        await Future.delayed(const Duration(seconds: 1)); // Adjust the interval if needed
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
