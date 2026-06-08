import '../models/foco.dart';
import '../models/regiao.dart';

// CAMADA DE DADOS — MVP com dados de exemplo.
// Todos os focos abaixo são fictícios e servem apenas para demonstração.
// Para integração real, substitua mockFocos pelo retorno de FirmsService
// (NASA FIRMS) e/ou InpeService (INPE BDQueimadas) sem alterar providers
// nem telas — a interface List<Foco> permanece a mesma.
final List<Foco> mockFocos = [
  // ── Hoje ────────────────────────────────────────────────────────────────
  Foco(id: 'f01', latitude: -9.52,  longitude: -48.21, frp: 145, brightness: 345, dataHora: _diasAtras(0, h: 2),  satelite: 'VIIRS',  estado: 'TO', bioma: 'Cerrado'),
  Foco(id: 'f02', latitude: -3.82,  longitude: -52.14, frp: 210, brightness: 382, dataHora: _diasAtras(0, h: 4),  satelite: 'VIIRS',  estado: 'PA', bioma: 'Amazônia'),
  Foco(id: 'f03', latitude: -8.21,  longitude: -63.41, frp: 88,  brightness: 326, dataHora: _diasAtras(0, h: 6),  satelite: 'AQUA',   estado: 'AM', bioma: 'Amazônia'),
  Foco(id: 'f04', latitude: -15.48, longitude: -47.91, frp: 12,  brightness: 291, dataHora: _diasAtras(0, h: 8),  satelite: 'TERRA',  estado: 'GO', bioma: 'Cerrado'),

  // ── Ontem ────────────────────────────────────────────────────────────────
  Foco(id: 'f05', latitude: -10.93, longitude: -55.51, frp: 175, brightness: 362, dataHora: _diasAtras(1, h: 1),  satelite: 'VIIRS',  estado: 'MT', bioma: 'Amazônia'),
  Foco(id: 'f06', latitude: -12.14, longitude: -50.31, frp: 52,  brightness: 317, dataHora: _diasAtras(1, h: 5),  satelite: 'AQUA',   estado: 'MT', bioma: 'Cerrado'),
  Foco(id: 'f07', latitude: -6.11,  longitude: -44.32, frp: 28,  brightness: 305, dataHora: _diasAtras(1, h: 9),  satelite: 'TERRA',  estado: 'MA', bioma: 'Cerrado'),
  Foco(id: 'f08', latitude: -4.25,  longitude: -56.80, frp: 130, brightness: 348, dataHora: _diasAtras(1, h: 12), satelite: 'VIIRS',  estado: 'PA', bioma: 'Amazônia'),
  Foco(id: 'f09', latitude: -17.90, longitude: -54.80, frp: 95,  brightness: 332, dataHora: _diasAtras(1, h: 15), satelite: 'AQUA',   estado: 'MS', bioma: 'Pantanal'),
  Foco(id: 'f10', latitude: -2.51,  longitude: -61.23, frp: 190, brightness: 371, dataHora: _diasAtras(1, h: 18), satelite: 'VIIRS',  estado: 'AM', bioma: 'Amazônia'),

  // ── 2 dias atrás ─────────────────────────────────────────────────────────
  Foco(id: 'f11', latitude: -8.76,  longitude: -70.11, frp: 65,  brightness: 321, dataHora: _diasAtras(2, h: 3),  satelite: 'TERRA',  estado: 'AC', bioma: 'Amazônia'),
  Foco(id: 'f12', latitude: -13.02, longitude: -43.81, frp: 22,  brightness: 298, dataHora: _diasAtras(2, h: 10), satelite: 'AQUA',   estado: 'BA', bioma: 'Caatinga'),
  Foco(id: 'f13', latitude: -16.32, longitude: -49.01, frp: 110, brightness: 340, dataHora: _diasAtras(2, h: 16), satelite: 'VIIRS',  estado: 'GO', bioma: 'Cerrado'),

  // ── 3 dias atrás ─────────────────────────────────────────────────────────
  Foco(id: 'f14', latitude: -11.45, longitude: -61.81, frp: 155, brightness: 356, dataHora: _diasAtras(3, h: 2),  satelite: 'VIIRS',  estado: 'RO', bioma: 'Amazônia'),
  Foco(id: 'f15', latitude: -9.10,  longitude: -40.50, frp: 8,   brightness: 283, dataHora: _diasAtras(3, h: 7),  satelite: 'TERRA',  estado: 'PE', bioma: 'Caatinga'),
  Foco(id: 'f16', latitude: -14.91, longitude: -40.11, frp: 35,  brightness: 309, dataHora: _diasAtras(3, h: 13), satelite: 'AQUA',   estado: 'BA', bioma: 'Mata Atlântica'),
  Foco(id: 'f17', latitude: -3.10,  longitude: -59.92, frp: 220, brightness: 388, dataHora: _diasAtras(3, h: 19), satelite: 'VIIRS',  estado: 'AM', bioma: 'Amazônia'),
  Foco(id: 'f18', latitude: -19.55, longitude: -56.02, frp: 72,  brightness: 323, dataHora: _diasAtras(3, h: 22), satelite: 'AQUA',   estado: 'MS', bioma: 'Pantanal'),

  // ── 4 dias atrás ─────────────────────────────────────────────────────────
  Foco(id: 'f19', latitude: -5.81,  longitude: -35.21, frp: 18,  brightness: 293, dataHora: _diasAtras(4, h: 6),  satelite: 'TERRA',  estado: 'RN', bioma: 'Caatinga'),
  Foco(id: 'f20', latitude: -1.45,  longitude: -48.45, frp: 100, brightness: 337, dataHora: _diasAtras(4, h: 11), satelite: 'VIIRS',  estado: 'PA', bioma: 'Amazônia'),

  // ── 5 dias atrás ─────────────────────────────────────────────────────────
  Foco(id: 'f21', latitude: -15.01, longitude: -59.90, frp: 130, brightness: 349, dataHora: _diasAtras(5, h: 3),  satelite: 'VIIRS',  estado: 'MT', bioma: 'Amazônia'),
  Foco(id: 'f22', latitude: -7.21,  longitude: -47.51, frp: 45,  brightness: 313, dataHora: _diasAtras(5, h: 8),  satelite: 'AQUA',   estado: 'TO', bioma: 'Cerrado'),
  Foco(id: 'f23', latitude: -22.91, longitude: -43.18, frp: 5,   brightness: 281, dataHora: _diasAtras(5, h: 14), satelite: 'TERRA',  estado: 'RJ', bioma: 'Mata Atlântica'),
  Foco(id: 'f24', latitude: -6.01,  longitude: -67.10, frp: 160, brightness: 358, dataHora: _diasAtras(5, h: 20), satelite: 'VIIRS',  estado: 'AM', bioma: 'Amazônia'),

  // ── 6 dias atrás ─────────────────────────────────────────────────────────
  Foco(id: 'f25', latitude: -12.63, longitude: -38.01, frp: 30,  brightness: 304, dataHora: _diasAtras(6, h: 5),  satelite: 'TERRA',  estado: 'BA', bioma: 'Caatinga'),
  Foco(id: 'f26', latitude: -2.91,  longitude: -45.82, frp: 80,  brightness: 328, dataHora: _diasAtras(6, h: 10), satelite: 'AQUA',   estado: 'MA', bioma: 'Amazônia'),
  Foco(id: 'f27', latitude: -10.01, longitude: -67.82, frp: 195, brightness: 376, dataHora: _diasAtras(6, h: 16), satelite: 'VIIRS',  estado: 'AC', bioma: 'Amazônia'),
];

/// Regiões pré-cadastradas para o demo (salvas como padrão no primeiro uso).
final List<Regiao> regioesPadrao = [
  Regiao(id: 'demo_r1', nome: 'Brasília', latitude: -15.7975, longitude: -47.8919, raioKm: 200, criadaEm: DateTime.now()),
  Regiao(id: 'demo_r2', nome: 'Belém',    latitude: -1.4558,  longitude: -48.5044, raioKm: 150, criadaEm: DateTime.now()),
  Regiao(id: 'demo_r3', nome: 'Manaus',   latitude: -3.1190,  longitude: -60.0217, raioKm: 100, criadaEm: DateTime.now()),
];

DateTime _diasAtras(int dias, {int h = 0}) =>
    DateTime.now().subtract(Duration(days: dias, hours: h));
