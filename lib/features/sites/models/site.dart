class Site {
  final int? id;
  final String name;
  final DateTime createdAt;
  
  // MQTT settings
  final String? mqttHost;
  final int? mqttPort;
  final String? mqttUsername;
  final String? mqttPassword;
  final String? mqttTopicPrefix;

  const Site({
    this.id,
    required this.name,
    required this.createdAt,
    this.mqttHost,
    this.mqttPort,
    this.mqttUsername,
    this.mqttPassword,
    this.mqttTopicPrefix,
  });

  // Convert a Site into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'mqtt_host': mqttHost,
      'mqtt_port': mqttPort,
      'mqtt_username': mqttUsername,
      'mqtt_password': mqttPassword,
      'mqtt_topic_prefix': mqttTopicPrefix,
    };
  }

  // Convert a Map into a Site.
  factory Site.fromMap(Map<String, dynamic> map) {
    return Site(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      mqttHost: map['mqtt_host'] as String?,
      mqttPort: map['mqtt_port'] as int?,
      mqttUsername: map['mqtt_username'] as String?,
      mqttPassword: map['mqtt_password'] as String?,
      mqttTopicPrefix: map['mqtt_topic_prefix'] as String?,
    );
  }

  Site copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    String? mqttHost,
    int? mqttPort,
    String? mqttUsername,
    String? mqttPassword,
    String? mqttTopicPrefix,
  }) {
    return Site(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      mqttHost: mqttHost ?? this.mqttHost,
      mqttPort: mqttPort ?? this.mqttPort,
      mqttUsername: mqttUsername ?? this.mqttUsername,
      mqttPassword: mqttPassword ?? this.mqttPassword,
      mqttTopicPrefix: mqttTopicPrefix ?? this.mqttTopicPrefix,
    );
  }
}
