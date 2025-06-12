import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  static final Guid serviceUuid = Guid("12345678-1234-1234-1234-123456789abc");
  static final Guid rxCharUuid = Guid("12345678-1234-1234-1234-123456789abe");

  /// Quét BLE trong 4 giây và trả về danh sách thiết bị tìm thấy
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

  /// Gửi dữ liệu tới ESP32 qua BLE
  static Future<void> sendData(BluetoothDevice device, String data) async {
    try {
      // Kết nối nếu chưa kết nối
      if (device.connectionState != BluetoothConnectionState.connected) {
        await device.connect(timeout: const Duration(seconds: 5));
      }

      final services = await device.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid == serviceUuid,
        orElse: () => throw Exception("Service UUID not found"),
      );

      final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid == rxCharUuid,
        orElse: () => throw Exception("RX Characteristic not found"),
      );

      final bytes = data.codeUnits;
      await characteristic.write(bytes, withoutResponse: false);
    } catch (e) {
      print("BLE write error: $e");
    } finally {
      // Ngắt kết nối sau khi gửi
      await device.disconnect();
    }
  }
}
