// services/network_connectivity_service.dart
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkConnectivityService extends ChangeNotifier {
  static final NetworkConnectivityService _instance =
      NetworkConnectivityService._internal();
  factory NetworkConnectivityService() => _instance;
  NetworkConnectivityService._internal();

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  // Pour stocker le type de connexion actuel
  ConnectivityResult _connectionType = ConnectivityResult.none;
  ConnectivityResult get connectionType => _connectionType;

  final Connectivity _connectivity = Connectivity();

  void init() {
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(dynamic result) async {
    final ConnectivityResult connectionResult;
    if (result is List<ConnectivityResult>) {
      connectionResult = result.isNotEmpty
          ? result.first
          : ConnectivityResult.none;
    } else if (result is ConnectivityResult) {
      connectionResult = result;
    } else {
      connectionResult = ConnectivityResult.none;
    }

    _connectionType = connectionResult;

    // Vérifier si au moins une connexion est disponible
    bool hasConnection = result != ConnectivityResult.none;

    if (hasConnection) {
      // Vérifier la connexion internet réelle avec un timeout
      try {
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 5));
        debugPrint('Résultat de la vérification Internet : $result');
        hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        hasConnection = false;
      } on TimeoutException catch (_) {
        hasConnection = false;
      }
    }

    final previousState = _isConnected;
    _isConnected = hasConnection;

    if (previousState != _isConnected) {
      notifyListeners();

      if (_isConnected) {
        // Déclencher la synchronisation quand la connexion revient
        _triggerSync();
      }
    }
  }

  void _triggerSync() {
    // Émettre un événement pour déclencher la synchronisation
    print('Connexion rétablie - déclenchement synchronisation');
  }

  // Méthode utilitaire pour obtenir un message convivial du type de connexion
  String getConnectionTypeMessage() {
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Réseau mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Autre';
      case ConnectivityResult.none:
        return 'Aucune';
      default:
        return 'Inconnu';
    }
  }

  // Méthode pour forcer une vérification manuelle de la connexion
  Future<bool> checkConnectionManually() async {
    await _checkConnection();
    return _isConnected;
  }
}
