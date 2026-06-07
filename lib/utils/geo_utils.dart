import 'dart:math';

/// Cálculos geográficos sem dependência externa.
class GeoUtils {
  static const double _earthRadiusKm = 6371.0;

  /// Haversine — distância em km entre dois pontos (lat/lon em graus).
  static double distanciaKm(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _toRad(double deg) => deg * pi / 180;
}
