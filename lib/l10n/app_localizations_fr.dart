// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Tasmopilot';

  @override
  String get sites => 'Sites';

  @override
  String get devices => 'Appareils';

  @override
  String get addSite => 'Ajouter un site';

  @override
  String get editSite => 'Modifier le site';

  @override
  String get deleteSite => 'Supprimer le site ?';

  @override
  String get deleteSiteConfirm =>
      'Cette action est irréversible et supprimera tous les appareils associés.';

  @override
  String get addDevice => 'Ajouter un appareil';

  @override
  String get editDevice => 'Modifier l\'appareil';

  @override
  String get deleteDevice => 'Supprimer l\'appareil ?';

  @override
  String get deleteDeviceConfirm => 'Cette action est irréversible.';

  @override
  String get name => 'Nom';

  @override
  String get ipAddress => 'Adresse IP';

  @override
  String get mqttTopic => 'MQTT Topic';

  @override
  String get mqttHost => 'Broker Host';

  @override
  String get mqttPort => 'Port';

  @override
  String get mqttUser => 'Utilisateur';

  @override
  String get mqttPass => 'Mot de passe';

  @override
  String get mqttPrefix => 'Prefix Topic';

  @override
  String get configureMqtt => 'Configurer MQTT';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get add => 'Ajouter';

  @override
  String get delete => 'Supprimer';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get noSites => 'Aucun site configuré';

  @override
  String get noDevices => 'Aucun appareil sur ce site';

  @override
  String get scanNetwork => 'Scanner le réseau';

  @override
  String get mqttStatus => 'Statut MQTT';

  @override
  String get liveDetails => 'DÉTAILS EN DIRECT';

  @override
  String get wifiSsid => 'WiFi SSID';

  @override
  String get mqttBroker => 'MQTT Broker';

  @override
  String get rawData => 'Données brutes (JSON)';

  @override
  String get powerOn => 'ALLUMÉ';

  @override
  String get powerOff => 'ÉTEINT';

  @override
  String get uptime => 'Uptime';

  @override
  String get version => 'Firmware';

  @override
  String get module => 'Module';

  @override
  String get macAddress => 'Adresse MAC';

  @override
  String get mqttDiscovery => 'Découverte MQTT';

  @override
  String get mqttDiscoveryDesc =>
      'En attente d\'annonces Tasmota sur le broker...';

  @override
  String get close => 'Fermer';

  @override
  String get copyIp => 'Copier IP';

  @override
  String get ipCopied => 'IP copiée !';

  @override
  String get openWeb => 'Ouvrir l\'interface Web';

  @override
  String get controls => 'CONTRÔLES';

  @override
  String get system => 'SYSTÈME';

  @override
  String get network => 'RÉSEAU';

  @override
  String get wifiSignal => 'Signal WiFi';

  @override
  String get deviceUnreachable => 'Appareil inaccessible';

  @override
  String get retry => 'Réessayer';

  @override
  String get searchingSignal => 'Recherche du signal...';

  @override
  String get checkingConnection => 'Vérification de la connexion...';

  @override
  String get deviceSearch => 'Recherche d\'appareils';

  @override
  String get scanningNetwork => 'Scan du sous-réseau en cours...';

  @override
  String get noDevicesFound =>
      'Aucun appareil Tasmota trouvé sur le réseau local.';

  @override
  String get initializingScan => 'Initialisation du scan...';

  @override
  String get rescan => 'Relancer le scan';

  @override
  String get errorDeviceUnreachable =>
      'Erreur: Impossible de contacter l\'appareil';

  @override
  String get channel => 'Canal';

  @override
  String get client => 'Client';

  @override
  String get verifyingConnection => 'Vérification de la connexion...';
}
