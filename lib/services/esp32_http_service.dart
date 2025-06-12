import 'package:http/http.dart' as http;
import 'dart:convert';

class ESP32HttpService {
  /// Gửi lệnh điều khiển (mở, đóng, dừng, bật, tắt...)
  static Future<bool> sendCommand(String address, String command) async {
    try {
      final url = Uri.parse('http://$address/$command');
      print('[ESP32HttpService] Gửi lệnh: GET $url');
      final response = await http.get(url);
      print('[ESP32HttpService] Phản hồi: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('[ESP32HttpService] Lỗi gửi lệnh "$command" đến $address: $e');
      return false;
    }
  }

  /// Lấy phần trăm mở của rèm
  static Future<int?> getCurtainPercentage(String address) async {
    try {
      final url = Uri.parse('http://$address/status');
      print('[ESP32HttpService] Lấy trạng thái rèm: GET $url');
      final response = await http.get(url);
      print('[ESP32HttpService] Phản hồi trạng thái rèm: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['percentage'] as int?;
      }
    } catch (e) {
      print('[ESP32HttpService] Lỗi khi lấy phần trăm rèm: $e');
    }
    return null;
  }

  /// Lấy trạng thái bật/tắt của đèn
  static Future<bool?> getLightStatus(String address) async {
    try {
      final url = Uri.parse('http://$address/light_status');
      print('[ESP32HttpService] Lấy trạng thái đèn: GET $url');
      final response = await http.get(url);
      print('[ESP32HttpService] Phản hồi trạng thái đèn: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final status = response.body.trim().toLowerCase();
        return status == 'on';
      }
    } catch (e) {
      print('[ESP32HttpService] Lỗi khi lấy trạng thái đèn: $e');
    }
    return null;
  }

  /// Lấy trạng thái bật/tắt của TV
  static Future<bool?> getTVStatus(String address) async {
    try {
      final url = Uri.parse('http://$address/tv_status');
      print('[ESP32HttpService] Lấy trạng thái TV: GET $url');
      final response = await http.get(url);
      print('[ESP32HttpService] Phản hồi trạng thái TV: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final status = response.body.trim().toLowerCase();
        return status == 'on';
      }
    } catch (e) {
      print('[ESP32HttpService] Lỗi khi lấy trạng thái TV: $e');
    }
    return null;
  }

  /// Kiểm tra kết nối với ESP32 bằng endpoint /ping
  static Future<bool> checkConnection(String address) async {
    try {
      final url = Uri.parse('http://$address/ping');
      print('[ESP32HttpService] Kiểm tra kết nối: GET $url');
      final response = await http.get(url).timeout(const Duration(seconds: 2));
      print('[ESP32HttpService] Phản hồi /ping: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 && response.body.trim().toLowerCase() == 'pong') {
        return true;
      }
    } catch (e) {
      print('[ESP32HttpService] Lỗi kiểm tra kết nối: $e');
    }
    return false;
  }
}
