import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alerta.dart';
import '../providers/alertas_provider.dart';
import '../utils/helpers.dart';
import '../widgets/estado_vazio_widget.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertasProvider>();
    final alertas = provider.alertas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          if (provider.naoLidos > 0)
            TextButton(
              onPressed: provider.marcarTodosLidos,
              child: const Text('Marcar todos',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: alertas.isEmpty
          ? const EstadoVazioWidget(
              icone: Icons.notifications_off_outlined,
              mensagem: 'Nenhum alerta por enquanto.\nCadastre regiões para ser notificado.',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: alertas.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) => _AlertaTile(
                alerta: alertas[i],
                onTap: () => provider.marcarLido(alertas[i].id),
              ),
            ),
    );
  }
}

class _AlertaTile extends StatelessWidget {
  final Alerta alerta;
  final VoidCallback onTap;

  const _AlertaTile({required this.alerta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: alerta.lido ? null : Colors.orange.shade50,
      leading: CircleAvatar(
        backgroundColor:
            alerta.lido ? Colors.grey.shade200 : Colors.deepOrange,
        child: Icon(
          Icons.local_fire_department,
          color: alerta.lido ? Colors.grey : Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        alerta.descricao,
        style: TextStyle(
          fontWeight: alerta.lido ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(formatarDataHora(alerta.geradoEm)),
      trailing: alerta.lido
          ? null
          : const Icon(Icons.circle, color: Colors.deepOrange, size: 10),
      onTap: alerta.lido ? null : onTap,
    );
  }
}
