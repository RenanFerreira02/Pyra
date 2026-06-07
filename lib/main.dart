import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/alertas_provider.dart';
import 'providers/focos_provider.dart';
import 'providers/regioes_provider.dart';
import 'screens/alerts_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/map_screen.dart';
import 'screens/regions_screen.dart';
import 'services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PyraApp());
}

// StatefulWidget para que StorageService seja criado uma única vez,
// independente de quantas vezes o build rodar.
class PyraApp extends StatefulWidget {
  const PyraApp({super.key});

  @override
  State<PyraApp> createState() => _PyraAppState();
}

class _PyraAppState extends State<PyraApp> {
  final _storage = StorageService();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FocosProvider()),
        ChangeNotifierProvider(create: (_) => RegioesProvider(storage: _storage)),
        ChangeNotifierProvider(create: (_) => AlertasProvider(storage: _storage)),
      ],
      child: MaterialApp(
        title: 'Pyra — Monitoramento de Queimadas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: false),
        ),
        home: const _AppShell(),
      ),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _tab = 0;

  static const _screens = [
    MapScreen(),
    DashboardScreen(),
    AlertsScreen(),
    RegionsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    final focos = context.read<FocosProvider>();
    final regioes = context.read<RegioesProvider>();
    final alertas = context.read<AlertasProvider>();

    // Carrega focos e regiões em paralelo; só verifica proximidade quando ambos terminam.
    await Future.wait([regioes.pronto, focos.carregarFocos()]);
    await alertas.verificarProximidade(focos.focosRaw, regioes.regioes);
  }

  @override
  Widget build(BuildContext context) {
    final naoLidos = context.watch<AlertasProvider>().naoLidos;

    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: naoLidos > 0,
              label: Text('$naoLidos'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: naoLidos > 0,
              label: Text('$naoLidos'),
              child: const Icon(Icons.notifications),
            ),
            label: 'Alertas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Regiões',
          ),
        ],
      ),
    );
  }
}
