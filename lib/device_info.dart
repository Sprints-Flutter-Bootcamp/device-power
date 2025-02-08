import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:device_power/widgets/my_app_bar.dart';

class DeviceInfo extends StatefulWidget {
  const DeviceInfo({super.key});

  @override
  State<DeviceInfo> createState() => _DeviceInfoState();
}

class _DeviceInfoState extends State<DeviceInfo> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = {};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;

    Map<String, dynamic> deviceData = {};

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData = {
          'Brand': androidInfo.brand,
          'Model': androidInfo.model,
          'Manufacturer': androidInfo.manufacturer,
          'Android Version': androidInfo.version.release,
          'SDK Version': androidInfo.version.sdkInt,
          'Physical Device': androidInfo.isPhysicalDevice ? 'Yes' : 'No',
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData = {
          'Device': iosInfo.name,
          'Model': iosInfo.model,
          'System Version': iosInfo.systemVersion,
          'Identifier': iosInfo.identifierForVendor,
          'Physical Device': iosInfo.isPhysicalDevice ? 'Yes' : 'No',
        };
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await deviceInfoPlugin.windowsInfo;
        deviceData = {
          'Computer Name': windowsInfo.computerName,
          'Product Name': windowsInfo.productName,
          'User Name': windowsInfo.userName,
          'Total RAM (MB)': windowsInfo.systemMemoryInMegabytes,
        };
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macInfo = await deviceInfoPlugin.macOsInfo;
        deviceData = {
          'Computer Name': macInfo.computerName,
          'Model': macInfo.model,
          'OS Version': macInfo.osRelease,
          'CPU Cores': macInfo.activeCPUs,
          'Memory Size': macInfo.memorySize,
        };
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await deviceInfoPlugin.linuxInfo;
        deviceData = {
          'Name': linuxInfo.name,
          'Version': linuxInfo.version,
          'Pretty Name': linuxInfo.prettyName,
        };
      }
    } catch (e) {
      deviceData = {'Error': 'Failed to get device info'};
    }

    setState(() {
      _deviceData = deviceData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, "Device Info"),
      body: ListView(
        children: _deviceData.entries.map((entry) {
          return ListTile(
            title: Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${entry.value}'),
          );
        }).toList(),
      ),
    );
  }
}
