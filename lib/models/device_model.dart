enum DeviceType { curtain, light, tv, door }

extension DeviceTypeExtension on DeviceType {
  String get name {
    switch (this) {
      case DeviceType.curtain:
        return 'curtain';
      case DeviceType.light:
        return 'light';
      case DeviceType.tv:
        return 'tv';
      case DeviceType.door:
        return 'door';
    }
  }

  static DeviceType fromString(String s) {
    switch (s) {
      case 'curtain':
        return DeviceType.curtain;
      case 'light':
        return DeviceType.light;
      case 'tv':
        return DeviceType.tv;
      case 'door':
        return DeviceType.door;
      default:
        return DeviceType.curtain;
    }
  }
}

class Device {
  final String id;
  final String name;
  final String address;
  final String connection; // 'IP' or 'BLE'
  final String mac; // dùng để ánh xạ IP
  final String ip;  // IP dùng để gửi lệnh qua HTTP
  final DeviceType type;

  Device({
    required this.id,
    required this.name,
    required this.connection,
    required this.mac,
    required this.type,
    required this.address,
    required this.ip,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'],
        name: json['name'],
        connection: json['connection'],
        mac: json['mac'] ?? '',
        address: json['address'] ?? '',
        ip: json['ip'],
        type: DeviceTypeExtension.fromString(json['type']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'connection': connection,
        'mac': mac,
        'ip': ip,
        'address': address,
        'type': type.name,
      };
}
