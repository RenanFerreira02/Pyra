import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/regiao.dart';
import '../providers/regioes_provider.dart';
import '../services/location_service.dart';
import '../widgets/estado_vazio_widget.dart';

class RegionsScreen extends StatelessWidget {
  const RegionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegioesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regiões Monitoradas'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: provider.regioes.isEmpty
          ? const EstadoVazioWidget(
              icone: Icons.add_location_alt_outlined,
              mensagem: 'Nenhuma região cadastrada.\nToque em + para adicionar.',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.regioes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final regiao = provider.regioes[i];
                return _RegiaoTile(
                  regiao: regiao,
                  onEdit: () => _showDialog(context, regiao: regiao),
                  onDelete: () => _confirmarExclusao(context, provider, regiao),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Nova região'),
        onPressed: () => _showDialog(context),
      ),
    );
  }

  Future<void> _confirmarExclusao(
    BuildContext context,
    RegioesProvider provider,
    Regiao regiao,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover região'),
        content: Text('Deseja remover "${regiao.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover')),
        ],
      ),
    );
    if (ok == true) await provider.excluirRegiao(regiao.id);
  }

  void _showDialog(BuildContext context, {Regiao? regiao}) {
    showDialog(
      context: context,
      builder: (_) => _RegiaoDialog(regiao: regiao),
    );
  }
}

class _RegiaoTile extends StatelessWidget {
  final Regiao regiao;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RegiaoTile({
    required this.regiao,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.location_on, color: Colors.white, size: 20),
      ),
      title: Text(regiao.nome,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        'Raio: ${regiao.raioKm.toStringAsFixed(0)} km\n'
        'Lat: ${regiao.latitude.toStringAsFixed(4)}, Lon: ${regiao.longitude.toStringAsFixed(4)}',
      ),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
          IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete),
        ],
      ),
    );
  }
}

class _RegiaoDialog extends StatefulWidget {
  final Regiao? regiao;
  const _RegiaoDialog({this.regiao});

  @override
  State<_RegiaoDialog> createState() => _RegiaoDialogState();
}

class _RegiaoDialogState extends State<_RegiaoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _lat;
  late final TextEditingController _lon;
  late final TextEditingController _raio;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    final r = widget.regiao;
    _nome = TextEditingController(text: r?.nome ?? '');
    _lat = TextEditingController(text: r?.latitude.toString() ?? '');
    _lon = TextEditingController(text: r?.longitude.toString() ?? '');
    _raio = TextEditingController(text: r?.raioKm.toStringAsFixed(0) ?? '50');
  }

  @override
  void dispose() {
    _nome.dispose();
    _lat.dispose();
    _lon.dispose();
    _raio.dispose();
    super.dispose();
  }

  Future<void> _usarLocalizacaoAtual() async {
    setState(() => _carregando = true);
    try {
      final pos = await LocationService().obterPosicaoAtual();
      _lat.text = pos.latitude.toStringAsFixed(6);
      _lon.text = pos.longitude.toStringAsFixed(6);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao obter localização: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    final provider = context.read<RegioesProvider>();
    try {
      if (widget.regiao == null) {
        await provider.adicionarRegiao(
          nome: _nome.text.trim(),
          latitude: double.parse(_lat.text),
          longitude: double.parse(_lon.text),
          raioKm: double.parse(_raio.text),
        );
      } else {
        await provider.atualizarRegiao(
          widget.regiao!.copyWith(
            nome: _nome.text.trim(),
            latitude: double.parse(_lat.text),
            longitude: double.parse(_lon.text),
            raioKm: double.parse(_raio.text),
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.regiao == null ? 'Nova Região' : 'Editar Região'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome da região'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lat,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lon,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) => double.tryParse(v ?? '') == null ? 'Inválido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _carregando ? null : _usarLocalizacaoAtual,
                  icon: const Icon(Icons.my_location, size: 16),
                  label: const Text('Usar minha localização'),
                ),
              ),
              TextFormField(
                controller: _raio,
                decoration: const InputDecoration(
                  labelText: 'Raio de monitoramento (km)',
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final d = double.tryParse(v ?? '');
                  if (d == null || d <= 0) return 'Informe um raio válido';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _carregando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _carregando ? null : _salvar,
          child: _carregando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
