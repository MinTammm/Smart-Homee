import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  static Future<List<BluetoothDevice>> scanDevices() async {
    final devices = <BluetoothDevice>{};

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        devices.add(r.device);
      }
    });

    await Future.delayed(const Duration(seconds: 4));
    await FlutterBluePlus.stopScan();
    await subscription.cancel();

    return devices.toList();
  }

  static Future<void> sendData(BluetoothDevice device, String data) async {
    await device.connect();
    // Giả sử ESP32 có service/characteristic UUID sau, bạn thay theo firmware:
    final serviceUuid = Guid("0000ffe0-0000-1000-8000-00805f9b34fb");
    final charUuid = Guid("0000ffe1-0000-1000-8000-00805f9b34fb");

    final services = await device.discoverServices();
    final service = services.firstWhere((s) => s.uuid == serviceUuid);
    final characteristic = service.characteristics.firstWhere((c) => c.uuid == charUuid);

    final bytes = data.codeUnits;
    await characteristic.write(bytes);

    await device.disconnect();
  }
}
