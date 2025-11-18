import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyBreakdownTable extends StatelessWidget {
  final List<Map<String, dynamic>> datosMensuales;
  final int anio;

  const MonthlyBreakdownTable({
    Key? key,
    required this.datosMensuales,
    required this.anio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (datosMensuales.isEmpty) {
      return SizedBox.shrink();
    }

    // Calcular total anual
    final totalAnual = datosMensuales
        .map((d) => d['total'] as double)
        .reduce((a, b) => a + b);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desglose Mensual',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Tabla
            Table(
              columnWidths: {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.5),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: [
                    _buildHeaderCell('Mes'),
                    _buildHeaderCell('Total', TextAlign.right),
                    _buildHeaderCell('%', TextAlign.right),
                  ],
                ),

                // Filas de datos
                ...datosMensuales.map((dato) {
                  final mes = dato['mes'] as int;
                  final total = dato['total'] as double;
                  final porcentaje = totalAnual > 0
                      ? (total / totalAnual * 100)
                      : 0;

                  final fecha = DateTime(anio, mes);
                  final nombreMes = DateFormat('MMMM', 'es_ES').format(fecha);

                  // Determinar color según el monto
                  Color? colorFondo;
                  if (total > 0) {
                    final maxTotal = datosMensuales
                        .map((d) => d['total'] as double)
                        .reduce((a, b) => a > b ? a : b);

                    if (total == maxTotal) {
                      colorFondo = Colors.orange.shade50;
                    }
                  }

                  return TableRow(
                    decoration: BoxDecoration(color: colorFondo),
                    children: [
                      _buildDataCell(
                        _capitalizeFirst(nombreMes),
                        TextAlign.left,
                      ),
                      _buildDataCell(
                        '€${total.toStringAsFixed(2)}',
                        TextAlign.right,
                        fontWeight: total > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      _buildDataCell(
                        '${porcentaje.toStringAsFixed(1)}%',
                        TextAlign.right,
                        color: Colors.grey[600],
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, [TextAlign align = TextAlign.left]) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text,
    TextAlign align, {
    FontWeight? fontWeight,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(fontSize: 14, fontWeight: fontWeight, color: color),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
