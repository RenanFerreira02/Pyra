class Regiao {
  final String id;
  final String nome;
  final double latitude;
  final double longitude;
  final double raioKm;
  final DateTime criadaEm;

  const Regiao({
    required this.id,
    required this.nome,
    required this.latitude,
    required this.longitude,
    required this.raioKm,
    required this.criadaEm,
  });

  factory Regiao.fromJson(Map<String, dynamic> json) => Regiao(
        id: json['id'] as String,
        nome: json['nome'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        raioKm: (json['raioKm'] as num?)?.toDouble() ?? 50.0,
        criadaEm: json['criadaEm'] != null
            ? DateTime.parse(json['criadaEm'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'latitude': latitude,
        'longitude': longitude,
        'raioKm': raioKm,
        'criadaEm': criadaEm.toIso8601String(),
      };

  Regiao copyWith({
    String? nome,
    double? latitude,
    double? longitude,
    double? raioKm,
  }) =>
      Regiao(
        id: id,
        nome: nome ?? this.nome,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        raioKm: raioKm ?? this.raioKm,
        criadaEm: criadaEm,
      );
}
