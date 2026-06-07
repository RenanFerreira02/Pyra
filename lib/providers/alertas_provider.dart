import 'package:flutter/foundation.dart';
import '../models/alerta.dart';
import '../models/foco.dart';
import '../models/regiao.dart';
import '../services/storage_service.dart';
import '../utils/geo_utils.dart';

class AlertasProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Alerta> _alertas = [];

  AlertasProvider({required StorageService storage}) : _storage = storage {
    _carregar();
  }

  List<Alerta> get alertas => List.unmodifiable(_alertas);
  int get naoLidos => _alertas.where((a) => !a.lido).length;

  Future<void> _carregar() async {
    _alertas = await _storage.carregarAlertas();
    notifyListeners();
  }

  /// Cruza focos com regiões e persiste novos alertas.
  Future<void> verificarProximidade(List<Foco> focos, List<Regiao> regioes) async {
    final idsExistentes = _alertas.map((a) => a.id).toSet();
    var mudou = false;

    for (final regiao in regioes) {
      for (final foco in focos) {
        final alertaId = '${foco.id}_${regiao.id}';
        if (idsExistentes.contains(alertaId)) continue;

        final dist = GeoUtils.distanciaKm(
          regiao.latitude, regiao.longitude,
          foco.latitude, foco.longitude,
        );

        if (dist <= regiao.raioKm) {
          _alertas.add(Alerta(
            id: alertaId,
            regiaoId: regiao.id,
            regiaoNome: regiao.nome,
            focoId: foco.id,
            distanciaKm: dist,
            geradoEm: foco.dataHora,
          ));
          mudou = true;
        }
      }
    }

    if (mudou) {
      _alertas.sort((a, b) => b.geradoEm.compareTo(a.geradoEm));
      await _storage.salvarAlertas(_alertas);
      notifyListeners();
    }
  }

  Future<void> marcarLido(String alertaId) async {
    final idx = _alertas.indexWhere((a) => a.id == alertaId);
    if (idx >= 0) {
      _alertas[idx] = _alertas[idx].copyWith(lido: true);
      await _storage.salvarAlertas(_alertas);
      notifyListeners();
    }
  }

  Future<void> marcarTodosLidos() async {
    var mudou = false;
    for (var i = 0; i < _alertas.length; i++) {
      if (!_alertas[i].lido) {
        _alertas[i] = _alertas[i].copyWith(lido: true);
        mudou = true;
      }
    }
    if (mudou) {
      await _storage.salvarAlertas(_alertas);
      notifyListeners();
    }
  }
}
