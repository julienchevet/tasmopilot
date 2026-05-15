class Device {
  final int? id;
  final int siteId;
  final String name;
  final String ipAddress;
  final String? macAddress;
  final DateTime createdAt;

  // Enriched and Configuration data
  final String? module;
  final String? version;
  final String? topic;
  final String? fullTopic;
  final String? mqttHost;
  final int? mqttPort;
  final String? mqttUser;
  final String? mqttPassword;
  final String? mqttClientId;
  final String? webPassword;
  final String? ssid1;
  final String? wifiPassword1;
  final String? ssid2;
  final String? wifiPassword2;
  final String? hostname;
  final String? groupTopic;
  final String? friendlyName1;
  final String? friendlyName2;
  final int? rssi;
  final String? uptime;
  final String? powerState; // Comma separated states like "ON,OFF"

  const Device({
    this.id,
    required this.siteId,
    required this.name,
    required this.ipAddress,
    this.macAddress,
    required this.createdAt,
    this.module,
    this.version,
    this.topic,
    this.fullTopic,
    this.mqttHost,
    this.mqttPort,
    this.mqttUser,
    this.mqttPassword,
    this.mqttClientId,
    this.webPassword,
    this.ssid1,
    this.wifiPassword1,
    this.ssid2,
    this.wifiPassword2,
    this.hostname,
    this.groupTopic,
    this.friendlyName1,
    this.friendlyName2,
    this.rssi,
    this.uptime,
    this.powerState,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'site_id': siteId,
      'name': name,
      'ip_address': ipAddress,
      'mac_address': macAddress,
      'created_at': createdAt.toIso8601String(),
      'module': module,
      'version': version,
      'topic': topic,
      'full_topic': fullTopic,
      'mqtt_host': mqttHost,
      'mqtt_port': mqttPort,
      'mqtt_user': mqttUser,
      'mqtt_password': mqttPassword,
      'mqtt_client_id': mqttClientId,
      'web_password': webPassword,
      'ssid1': ssid1,
      'wifi_password1': wifiPassword1,
      'ssid2': ssid2,
      'wifi_password2': wifiPassword2,
      'hostname': hostname,
      'group_topic': groupTopic,
      'friendly_name1': friendlyName1,
      'friendly_name2': friendlyName2,
      'rssi': rssi,
      'uptime': uptime,
      'power_state': powerState,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] as int?,
      siteId: map['site_id'] as int,
      name: map['name'] as String,
      ipAddress: map['ip_address'] as String,
      macAddress: map['mac_address'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      module: map['module'] as String?,
      version: map['version'] as String?,
      topic: map['topic'] as String?,
      fullTopic: map['full_topic'] as String?,
      mqttHost: map['mqtt_host'] as String?,
      mqttPort: map['mqtt_port'] as int?,
      mqttUser: map['mqtt_user'] as String?,
      mqttPassword: map['mqtt_password'] as String?,
      mqttClientId: map['mqtt_client_id'] as String?,
      webPassword: map['web_password'] as String?,
      ssid1: map['ssid1'] as String?,
      wifiPassword1: map['wifi_password1'] as String?,
      ssid2: map['ssid2'] as String?,
      wifiPassword2: map['wifi_password2'] as String?,
      hostname: map['hostname'] as String?,
      groupTopic: map['group_topic'] as String?,
      friendlyName1: map['friendly_name1'] as String?,
      friendlyName2: map['friendly_name2'] as String?,
      rssi: map['rssi'] as int?,
      uptime: map['uptime'] as String?,
      powerState: map['power_state'] as String?,
    );
  }

  Device copyWith({
    int? id,
    int? siteId,
    String? name,
    String? ipAddress,
    String? macAddress,
    DateTime? createdAt,
    String? module,
    String? version,
    String? topic,
    String? fullTopic,
    String? mqttHost,
    int? mqttPort,
    String? mqttUser,
    String? mqttPassword,
    String? mqttClientId,
    String? webPassword,
    String? ssid1,
    String? wifiPassword1,
    String? ssid2,
    String? wifiPassword2,
    String? hostname,
    String? groupTopic,
    String? friendlyName1,
    String? friendlyName2,
    int? rssi,
    String? uptime,
    String? powerState,
  }) {
    return Device(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      createdAt: createdAt ?? this.createdAt,
      module: module ?? this.module,
      version: version ?? this.version,
      topic: topic ?? this.topic,
      fullTopic: fullTopic ?? this.fullTopic,
      mqttHost: mqttHost ?? this.mqttHost,
      mqttPort: mqttPort ?? this.mqttPort,
      mqttUser: mqttUser ?? this.mqttUser,
      mqttPassword: mqttPassword ?? this.mqttPassword,
      mqttClientId: mqttClientId ?? this.mqttClientId,
      webPassword: webPassword ?? this.webPassword,
      ssid1: ssid1 ?? this.ssid1,
      wifiPassword1: wifiPassword1 ?? this.wifiPassword1,
      ssid2: ssid2 ?? this.ssid2,
      wifiPassword2: wifiPassword2 ?? this.wifiPassword2,
      hostname: hostname ?? this.hostname,
      groupTopic: groupTopic ?? this.groupTopic,
      friendlyName1: friendlyName1 ?? this.friendlyName1,
      friendlyName2: friendlyName2 ?? this.friendlyName2,
      rssi: rssi ?? this.rssi,
      uptime: uptime ?? this.uptime,
      powerState: powerState ?? this.powerState,
    );
  }
}
