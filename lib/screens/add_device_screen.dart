import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/device_model.dart';
import '../services/ble_service.dart';
import '../services/esp32_http_service.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ipController = TextEditingController();

  String name = '';
  String address = '';
  String connection = 'IP';
  DeviceType type = DeviceType.curtain;
  List<BluetoothDevice> scannedDevices = [];
  bool _isLoading = false;

  Future<void> _scanBLE() async {
    final devices = await BLEService.scanDevices();
    setState(() => scannedDevices = devices);
  }

  bool _validateIp(String ip) {
    final regex = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
    return regex.hasMatch(ip) &&
        ip.split('.').every((octet) => int.parse(octet) <= 255);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    String ip = ipController.text.trim();

    if (connection == 'IP') {
      if (!_validateIp(ip)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Địa chỉ IP không hợp lệ')),
        );
        return;
      }

      setState(() => _isLoading = true);
      final connected = await ESP32HttpService.checkConnection(ip);
      setState(() => _isLoading = false);

      if (!connected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không kết nối được tới thiết bị.')),
        );
        return;
      }
    }

    final newDevice = Device(
      id: const Uuid().v4(),
      name: name.trim(),
      connection: connection,
      address: connection == 'IP' ? ip : address.trim(),
      type: type,
    );

    Navigator.pop(context, newDevice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm thiết bị')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: connection,
                items: ['IP', 'BLE']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    connection = value!;
                    address = '';
                    scannedDevices = [];
                    ipController.clear();
                  });
                },
                decoration: const InputDecoration(labelText: 'Kết nối'),
              ),
              const SizedBox(height: 10),

              if (connection == 'BLE') ...[
                ElevatedButton(
                  onPressed: _scanBLE,
                  child: const Text('Quét thiết bị BLE'),
                ),
                if (scannedDevices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Chưa tìm thấy thiết bị.'),
                  ),
                ...scannedDevices.map(
                  (d) => ListTile(
                    title: Text(d.name.isNotEmpty ? d.name : d.id.toString()),
                    subtitle: Text(d.id.toString()),
                    onTap: () {
                      setState(() {
                        address = d.id.toString();
                        name = d.name.isNotEmpty ? d.name : 'BLE Device';
                      });
                    },
                    selected: d.id.toString() == address,
                    selectedTileColor: Colors.blue.shade100,
                  ),
                ),
              ],

              TextFormField(
                decoration: const InputDecoration(labelText: 'Tên thiết bị'),
                initialValue: name,
                onChanged: (val) => name = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Không được để trống' : null,
              ),

              if (connection == 'IP')
                TextFormField(
                  controller: ipController,
                  decoration: const InputDecoration(labelText: 'Địa chỉ IP'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Không được để trống' : null,
                ),

              DropdownButtonFormField<DeviceType>(
                value: type,
                items: DeviceType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (val) => setState(() => type = val!),
                decoration: const InputDecoration(labelText: 'Loại thiết bị'),
              ),
              const SizedBox(height: 20),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Thêm thiết bị'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
