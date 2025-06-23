import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:Smarthome/services/esp32_http_service.dart';
import 'ble_mac_to_ip.dart';

class BLEService {
  static final Guid serviceUuid = Guid("12345678-1234-1234-1234-123456789abc");
  static final Guid txCharUuid = Guid("12345678-1234-1234-1234-123456789abd");
  static final Guid rxCharUuid = Guid("12345678-1234-1234-1234-123456789abe");

  static BluetoothCharacteristic? _rxChar;
  static BluetoothDevice? _connectedDevice;

  /// Quét thiết bị BLE trong 4 giây
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

  /// Kết nối tới ESP32 và đăng ký lắng nghe dữ liệu từ TX
  static Future<void> connectAndListen(
    BluetoothDevice device,
    Function(String) onData,
  ) async {
    try {
      // Kết nối nếu chưa kết nối
      final state = await device.state.first;
      if (state != BluetoothDeviceState.connected) {
        await device.connect(timeout: const Duration(seconds: 5));
      }

      _connectedDevice = device;

      final services = await device.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid == serviceUuid,
        orElse: () => throw Exception("Service UUID not found"),
      );

      final txChar = service.characteristics.firstWhere(
        (c) => c.uuid == txCharUuid,
        orElse: () => throw Exception("TX Characteristic not found"),
      );

      final rxChar = service.characteristics.firstWhere(
        (c) => c.uuid == rxCharUuid,
        orElse: () => throw Exception("RX Characteristic not found"),
      );

      _rxChar = rxChar;

      // Lắng nghe phản hồi từ ESP32
      await txChar.setNotifyValue(true);
      txChar.onValueReceived.listen((value) {
        final msg = utf8.decode(value);
        print("BLE received: $msg");
        onData(msg);
      });

      print("Đã kết nối BLE và lắng nghe dữ liệu.");
    } catch (e) {
      print("BLE connect error: $e");
    }
  }

  /// Gửi lệnh OPEN / CLOSE / STOP tới ESP32 qua BLE
  static Future<void> sendCommand(String command) async {
    if (_rxChar == null || _connectedDevice == null) {
      print("⚠️ BLE chưa kết nối.");
      return;
    }

    try {
      final data = utf8.encode(command.trim().toUpperCase());
      await _rxChar!.write(data, withoutResponse: false);
      print("Đã gửi lệnh BLE: $command");
    } catch (e) {
      print("BLE send error: $e");
    }
  }

  /// Ngắt kết nối BLE
  static Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      print("Đã ngắt kết nối BLE.");
      _connectedDevice = null;
      _rxChar = null;
    }
  }
}
