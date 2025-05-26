import 'device_type.dart';

class DeviceModel {
  final String id;
  final String name;
  final String connection;
  final DeviceType type;

  DeviceModel({
    required this.id,
    required this.name,
    required this.connection,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'connection': connection,
        'type': type.index,
      };

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      name: json['name'],
      connection: json['connection'],
      type: DeviceType.values[json['type']],
    );
  }
}
