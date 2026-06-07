import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focos_provider.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/estado_vazio_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FocosProvider>();

    if (provider.status == FocosStatus.loading && provider.focosRaw.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.status == FocosStatus.error && provider.focosRaw.isEmpty) {
      return Scaffold(
        body: EstadoVazioWidget(
          icone: Icons.cloud_off,
          mensagem: provider.erro,
          onRetry: provider.carregarFocos,
        ),
      );
    }

    final total = provider.focosRaw.length;
    final porEstado = provider.focosPorEstado();
    final porBioma = provider.focosPorBioma();
    final porDia = provider.focosPorDia(dias: 7);
    final topEstado = porEstado.entries.isEmpty
        ? '-'
        : (porEstado.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.status == FocosStatus.loading
                ? null
                : provider.carregarFocos,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.carregarFocos,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Cards de resumo ──────────────────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  titulo: 'Total de focos',
                  valor: '$total',
                  icone: Icons.local_fire_department,
                  cor: Colors.deepOrange,
                ),
                StatCard(
                  titulo: 'Estado com mais focos',
                  valor: topEstado,
                  icone: Icons.map_outlined,
                  cor: Colors.redAccent,
                ),
                StatCard(
                  titulo: 'Focos alta intensidade',
                  valor: '${provider.focosRaw.where((f) => f.intensidade == 'Alta').length}',
                  icone: Icons.whatshot,
                  cor: Colors.red,
                ),
                StatCard(
                  titulo: 'Satélites ativos',
                  valor: '${provider.focosRaw.map((f) => f.satelite).toSet().length}',
                  icone: Icons.satellite_alt,
                  cor: Colors.blueGrey,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Gráfico de barras: focos por dia ─────────────────────────
            const _SectionTitle(title: 'Focos nos últimos 7 dias'),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _BarChartDias(porDia: porDia),
            ),

            const SizedBox(height: 24),

            // ── Gráfico de pizza: focos por bioma ────────────────────────
            if (porBioma.isNotEmpty) ...[
              const _SectionTitle(title: 'Distribuição por bioma'),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: _PieChartBioma(porBioma: porBioma),
              ),
              const SizedBox(height: 8),
              _Legenda(data: porBioma),
            ],

            const SizedBox(height: 24),

            // ── Lista: top estados ───────────────────────────────────────
            if (porEstado.isNotEmpty) ...[
              const _SectionTitle(title: 'Top estados'),
              const SizedBox(height: 8),
              ...(porEstado.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value)))
                  .take(5)
                  .map((e) => _EstadoBar(
                        estado: e.key,
                        count: e.value,
                        maxCount: porEstado.values.reduce((a, b) => a > b ? a : b),
                      )),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
}

class _BarChartDias extends StatelessWidget {
  final Map<String, int> porDia;
  const _BarChartDias({required this.porDia});

  @override
  Widget build(BuildContext context) {
    final entries = porDia.entries.toList(); // já ordenado: mais antigo → mais recente
    final maxY = entries.map((e) => e.value).fold(0, (a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 10 : maxY * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(entries[idx].key,
                      style: const TextStyle(fontSize: 9)),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          entries.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: entries[i].value.toDouble(),
                color: Colors.deepOrange,
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _biomaColors = [
  Colors.green.shade700,
  Colors.amber.shade700,
  Colors.teal,
  Colors.indigo,
  Colors.brown,
  Colors.pink,
];

class _PieChartBioma extends StatelessWidget {
  final Map<String, int> porBioma;
  const _PieChartBioma({required this.porBioma});

  @override
  Widget build(BuildContext context) {
    final entries = porBioma.entries.toList();
    final total = entries.map((e) => e.value).fold(0, (a, b) => a + b);

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 48,
        sections: List.generate(entries.length, (i) {
          final pct = entries[i].value / total * 100;
          return PieChartSectionData(
            value: entries[i].value.toDouble(),
            title: '${pct.toStringAsFixed(0)}%',
            color: _biomaColors[i % _biomaColors.length],
            radius: 70,
            titleStyle: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }),
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  final Map<String, int> data;
  const _Legenda({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: List.generate(entries.length, (i) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _biomaColors[i % _biomaColors.length],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text('${entries[i].key} (${entries[i].value})',
              style: const TextStyle(fontSize: 11)),
        ],
      )),
    );
  }
}

class _EstadoBar extends StatelessWidget {
  final String estado;
  final int count;
  final int maxCount;
  const _EstadoBar({required this.estado, required this.count, required this.maxCount});

  @override
  Widget build(BuildContext context) {
    final fraction = maxCount == 0 ? 0.0 : count / maxCount;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text(estado, style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 16,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(Colors.deepOrange),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
