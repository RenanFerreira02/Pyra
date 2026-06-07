import 'package:intl/intl.dart';

final _dateTimeFmt = DateFormat('dd/MM/yyyy HH:mm');

String formatarDataHora(DateTime dt) => _dateTimeFmt.format(dt);

/// Converte km para string legível.
String formatarDistancia(double km) =>
    km < 1 ? '${(km * 1000).toStringAsFixed(0)} m' : '${km.toStringAsFixed(1)} km';
