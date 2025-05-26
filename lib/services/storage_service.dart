import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_model.dart';

class StorageService {
  static const _key = 'devices';

  static Future<void> saveDevice(DeviceModel device) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadDevices();
    list.removeWhere((d) => d.id == device.id);
    list.add(device);
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<List<DeviceModel>> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return [];
    final List decoded = jsonDecode(json);
    return decoded.map((e) => DeviceModel.fromJson(e)).toList();
  }

  static Future<void> removeDevice(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadDevices();
    list.removeWhere((d) => d.id == id);
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
