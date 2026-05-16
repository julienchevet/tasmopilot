import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tasmopilot'**
  String get appTitle;

  /// No description provided for @sites.
  ///
  /// In fr, this message translates to:
  /// **'Sites'**
  String get sites;

  /// No description provided for @devices.
  ///
  /// In fr, this message translates to:
  /// **'Appareils'**
  String get devices;

  /// No description provided for @addSite.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un site'**
  String get addSite;

  /// No description provided for @editSite.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le site'**
  String get editSite;

  /// No description provided for @deleteSite.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le site ?'**
  String get deleteSite;

  /// No description provided for @deleteSiteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible et supprimera tous les appareils associés.'**
  String get deleteSiteConfirm;

  /// No description provided for @addDevice.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un appareil'**
  String get addDevice;

  /// No description provided for @editDevice.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'appareil'**
  String get editDevice;

  /// No description provided for @deleteDevice.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'appareil ?'**
  String get deleteDevice;

  /// No description provided for @deleteDeviceConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get deleteDeviceConfirm;

  /// No description provided for @name.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get name;

  /// No description provided for @ipAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse IP'**
  String get ipAddress;

  /// No description provided for @mqttTopic.
  ///
  /// In fr, this message translates to:
  /// **'MQTT Topic'**
  String get mqttTopic;

  /// No description provided for @mqttHost.
  ///
  /// In fr, this message translates to:
  /// **'Broker Host'**
  String get mqttHost;

  /// No description provided for @mqttPort.
  ///
  /// In fr, this message translates to:
  /// **'Port'**
  String get mqttPort;

  /// No description provided for @mqttUser.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get mqttUser;

  /// No description provided for @mqttPass.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get mqttPass;

  /// No description provided for @mqttPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Prefix Topic'**
  String get mqttPrefix;

  /// No description provided for @configureMqtt.
  ///
  /// In fr, this message translates to:
  /// **'Configurer MQTT'**
  String get configureMqtt;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @noSites.
  ///
  /// In fr, this message translates to:
  /// **'Aucun site configuré'**
  String get noSites;

  /// No description provided for @noDevices.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil sur ce site'**
  String get noDevices;

  /// No description provided for @scanNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Scanner le réseau'**
  String get scanNetwork;

  /// No description provided for @mqttStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut MQTT'**
  String get mqttStatus;

  /// No description provided for @liveDetails.
  ///
  /// In fr, this message translates to:
  /// **'DÉTAILS EN DIRECT'**
  String get liveDetails;

  /// No description provided for @wifiSsid.
  ///
  /// In fr, this message translates to:
  /// **'WiFi SSID'**
  String get wifiSsid;

  /// No description provided for @mqttBroker.
  ///
  /// In fr, this message translates to:
  /// **'MQTT Broker'**
  String get mqttBroker;

  /// No description provided for @rawData.
  ///
  /// In fr, this message translates to:
  /// **'Données brutes (JSON)'**
  String get rawData;

  /// No description provided for @powerOn.
  ///
  /// In fr, this message translates to:
  /// **'ALLUMÉ'**
  String get powerOn;

  /// No description provided for @powerOff.
  ///
  /// In fr, this message translates to:
  /// **'ÉTEINT'**
  String get powerOff;

  /// No description provided for @uptime.
  ///
  /// In fr, this message translates to:
  /// **'Uptime'**
  String get uptime;

  /// No description provided for @version.
  ///
  /// In fr, this message translates to:
  /// **'Firmware'**
  String get version;

  /// No description provided for @module.
  ///
  /// In fr, this message translates to:
  /// **'Module'**
  String get module;

  /// No description provided for @macAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse MAC'**
  String get macAddress;

  /// No description provided for @mqttDiscovery.
  ///
  /// In fr, this message translates to:
  /// **'Découverte MQTT'**
  String get mqttDiscovery;

  /// No description provided for @mqttDiscoveryDesc.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'annonces Tasmota sur le broker...'**
  String get mqttDiscoveryDesc;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @copyIp.
  ///
  /// In fr, this message translates to:
  /// **'Copier IP'**
  String get copyIp;

  /// No description provided for @ipCopied.
  ///
  /// In fr, this message translates to:
  /// **'IP copiée !'**
  String get ipCopied;

  /// No description provided for @openWeb.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir l\'interface Web'**
  String get openWeb;

  /// No description provided for @controls.
  ///
  /// In fr, this message translates to:
  /// **'CONTRÔLES'**
  String get controls;

  /// No description provided for @system.
  ///
  /// In fr, this message translates to:
  /// **'SYSTÈME'**
  String get system;

  /// No description provided for @network.
  ///
  /// In fr, this message translates to:
  /// **'RÉSEAU'**
  String get network;

  /// No description provided for @wifiSignal.
  ///
  /// In fr, this message translates to:
  /// **'Signal WiFi'**
  String get wifiSignal;

  /// No description provided for @deviceUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Appareil inaccessible'**
  String get deviceUnreachable;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @searchingSignal.
  ///
  /// In fr, this message translates to:
  /// **'Recherche du signal...'**
  String get searchingSignal;

  /// No description provided for @checkingConnection.
  ///
  /// In fr, this message translates to:
  /// **'Vérification de la connexion...'**
  String get checkingConnection;

  /// No description provided for @deviceSearch.
  ///
  /// In fr, this message translates to:
  /// **'Recherche d\'appareils'**
  String get deviceSearch;

  /// No description provided for @scanningNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Scan du sous-réseau en cours...'**
  String get scanningNetwork;

  /// No description provided for @noDevicesFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil Tasmota trouvé sur le réseau local.'**
  String get noDevicesFound;

  /// No description provided for @initializingScan.
  ///
  /// In fr, this message translates to:
  /// **'Initialisation du scan...'**
  String get initializingScan;

  /// No description provided for @rescan.
  ///
  /// In fr, this message translates to:
  /// **'Relancer le scan'**
  String get rescan;

  /// No description provided for @errorDeviceUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: Impossible de contacter l\'appareil'**
  String get errorDeviceUnreachable;

  /// No description provided for @channel.
  ///
  /// In fr, this message translates to:
  /// **'Canal'**
  String get channel;

  /// No description provided for @client.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @verifyingConnection.
  ///
  /// In fr, this message translates to:
  /// **'Vérification de la connexion...'**
  String get verifyingConnection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
