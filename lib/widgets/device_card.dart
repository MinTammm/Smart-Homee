import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../utils/device_icons.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(getDeviceIcon(device.type)),
        title: Text(device.name),
        subtitle: Text('${device.connection} - ${device.address}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
