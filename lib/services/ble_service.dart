import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  BluetoothDevice? device;
  BluetoothCharacteristic? commandChar;
  BluetoothCharacteristic? statusChar;

  Future<bool> connect(BluetoothDevice device) async {
    try {
      this.device = device;
      await device.connect(autoConnect: false);
      var services = await device.discoverServices();

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            commandChar = characteristic;
          }
          if (characteristic.properties.read || characteristic.properties.notify) {
            statusChar = characteristic;
          }
        }
      }

      return commandChar != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendCommand(String command) async {
    try {
      await commandChar?.write(utf8.encode(command));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<int?> getCurtainStatus() async {
    try {
      var value = await statusChar?.read();
      return int.tryParse(utf8.decode(value ?? []));
    } catch (_) {
      return null;
    }
  }

  Future<void> disconnect() async {
    await device?.disconnect();
  }
}
