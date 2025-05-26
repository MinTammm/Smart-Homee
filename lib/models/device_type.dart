enum DeviceType { curtain, light, tv, door }

String deviceTypeToString(DeviceType type) {
  switch (type) {
    case DeviceType.curtain:
      return 'Rèm';
    case DeviceType.light:
      return 'Đèn';
    case DeviceType.tv:
      return 'TV';
    case DeviceType.door:
      return 'Cửa';
  }
}

IconData deviceTypeToIcon(DeviceType type) {
  switch (type) {
    case DeviceType.curtain:
      return Icons.window;
    case DeviceType.light:
      return Icons.lightbulb;
    case DeviceType.tv:
      return Icons.tv;
    case DeviceType.door:
      return Icons.door_front_door;
  }
}
