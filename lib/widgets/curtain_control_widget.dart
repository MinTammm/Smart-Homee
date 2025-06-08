import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/esp32_http_service.dart';

class CurtainControlWidget extends StatefulWidget {
  final Device device;

  const CurtainControlWidget({super.key, required this.device});

  @override
  State<CurtainControlWidget> createState() => _CurtainControlWidgetState();
}

class _CurtainControlWidgetState extends State<CurtainControlWidget> {
  int percentage = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() => loading = true);
    final result = await ESP32HttpService.getCurtainPercentage(widget.device.address);
    if (result != null) setState(() => percentage = result);
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nhãn dán biểu tượng rèm
                  const Center(
                    child: Icon(Icons.window, size: 100, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Độ mở rèm: $percentage%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),

                  Slider(
                    value: percentage.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '$percentage%',
                    onChanged: null, // Read-only slider
                  ),
                  const SizedBox(height: 30),

                  // Ba nút tròn điều khiển nằm ngang
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'open',
                        backgroundColor: Colors.green,
                        onPressed: () => _sendCommand('open'),
                        child: const Icon(Icons.arrow_upward, color: Colors.white),
                      ),
                      FloatingActionButton(
                        heroTag: 'stop',
                        backgroundColor: Colors.orange,
                        onPressed: () => _sendCommand('stop'),
                        child: const Icon(Icons.pause, color: Colors.white),
                      ),
                      FloatingActionButton(
                        heroTag: 'close',
                        backgroundColor: Colors.red,
                        onPressed: () => _sendCommand('close'),
                        child: const Icon(Icons.arrow_downward, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
