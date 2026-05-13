class Device {
  final int? id;
  final int siteId;
  final String name;
  final String ipAddress;
  final String? macAddress;
  final DateTime createdAt;

  const Device({
    this.id,
    required this.siteId,
    required this.name,
    required this.ipAddress,
    this.macAddress,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'site_id': siteId,
      'name': name,
      'ip_address': ipAddress,
      'mac_address': macAddress,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] as int,
      siteId: map['site_id'] as int,
      name: map['name'] as String,
      ipAddress: map['ip_address'] as String,
      macAddress: map['mac_address'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Device copyWith({
    int? id,
    int? siteId,
    String? name,
    String? ipAddress,
    String? macAddress,
    DateTime? createdAt,
  }) {
    return Device(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
