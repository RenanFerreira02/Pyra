import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focos_provider.dart';

class FiltroBottomSheet extends StatefulWidget {
  const FiltroBottomSheet({super.key});

  static Future<void> mostrar(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const FiltroBottomSheet(),
      );

  @override
  State<FiltroBottomSheet> createState() => _FiltroBottomSheetState();
}

class _FiltroBottomSheetState extends State<FiltroBottomSheet> {
  DateTime? _inicio;
  DateTime? _fim;
  String? _intensidade;

  @override
  void initState() {
    super.initState();
    final p = context.read<FocosProvider>();
    _inicio = p.dataInicio;
    _fim = p.dataFim;
    _intensidade = p.intensidadeFiltro;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtrar focos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Período
          const Text('Período', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _datePicker('De', _inicio, (d) => setState(() => _inicio = d))),
              const SizedBox(width: 8),
              Expanded(child: _datePicker('Até', _fim, (d) => setState(() => _fim = d))),
            ],
          ),
          const SizedBox(height: 16),

          // Intensidade
          const Text('Intensidade', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Baixa', 'Média', 'Alta'].map((v) => FilterChip(
              label: Text(v),
              selected: _intensidade == v,
              onSelected: (s) => setState(() => _intensidade = s ? v : null),
            )).toList(),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<FocosProvider>().limparFiltros();
                    Navigator.pop(context);
                  },
                  child: const Text('Limpar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    context.read<FocosProvider>().setFiltros(
                      dataInicio: _inicio,
                      dataFim: _fim,
                      intensidade: _intensidade,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datePicker(String label, DateTime? value, ValueChanged<DateTime?> onChanged) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        onChanged(picked);
      },
      child: Text(value == null
          ? label
          : '${value.day}/${value.month}/${value.year}'),
    );
  }
}
