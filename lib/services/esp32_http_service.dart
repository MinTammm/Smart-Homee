import 'dart:convert';
import 'package:http/http.dart' as http;

class Esp32HttpService {
  final String ip;

  Esp32HttpService({required this.ip});

  Uri _buildUri(String path) => Uri.parse('http://$ip$path');

  Future<bool> sendCommand(String command) async {
    try {
      final response = await http.get(_buildUri('/$command'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<int?> getCurtainStatus() async {
    try {
      final response = await http.get(_buildUri('/status'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['percent'];
      }
    } catch (_) {}
    return null;
  }
}
