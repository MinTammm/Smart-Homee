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
        return DeviceType.curtain; // default fallback
    }
  }
}

class Device {
  final String id;
  final String name;
  final String connection; // 'IP' or 'BLE'
  final String address;    // IP address or BLE MAC/id
  final DeviceType type;

  Device({
    required this.id,
    required this.name,
    required this.connection,
    required this.address,
    required this.type,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'],
        name: json['name'],
        connection: json['connection'],
        address: json['address'],
        type: DeviceTypeExtension.fromString(json['type']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'connection': connection,
        'address': address,
        'type': type.name,
      };
}
