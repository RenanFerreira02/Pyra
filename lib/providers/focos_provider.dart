import 'package:flutter/foundation.dart';
import '../models/foco.dart';
import '../utils/mock_data.dart';

enum FocosStatus { idle, loading, success, error }

class FocosProvider extends ChangeNotifier {
  List<Foco> _focos = [];
  FocosStatus _status = FocosStatus.idle;

  DateTime? _dataInicio;
  DateTime? _dataFim;
  String? _intensidadeFiltro;

  List<Foco> get focos => _focosFiltrados();
  List<Foco> get focosRaw => _focos;
  FocosStatus get status => _status;
  String get erro => '';
  DateTime? get dataInicio => _dataInicio;
  DateTime? get dataFim => _dataFim;
  String? get intensidadeFiltro => _intensidadeFiltro;

  void setFiltros({DateTime? dataInicio, DateTime? dataFim, String? intensidade}) {
    _dataInicio = dataInicio;
    _dataFim = dataFim;
    _intensidadeFiltro = intensidade;
    notifyListeners();
  }

  void limparFiltros() {
    _dataInicio = null;
    _dataFim = null;
    _intensidadeFiltro = null;
    notifyListeners();
  }

  List<Foco> _focosFiltrados() => _focos.where((f) {
        if (_dataInicio != null && f.dataHora.isBefore(_dataInicio!)) return false;
        if (_dataFim != null && f.dataHora.isAfter(_dataFim!)) return false;
        if (_intensidadeFiltro != null && f.intensidade != _intensidadeFiltro) return false;
        return true;
      }).toList();

  Future<void> carregarFocos() async {
    _status = FocosStatus.loading;
    notifyListeners();

    // Simula latência de rede para o demo parecer realista
    await Future.delayed(const Duration(milliseconds: 900));

    _focos = List.of(mockFocos);
    _status = FocosStatus.success;
    notifyListeners();
  }

  // ── Estatísticas para o dashboard ─────────────────────────────────────────

  Map<String, int> focosPorEstado() {
    final map = <String, int>{};
    for (final f in _focos) {
      if (f.estado != null) map[f.estado!] = (map[f.estado!] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> focosPorBioma() {
    final map = <String, int>{};
    for (final f in _focos) {
      if (f.bioma != null) map[f.bioma!] = (map[f.bioma!] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> focosPorDia({int dias = 7}) {
    final agora = DateTime.now();
    final map = <String, int>{};
    for (var i = dias - 1; i >= 0; i--) {
      final dia = agora.subtract(Duration(days: i));
      final chave = '${dia.day}/${dia.month}';
      map[chave] = _focos
          .where((f) =>
              f.dataHora.day == dia.day &&
              f.dataHora.month == dia.month &&
              f.dataHora.year == dia.year)
          .length;
    }
    return map;
  }
}
