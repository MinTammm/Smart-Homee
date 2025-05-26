import 'package:flutter/material.dart';
import '../models/device_model.dart';

class DeviceTile extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DeviceTile({
    super.key,
    required this.device,
    required this.onTap,
    required this.onDelete,
  });

  String getStatus() {
    if (device.type == DeviceType.curtain) {
      return 'Độ mở: ${device.curtainPercentOpen.toStringAsFixed(0)}%';
    }
    return 'Kết nối';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        deviceTypeToIcon(device.type),
        size: 36,
        color: Colors.blue,
      ),
      title: Text(device.name),
      subtitle: Text(getStatus()),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
