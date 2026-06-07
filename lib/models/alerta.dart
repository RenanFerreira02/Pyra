/// Alerta gerado quando um foco está dentro do raio de uma região monitorada.
class Alerta {
  final String id;
  final String regiaoId;
  final String regiaoNome;
  final String focoId;
  final double distanciaKm;
  final DateTime geradoEm;
  final bool lido;

  const Alerta({
    required this.id,
    required this.regiaoId,
    required this.regiaoNome,
    required this.focoId,
    required this.distanciaKm,
    required this.geradoEm,
    this.lido = false,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) => Alerta(
        id: json['id'] as String,
        regiaoId: json['regiaoId'] as String,
        regiaoNome: json['regiaoNome'] as String,
        focoId: json['focoId'] as String,
        distanciaKm: (json['distanciaKm'] as num).toDouble(),
        geradoEm: DateTime.parse(json['geradoEm'] as String),
        lido: json['lido'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'regiaoId': regiaoId,
        'regiaoNome': regiaoNome,
        'focoId': focoId,
        'distanciaKm': distanciaKm,
        'geradoEm': geradoEm.toIso8601String(),
        'lido': lido,
      };

  Alerta copyWith({bool? lido}) => Alerta(
        id: id,
        regiaoId: regiaoId,
        regiaoNome: regiaoNome,
        focoId: focoId,
        distanciaKm: distanciaKm,
        geradoEm: geradoEm,
        lido: lido ?? this.lido,
      );

  String get descricao =>
      'Foco a ${distanciaKm.toStringAsFixed(1)} km de "$regiaoNome"';
}
