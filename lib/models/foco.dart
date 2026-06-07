class Foco {
  final String id;
  final double latitude;
  final double longitude;
  final double frp;        // Fire Radiative Power (MW) — intensidade
  final double brightness; // Brilho (Kelvin)
  final DateTime dataHora;
  final String satelite;
  final String? municipio;
  final String? estado;
  final String? bioma;

  const Foco({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.frp,
    required this.brightness,
    required this.dataHora,
    required this.satelite,
    this.municipio,
    this.estado,
    this.bioma,
  });

  /// Classifica a intensidade com base no FRP.
  String get intensidade {
    if (frp >= 100) return 'Alta';
    if (frp >= 30) return 'Média';
    return 'Baixa';
  }
}
