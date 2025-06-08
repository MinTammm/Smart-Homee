import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../controllers/device_controller.dart';
import 'add_device_screen.dart';
import '../widgets/curtain_control_widget.dart';
import '../widgets/light_control_widget.dart';
import '../widgets/tv_control_widget.dart';
import '../widgets/device_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeviceController _controller = DeviceController();

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    await _controller.loadDevices();
    setState(() {});
  }

  void _addDevice(Device device) async {
    await _controller.addDevice(device);
    setState(() {});
  }

  void _removeDevice(Device device) async {
    await _controller.removeDevice(device);
    setState(() {});
  }

  void _openControl(Device device) {
  if (device.type == DeviceType.curtain) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CurtainControlWidget(device: device)),
    );
  } else if (device.type == DeviceType.light) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LightControlWidget(device: device)),
    );
  } else if (device.type == DeviceType.tv) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TVControlWidget(device: device)),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Home')),
      body: ListView(
        children: _controller.devices.map((device) {
          return DeviceCard(
            device: device,
            onTap: () => _openControl(device),
            onDelete: () => _removeDevice(device),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
          );
          if (result != null && result is Device) {
            _addDevice(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}