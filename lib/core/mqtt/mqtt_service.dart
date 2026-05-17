import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../../features/sites/models/site.dart';

enum TasmotaMqttStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class TasmotaMqttService {
  MqttServerClient? _client;
  final _statusController = StreamController<TasmotaMqttStatus>.broadcast();
  final _messageController = StreamController<MqttReceivedMessage<MqttMessage>>.broadcast();
  
  Stream<TasmotaMqttStatus> get statusStream => _statusController.stream;
  Stream<MqttReceivedMessage<MqttMessage>> get messageStream => _messageController.stream;
  
  TasmotaMqttStatus _currentState = TasmotaMqttStatus.disconnected;
  TasmotaMqttStatus get currentState => _currentState;

  Future<bool> connect(Site site) async {
    if (site.mqttHost == null || site.mqttHost!.isEmpty) return false;

    _updateState(TasmotaMqttStatus.connecting);

    final clientIdentifier = 'tasmopilot_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient(site.mqttHost!, clientIdentifier);
    _client!.port = site.mqttPort ?? 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.logging(on: false);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect(site.mqttUsername, site.mqttPassword);
    } catch (e) {
      _updateState(TasmotaMqttStatus.error);
      _client!.disconnect();
      return false;
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      return true;
    } else {
      _updateState(TasmotaMqttStatus.error);
      _client!.disconnect();
      return false;
    }
  }

  void disconnect() {
    _client?.disconnect();
    _updateState(TasmotaMqttStatus.disconnected);
  }

  void _onConnected() {
    _updateState(TasmotaMqttStatus.connected);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      for (var message in c) {
        _messageController.add(message);
      }
    });
  }

  void _onDisconnected() {
    _updateState(TasmotaMqttStatus.disconnected);
  }

  void _updateState(TasmotaMqttStatus state) {
    _currentState = state;
    _statusController.add(state);
  }

  void subscribe(String topic) {
    if (_currentState == TasmotaMqttStatus.connected) {
      _client!.subscribe(topic, MqttQos.atMostOnce);
    }
  }

  void publish(String topic, String message) {
    if (_currentState == TasmotaMqttStatus.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    }
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _messageController.close();
  }
}
