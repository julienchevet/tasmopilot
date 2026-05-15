class DiscoveredDevice {
  final String ipAddress;
  final String hostname;
  final String? macAddress;
  
  // Enriched fields
  final String? module;
  final String? version;
  final String? topic;
  final List<String>? friendlyNames;
  final int? rssi;
  final String? uptime;
  final String? powerState;

  DiscoveredDevice({
    required this.ipAddress,
    required this.hostname,
    this.macAddress,
    this.module,
    this.version,
    this.topic,
    this.friendlyNames,
    this.rssi,
    this.uptime,
    this.powerState,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredDevice &&
          runtimeType == other.runtimeType &&
          ipAddress == other.ipAddress &&
          hostname == other.hostname;

  @override
  int get hashCode => Object.hash(ipAddress, hostname);
}
