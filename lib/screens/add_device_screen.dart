import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/device_type.dart';
import '../models/device_model.dart';

class AddDeviceScreen extends StatefulWidget {
  final void Function(DeviceModel) onDeviceAdded;

  const AddDeviceScreen({Key? key, required this.onDeviceAdded}) : super(key: key);

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _ipController = TextEditingController();
  final _nameController = TextEditingController();

  DeviceType? _selectedType = DeviceType.curtain;

  bool _loading = false;
  String? _errorMessage;

  List<BluetoothDevice> _bleDevices = [];
  BluetoothDevice? _selectedBleDevice;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _connectByIP(String ip) async {
    await Future.delayed(const Duration(seconds: 1));
    final parts = ip.split('.');
    if (parts.length == 4 && parts.every((e) => int.tryParse(e) != null)) {
      return true;
    }
    return false;
  }

  Future<bool> _connectByBLE(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 3));
      await device.disconnect();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _scanBleDevices() async {
    setState(() {
      _bleDevices.clear();
      _selectedBleDevice = null;
      _errorMessage = null;
      _loading = true;
    });

    FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 4));

    // Listen scan results once
    FlutterBluePlus.instance.scanResults.listen((results) {
      final newDevices = <BluetoothDevice>[];
      for (var r in results) {
        if (!_bleDevices.any((d) => d.id == r.device.id)) {
          newDevices.add(r.device);
        }
      }
      if (newDevices.isNotEmpty) {
        setState(() {
          _bleDevices.addAll(newDevices);
        });
      }
    });

    // Wait for scan timeout, then stop
    await Future.delayed(const Duration(seconds: 4));
    await FlutterBluePlus.instance.stopScan();

    setState(() {
      _loading = false;
      if (_bleDevices.isEmpty) {
        _errorMessage = 'Không tìm thấy thiết bị BLE nào.';
      }
    });
  }

  void _onAddDevice() async {
    setState(() {
      _errorMessage = null;
      _loading = true;
    });

    if (_selectedType == null) {
      setState(() {
        _errorMessage = 'Chưa chọn loại thiết bị';
        _loading = false;
      });
      return;
    }

    String id = const Uuid().v4();
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      name = '${deviceTypeToString(_selectedType!)} #${id.substring(0, 4)}';
    }

    bool success = false;

    if (_tabController.index == 0) {
      String ip = _ipController.text.trim();
      success = await _connectByIP(ip);
      if (success) {
        final device = DeviceModel(
          id: ip,
          name: name,
          connection: ip,
          type: _selectedType!,
        );
        setState(() {
          _loading = false;
        });
        widget.onDeviceAdded(device);
        Navigator.of(context).pop(device);
        return;
      }
    } else {
      if (_selectedBleDevice == null) {
        setState(() {
          _errorMessage = 'Chưa chọn thiết bị BLE';
          _loading = false;
        });
        return;
      }
      success = await _connectByBLE(_selectedBleDevice!);
      if (success) {
        final device = DeviceModel(
          id: _selectedBleDevice!.id.id,
          name: name,
          connection: _selectedBleDevice!.id.id,
          type: _selectedType!,
        );
        setState(() {
          _loading = false;
        });
        widget.onDeviceAdded(device);
        Navigator.of(context).pop(device);
        return;
      }
    }

    setState(() {
      _errorMessage = 'Kết nối thất bại';
      _loading = false;
    });
  }

  Widget _buildIpTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên thiết bị',
              hintText: 'Ví dụ: Rèm phòng khách',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ipController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ IP ESP32',
              hintText: 'Ví dụ: 192.168.1.10',
            ),
          ),
          const SizedBox(height: 16),
          _buildDeviceTypeDropdown(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _onAddDevice,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kết nối & Thêm thiết bị'),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildBleTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên thiết bị',
              hintText: 'Ví dụ: Rèm phòng khách',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : _scanBleDevices,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Quét thiết bị BLE'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _bleDevices.isEmpty
                ? Center(
                    child: Text(_loading
                        ? 'Đang quét thiết bị...'
                        : 'Chưa quét thiết bị hoặc không tìm thấy'),
                  )
                : ListView.builder(
                    itemCount: _bleDevices.length,
                    itemBuilder: (_, i) {
                      final d = _bleDevices[i];
                      final selected = _selectedBleDevice?.id == d.id;
                      return ListTile(
                        title: Text(d.name.isEmpty ? d.id.id : d.name),
                        subtitle: Text(d.id.id),
                        trailing: selected ? const Icon(Icons.check) : null,
                        onTap: () {
                          setState(() {
                            _selectedBleDevice = d;
                          });
                        },
                      );
                    },
                  ),
          ),
          _buildDeviceTypeDropdown(),
          ElevatedButton(
            onPressed: _loading ? null : _onAddDevice,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kết nối & Thêm thiết bị'),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildDeviceTypeDropdown() {
    return DropdownButton<DeviceType>(
      value: _selectedType,
      isExpanded: true,
      items: DeviceType.values
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(deviceTypeToString(e)),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) {
          setState(() {
            _selectedType = v;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm thiết bị'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Nhập IP'),
            Tab(text: 'Quét BLE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIpTab(),
          _buildBleTab(),
        ],
      ),
    );
  }
}
