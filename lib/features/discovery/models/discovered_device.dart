class DiscoveredDevice {
  final String ipAddress;
  final String hostname;
  final String? macAddress; // Sometimes available via mDNS TXT records

  DiscoveredDevice({
    required this.ipAddress,
    required this.hostname,
    this.macAddress,
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
