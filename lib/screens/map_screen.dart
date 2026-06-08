import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/foco.dart';
import '../providers/focos_provider.dart';
import '../providers/regioes_provider.dart';
import '../services/location_service.dart';
import '../widgets/filtro_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LocationService _location = LocationService();

  Position? _posicaoAtual;
  String? _erroLocalizacao;
  bool _carregandoLocalizacao = true;

  static const LatLng _brasilCentro = LatLng(-14.0, -51.0);

  @override
  void initState() {
    super.initState();
    // Obtém localização após o primeiro frame para o MapController já estar registrado.
    WidgetsBinding.instance.addPostFrameCallback((_) => _obterLocalizacao());
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _obterLocalizacao() async {
    setState(() => _carregandoLocalizacao = true);
    try {
      final pos = await _location.obterPosicaoAtual();
      if (!mounted) return;
      setState(() {
        _posicaoAtual = pos;
        _carregandoLocalizacao = false;
      });
      _mapController.move(LatLng(pos.latitude, pos.longitude), 7);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroLocalizacao = e.toString();
        _carregandoLocalizacao = false;
      });
    }
  }

  List<Marker> _buildMarkers(List<Foco> focos) {
    final markers = <Marker>[];

    if (_posicaoAtual != null) {
      markers.add(Marker(
        point: LatLng(_posicaoAtual!.latitude, _posicaoAtual!.longitude),
        width: 30,
        height: 30,
        child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 30),
      ));
    }

    for (final foco in focos) {
      final color = foco.frp >= 100
          ? Colors.red
          : foco.frp >= 30
              ? Colors.orange
              : Colors.yellow.shade700;

      markers.add(Marker(
        point: LatLng(foco.latitude, foco.longitude),
        width: 22,
        height: 22,
        child: Tooltip(
          message:
              'Foco ${foco.intensidade}\n${foco.estado ?? ''} | FRP: ${foco.frp.toStringAsFixed(0)} MW | ${foco.satelite}',
          child: Icon(Icons.local_fire_department, color: color, size: 22),
        ),
      ));
    }

    return markers;
  }

  List<CircleMarker> _buildCircles(RegioesProvider regioes) {
    return regioes.regioes
        .map((r) => CircleMarker(
              point: LatLng(r.latitude, r.longitude),
              radius: r.raioKm * 1000,
              useRadiusInMeter: true,
              color: Colors.blue.withValues(alpha: 0.1),
              borderColor: Colors.blue,
              borderStrokeWidth: 2,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final focosProvider = context.watch<FocosProvider>();
    final regioesProvider = context.watch<RegioesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pyra — Mapa de Focos'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar',
            onPressed: () => FiltroBottomSheet.mostrar(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: focosProvider.status == FocosStatus.loading
                ? null
                : () => focosProvider.carregarFocos(),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _brasilCentro,
              initialZoom: 4.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.pyra',
              ),
              CircleLayer(circles: _buildCircles(regioesProvider)),
              MarkerLayer(markers: _buildMarkers(focosProvider.focos)),
            ],
          ),

          // Legenda de intensidade
          const Positioned(
            bottom: 16,
            left: 16,
            child: _Legenda(),
          ),

          // Contador de focos
          Positioned(
            top: 12,
            left: 12,
            child: _FocosChip(count: focosProvider.focos.length),
          ),

          // Loading overlay
          if (focosProvider.status == FocosStatus.loading)
            const Positioned(
              top: 12,
              right: 60,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Carregando...', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

          // Erro de localização (não bloqueia o mapa)
          if (_erroLocalizacao != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Localização indisponível: $_erroLocalizacao',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        tooltip: 'Minha localização',
        onPressed: _carregandoLocalizacao ? null : _obterLocalizacao,
        child: _carregandoLocalizacao
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.my_location),
      ),
    );
  }
}

class _FocosChip extends StatelessWidget {
  final int count;
  const _FocosChip({required this.count});

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.deepOrange,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            '$count focos',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
}

class _Legenda extends StatelessWidget {
  const _Legenda();

  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Intensidade',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              SizedBox(height: 4),
              _LegendaItem(color: Colors.red, label: 'Alta (FRP ≥ 100 MW)'),
              _LegendaItem(color: Colors.orange, label: 'Média (30–99 MW)'),
              _LegendaItem(color: Colors.yellow, label: 'Baixa (< 30 MW)'),
            ],
          ),
        ),
      );
}

class _LegendaItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendaItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      );
}
