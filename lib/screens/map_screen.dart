import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
  final Completer<GoogleMapController> _controller = Completer();
  final LocationService _location = LocationService();

  Position? _posicaoAtual;
  String? _erroLocalizacao;
  bool _carregandoLocalizacao = true;

  static const CameraPosition _brasilInicial = CameraPosition(
    target: LatLng(-14.0, -51.0),
    zoom: 4.5,
  );

  @override
  void initState() {
    super.initState();
    // Carregamento dos focos é responsabilidade do _AppShell._inicializar.
    // Aqui só obtemos a localização do dispositivo.
    _obterLocalizacao();
  }

  Future<void> _obterLocalizacao() async {
    try {
      final pos = await _location.obterPosicaoAtual();
      if (!mounted) return;
      setState(() {
        _posicaoAtual = pos;
        _carregandoLocalizacao = false;
      });
      final ctrl = await _controller.future;
      ctrl.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(pos.latitude, pos.longitude),
        7,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroLocalizacao = e.toString();
        _carregandoLocalizacao = false;
      });
    }
  }

  Set<Marker> _buildMarkers(List<Foco> focos) {
    final markers = <Marker>{};

    // Marcador do usuário
    if (_posicaoAtual != null) {
      markers.add(Marker(
        markerId: const MarkerId('usuario'),
        position: LatLng(_posicaoAtual!.latitude, _posicaoAtual!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Sua localização'),
      ));
    }

    // Marcadores de focos
    for (final foco in focos) {
      final hue = foco.frp >= 100
          ? BitmapDescriptor.hueRed
          : foco.frp >= 30
              ? BitmapDescriptor.hueOrange
              : BitmapDescriptor.hueYellow;

      markers.add(Marker(
        markerId: MarkerId(foco.id),
        position: LatLng(foco.latitude, foco.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(
          title: 'Foco ${foco.intensidade}',
          snippet:
              '${foco.estado ?? ''} | FRP: ${foco.frp.toStringAsFixed(0)} MW\n${foco.satelite}',
        ),
      ));
    }

    return markers;
  }

  Set<Circle> _buildCircles(RegioesProvider regioes) {
    return regioes.regioes.map((r) => Circle(
          circleId: CircleId(r.id),
          center: LatLng(r.latitude, r.longitude),
          radius: r.raioKm * 1000,
          fillColor: Colors.blue.withValues(alpha: 0.1),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        )).toSet();
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
          GoogleMap(
            initialCameraPosition: _brasilInicial,
            onMapCreated: (ctrl) => _controller.complete(ctrl),
            myLocationEnabled: _posicaoAtual != null,
            myLocationButtonEnabled: false,
            markers: _buildMarkers(focosProvider.focos),
            circles: _buildCircles(regioesProvider),
            mapType: MapType.hybrid,
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
