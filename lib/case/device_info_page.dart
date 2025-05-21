import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:system_info2/system_info2.dart';
import 'package:will_widget_playground/utils/currency_formatter_w.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

const int megaByte = 1024 * 1024;

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  static const platform = MethodChannel('com.will/device');
  String _storageInfo = 'Unknown storage info.';
  bool? _jailbroken;
  bool? _developerMode;

  @override
  void initState() {

    super.initState();
    getTotalRam();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Device Info Page")),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            _buildExampleSection("RAM"),
            _buildExampleContent('Total physical memory   '
                ': ${SysInfo.getTotalPhysicalMemory() ~/ megaByte} MB'),
            _buildExampleContent(_storageInfo),
            _buildExampleContent('Jailbroken: ${_jailbroken == null ? "Unknown" : _jailbroken! ? "YES" : "NO"}'),
            _buildExampleContent('Developer mode: ${_developerMode == null ? "Unknown" : _developerMode! ? "YES" : "NO"}')
          ],
        ),
      ),
    );
  }

  Widget _buildExampleSection(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800])),
    );
  }

  Widget _buildExampleContent(String content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child:
          Text(content, style: TextStyle(fontSize: 14, color: Colors.black26)),
    );
  }

  Future getTotalRam() async {
    String storageInfo;
    try {
      final int totalStorage = await platform.invokeMethod('getTotalStorage');
      final int freeStorage = await platform.invokeMethod('getFreeStorage');
      final int totalStorage2 = await platform.invokeMethod('getTotalStorage2');
      final int getRomInfo = await platform.invokeMethod('getRomInfo');
      final num getRemUseInfo = await platform.invokeMethod('getRemUseInfo');
      storageInfo =
          'Total Storage: $totalStorage MB\nFree Storage: $freeStorage MB \nTotal Storage2: $totalStorage2 MB \nRomInfo: $getRomInfo MB \nRemUseInfo: $getRemUseInfo';
    } on PlatformException catch (e) {
      storageInfo = "Failed to get storage info: '${e.message}'.";
    }
    setState(() {
      _storageInfo = storageInfo;
    });
  }

  Future<void> initPlatformState() async {
    bool jailbroken;
    bool developerMode;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      jailbroken = await FlutterJailbreakDetection.jailbroken;
      developerMode = await FlutterJailbreakDetection.developerMode;
    } on PlatformException {
      jailbroken = true;
      developerMode = true;
    }

    var rootResult = await isRoot();
    debugPrint('rootResult: $rootResult');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _jailbroken = jailbroken;
      _developerMode = developerMode;
    });
  }

  Future<String> isRoot() async {
    String result = "0";
    try {
      var bool = await FlutterJailbreakDetection.jailbroken;
      if (bool) result = "1";
      return result;
    } catch (e) {
      return result;
    }
  }

}
