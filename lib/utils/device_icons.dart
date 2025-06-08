import 'package:flutter/material.dart';
import '../models/device_model.dart';

IconData getDeviceIcon(DeviceType type) {
  switch (type) {
    case DeviceType.curtain:
      return Icons.window;
    case DeviceType.light:
      return Icons.lightbulb;
    case DeviceType.tv:
      return Icons.tv;
    case DeviceType.door:
      return Icons.door_front_door;
    default:
      return Icons.device_unknown;
  }
}