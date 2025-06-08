import '../models/device_model.dart';
import '../services/storage_service.dart';

class DeviceController {
  List<Device> _devices = [];

  List<Device> get devices => _devices;

  Future<void> loadDevices() async {
    _devices = await StorageService.loadDevices();
  }

  Future<void> addDevice(Device device) async {
    _devices.add(device);
    await StorageService.saveDevices(_devices);
  }

  Future<void> removeDevice(Device device) async {
    _devices.remove(device);
    await StorageService.saveDevices(_devices);
  }
}
