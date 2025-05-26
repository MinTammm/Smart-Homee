import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../models/device_type.dart';
import '../services/storage_service.dart';
import 'add_device_screen.dart';
import 'device_control_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DeviceModel> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final loadedDevices = await StorageService.loadDevices();
    setState(() {
      _devices = loadedDevices;
    });
  }

  Future<void> _deleteDevice(String id) async {
    await StorageService.removeDevice(id);
    await _loadDevices();
  }

  Future<void> _addDevice() async {
    final device = await Navigator.of(context).push<DeviceModel>(
      MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
    );

    if (device != null) {
      await StorageService.saveDevice(device);
      await _loadDevices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Home')),
      body: _devices.isEmpty
          ? const Center(child: Text('Chưa có thiết bị'))
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  leading: Icon(deviceTypeToIcon(device.type)),
                  title: Text(device.name),
                  subtitle: Text(deviceTypeToString(device.type)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteDevice(device.id),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceControlScreen(device: device),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDevice,
        child: const Icon(Icons.add),
      ),
    );
  }
}
