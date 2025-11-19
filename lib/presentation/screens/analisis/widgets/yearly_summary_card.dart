import 'package:flutter/material.dart';

class YearlySummaryCard extends StatelessWidget {
  final double totalAnio;
  final double promedioMensual;
  final String? mesMayorGasto;
  final double? mayorGastoMes;

  const YearlySummaryCard({
    Key? key,
    required this.totalAnio,
    required this.promedioMensual,
    this.mesMayorGasto,
    this.mayorGastoMes,
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
            // Total del año
            Text(
              'Total del año',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              '€${totalAnio.toStringAsFixed(2)}',
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
                // Promedio mensual
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.calendar_month,
                    label: 'Promedio mensual',
                    value: '€${promedioMensual.toStringAsFixed(2)}',
                    color: Colors.green,
                  ),
                ),

                // Mes con mayor gasto
                if (mesMayorGasto != null && mayorGastoMes != null)
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.trending_up,
                      label: 'Mes con mayor gasto',
                      value: '€${mayorGastoMes!.toStringAsFixed(2)}',
                      subtitle: mesMayorGasto,
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
