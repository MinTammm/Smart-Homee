import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/esp32_http_service.dart';

class LightControlWidget extends StatefulWidget {
  final Device device;

  const LightControlWidget({super.key, required this.device});

  @override
  State<LightControlWidget> createState() => _LightControlWidgetState();
}

class _LightControlWidgetState extends State<LightControlWidget> {
  bool isOn = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() => loading = true);
    final result = await ESP32HttpService.getLightStatus(widget.device.address);
    if (result != null) setState(() => isOn = result);
    setState(() => loading = false);
  }

  Future<void> _toggleLight(bool turnOn) async {
    await ESP32HttpService.sendCommand(widget.device.address, turnOn ? 'on' : 'off');
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
                  Icon(Icons.lightbulb, size: 100, color: isOn ? Colors.yellow : Colors.grey),
                  const SizedBox(height: 20),
                  Text('Trạng thái: ${isOn ? 'Bật' : 'Tắt'}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'light_on',
                        backgroundColor: Colors.green,
                        onPressed: () => _toggleLight(true),
                        child: const Icon(Icons.power, color: Colors.white),
                      ),
                      FloatingActionButton(
                        heroTag: 'light_off',
                        backgroundColor: Colors.red,
                        onPressed: () => _toggleLight(false),
                        child: const Icon(Icons.power_off, color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
