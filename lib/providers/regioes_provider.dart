import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/regiao.dart';
import '../services/storage_service.dart';

class RegioesProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Regiao> _regioes = [];
  bool _carregando = false;
  final Completer<void> _inicializado = Completer();

  RegioesProvider({required StorageService storage}) : _storage = storage {
    _carregar();
  }

  List<Regiao> get regioes => List.unmodifiable(_regioes);
  bool get carregando => _carregando;

  /// Future que completa quando o carregamento inicial do storage termina.
  Future<void> get pronto => _inicializado.future;

  Future<void> _carregar() async {
    _regioes = await _storage.carregarRegioes();
    if (!_inicializado.isCompleted) _inicializado.complete();
    notifyListeners();
  }

  Future<void> adicionarRegiao({
    required String nome,
    required double latitude,
    required double longitude,
    double raioKm = 50.0,
  }) async {
    _carregando = true;
    notifyListeners();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _regioes.add(Regiao(
      id: id,
      nome: nome,
      latitude: latitude,
      longitude: longitude,
      raioKm: raioKm,
      criadaEm: DateTime.now(),
    ));
    await _storage.salvarRegioes(_regioes);
    _carregando = false;
    notifyListeners();
  }

  Future<void> atualizarRegiao(Regiao regiao) async {
    final idx = _regioes.indexWhere((r) => r.id == regiao.id);
    if (idx >= 0) {
      _regioes[idx] = regiao;
      await _storage.salvarRegioes(_regioes);
      notifyListeners();
    }
  }

  Future<void> excluirRegiao(String id) async {
    _regioes.removeWhere((r) => r.id == id);
    await _storage.salvarRegioes(_regioes);
    notifyListeners();
  }
}
