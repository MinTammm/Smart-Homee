import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/device_model.dart';

class StorageService {
  static const _key = 'devices';

  static Future<void> saveDevices(List<Device> devices) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(devices.map((d) => d.toJson()).toList());
    await prefs.setString(_key, data);
  }

  static Future<List<Device>> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Device.fromJson(e)).toList();
  }
}
