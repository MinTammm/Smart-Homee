import 'package:http/http.dart' as http;
import 'dart:convert'; // Thêm để decode JSON

class ESP32HttpService {
  /// Gửi lệnh điều khiển (mở, đóng, dừng, bật, tắt...)
  static Future<bool> sendCommand(String address, String command) async {
    try {
      final url = Uri.parse('http://$address/$command');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Lấy phần trăm mở của rèm
  static Future<int?> getCurtainPercentage(String address) async {
    try {
      final url = Uri.parse('http://$address/status');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['percent'] as int?;
      }
    } catch (e) {
      print('Lỗi khi lấy phần trăm rèm: $e');
    }
    return null;
  }

  /// Lấy trạng thái bật/tắt của đèn (true = bật, false = tắt)
  static Future<bool?> getLightStatus(String address) async {
    try {
      final url = Uri.parse('http://$address/light_status');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final status = response.body.trim().toLowerCase();
        return status == 'on';
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Lấy trạng thái bật/tắt của TV (true = bật, false = tắt)
  static Future<bool?> getTVStatus(String address) async {
    try {
      final url = Uri.parse('http://$address/tv_status');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final status = response.body.trim().toLowerCase();
        return status == 'on';
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Kiểm tra kết nối IP có đúng và thiết bị có phản hồi không
  /// Yêu cầu ESP32 trả về 'pong' khi truy cập endpoint /ping để xác thực
  static Future<bool> checkConnection(String address) async {
    try {
      final url = Uri.parse('http://$address/ping');
      final response = await http.get(url).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200 && response.body.trim().toLowerCase() == 'pong') {
        return true;
      }
    } catch (e) {
      // lỗi kết nối, timeout, hoặc sai nội dung đều trả về false
    }
    return false;
  }
}
