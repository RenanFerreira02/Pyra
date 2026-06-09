import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Abstrai permissões e obtenção de posição do dispositivo.
class LocationService {
  /// Solicita permissão e retorna a posição atual.
  /// Lança [LocationException] se o serviço estiver desativado ou a permissão for negada.
  Future<Position> obterPosicaoAtual() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Serviço de localização desativado.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException('Permissão de localização negada.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException('Permissão de localização negada permanentemente.');
    }

    // Tenta a última posição conhecida como fallback rápido
    final lastKnown = await Geolocator.getLastKnownPosition();

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 30),
        ),
      );
    } on TimeoutException {
      if (lastKnown != null) return lastKnown;
      throw const LocationException(
        'Não foi possível obter a localização. Verifique o GPS e tente novamente.',
      );
    }
  }
}

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);
  @override
  String toString() => 'LocationException: $message';
}
