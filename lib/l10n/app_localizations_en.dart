// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tasmopilot';

  @override
  String get sites => 'Sites';

  @override
  String get devices => 'Devices';

  @override
  String get addSite => 'Add Site';

  @override
  String get editSite => 'Edit Site';

  @override
  String get deleteSite => 'Delete Site?';

  @override
  String get deleteSiteConfirm =>
      'This action is irreversible and will delete all associated devices.';

  @override
  String get addDevice => 'Add Device';

  @override
  String get editDevice => 'Edit Device';

  @override
  String get deleteDevice => 'Delete Device?';

  @override
  String get deleteDeviceConfirm => 'This action is irreversible.';

  @override
  String get name => 'Name';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get mqttTopic => 'MQTT Topic';

  @override
  String get mqttHost => 'Broker Host';

  @override
  String get mqttPort => 'Port';

  @override
  String get mqttUser => 'Username';

  @override
  String get mqttPass => 'Password';

  @override
  String get mqttPrefix => 'Topic Prefix';

  @override
  String get configureMqtt => 'Configure MQTT';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get noSites => 'No sites configured';

  @override
  String get noDevices => 'No devices on this site';

  @override
  String get scanNetwork => 'Scan Network';

  @override
  String get mqttStatus => 'MQTT Status';

  @override
  String get liveDetails => 'LIVE DETAILS';

  @override
  String get wifiSsid => 'WiFi SSID';

  @override
  String get mqttBroker => 'MQTT Broker';

  @override
  String get rawData => 'Raw Data (JSON)';

  @override
  String get powerOn => 'ON';

  @override
  String get powerOff => 'OFF';

  @override
  String get uptime => 'Uptime';

  @override
  String get version => 'Firmware';

  @override
  String get module => 'Module';

  @override
  String get macAddress => 'MAC Address';

  @override
  String get mqttDiscovery => 'MQTT Discovery';

  @override
  String get mqttDiscoveryDesc =>
      'Waiting for Tasmota announcements on the broker...';

  @override
  String get close => 'Close';

  @override
  String get copyIp => 'Copy IP';

  @override
  String get ipCopied => 'IP Copied!';

  @override
  String get openWeb => 'Open Web Interface';

  @override
  String get controls => 'CONTROLS';

  @override
  String get system => 'SYSTEM';

  @override
  String get network => 'NETWORK';

  @override
  String get wifiSignal => 'WiFi Signal';

  @override
  String get deviceUnreachable => 'Device Unreachable';

  @override
  String get retry => 'Retry';

  @override
  String get searchingSignal => 'Searching for signal...';

  @override
  String get checkingConnection => 'Checking connection...';

  @override
  String get deviceSearch => 'Searching for devices';

  @override
  String get scanningNetwork => 'Scanning subnet...';

  @override
  String get noDevicesFound => 'No Tasmota devices found on local network.';

  @override
  String get initializingScan => 'Initializing scan...';

  @override
  String get rescan => 'Rescan';

  @override
  String get errorDeviceUnreachable =>
      'Error: Impossible to contact the device';

  @override
  String get channel => 'Channel';

  @override
  String get client => 'Client';

  @override
  String get verifyingConnection => 'Verifying connection...';
}
