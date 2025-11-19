import 'package:flutter/material.dart';

class StatsSummaryCard extends StatelessWidget {
  final double totalMes;
  final double promedioDiario;
  final String? mayorGastoNombre;
  final double? mayorGastoImporte;
  final int diasTranscurridos;

  const StatsSummaryCard({
    Key? key,
    required this.totalMes,
    required this.promedioDiario,
    this.mayorGastoNombre,
    this.mayorGastoImporte,
    required this.diasTranscurridos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total del mes
            Text(
              'Total del mes',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              '€${totalMes.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            // Estadísticas en fila
            Row(
              children: [
                // Promedio diario
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.calendar_today,
                    label: 'Promedio diario',
                    value: '€${promedioDiario.toStringAsFixed(2)}',
                    color: Colors.green,
                  ),
                ),

                // Mayor gasto
                if (mayorGastoNombre != null && mayorGastoImporte != null)
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.trending_up,
                      label: 'Mayor gasto',
                      value: '€${mayorGastoImporte!.toStringAsFixed(2)}',
                      subtitle: mayorGastoNombre,
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
