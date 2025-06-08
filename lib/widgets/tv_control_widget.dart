import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/esp32_http_service.dart';

class TVControlWidget extends StatefulWidget {
  final Device device;

  const TVControlWidget({super.key, required this.device});

  @override
  State<TVControlWidget> createState() => _TVControlWidgetState();
}

class _TVControlWidgetState extends State<TVControlWidget> {
  bool isOn = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() => loading = true);
    final result = await ESP32HttpService.getTVStatus(widget.device.address);
    if (result != null) setState(() => isOn = result);
    setState(() => loading = false);
  }

  Future<void> _sendCommand(String cmd) async {
    await ESP32HttpService.sendCommand(widget.device.address, cmd);
    await _fetchStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(Icons.tv, size: 100, color: isOn ? Colors.blue : Colors.grey),
                  const SizedBox(height: 20),
                  Text('Trạng thái: ${isOn ? 'Bật' : 'Tắt'}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'tv_on',
                        backgroundColor: Colors.green,
                        onPressed: () => _sendCommand('on'),
                        child: const Icon(Icons.power, color: Colors.white),
                      ),
                      FloatingActionButton(
                        heroTag: 'tv_off',
                        backgroundColor: Colors.red,
                        onPressed: () => _sendCommand('off'),
                        child: const Icon(Icons.power_off, color: Colors.white),
                      ),
                      FloatingActionButton(
                        heroTag: 'tv_volume_down',
                        backgroundColor: Colors.blueGrey,
                        onPressed: () => _sendCommand('volume_down'),
                        child: const Icon(Icons.volume_down, color: Colors.white),
                      ),
                      FloatingActionButton(
                        heroTag: 'tv_volume_up',
                        backgroundColor: Colors.blue,
                        onPressed: () => _sendCommand('volume_up'),
                        child: const Icon(Icons.volume_up, color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
