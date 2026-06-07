import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alerta.dart';
import '../models/regiao.dart';
import '../utils/mock_data.dart';

/// Persistência local via SharedPreferences — substitui o Firestore no MVP demo.
class StorageService {
  static const _keyRegioes = 'regioes_v1';
  static const _keyAlertas = 'alertas_v1';

  // ── Regiões ───────────────────────────────────────────────────────────────

  Future<List<Regiao>> carregarRegioes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyRegioes);
    if (raw == null) return List.of(regioesPadrao); // primeiro uso: demo pronto
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Regiao.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> salvarRegioes(List<Regiao> regioes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyRegioes,
      jsonEncode(regioes.map((r) => r.toJson()).toList()),
    );
  }

  // ── Alertas ───────────────────────────────────────────────────────────────

  Future<List<Alerta>> carregarAlertas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAlertas);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Alerta.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> salvarAlertas(List<Alerta> alertas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyAlertas,
      jsonEncode(alertas.map((a) => a.toJson()).toList()),
    );
  }
}
