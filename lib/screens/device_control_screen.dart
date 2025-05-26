import 'package:flutter/material.dart';
import '../../models/device_model.dart';
import '../../models/device_type.dart';
import 'curtain_control.dart';
import 'light_control.dart';
import 'tv_control.dart';
import 'door_control.dart';

class DeviceControlScreen extends StatelessWidget {
  final DeviceModel device;

  const DeviceControlScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    Widget control;

    switch (device.type) {
      case DeviceType.curtain:
        control = CurtainControl(device: device);
        break;
      case DeviceType.light:
        control = LightControl(device: device);
        break;
      case DeviceType.tv:
        control = TvControl(device: device);
        break;
      case DeviceType.door:
        control = DoorControl(device: device);
        break;
      default:
        control = Center(
          child: Text('Loại thiết bị không được hỗ trợ'),
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text(device.name)),
      body: control,
    );
  }
}
