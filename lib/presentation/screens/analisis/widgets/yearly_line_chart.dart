import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearlyLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> datosMensuales;
  final int anio;

  const YearlyLineChart({
    Key? key,
    required this.datosMensuales,
    required this.anio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (datosMensuales.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'No hay datos para mostrar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolución Mensual $anio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Container(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getHorizontalInterval(),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final mes = value.toInt();
                          if (mes < 1 || mes > 12) return Text('');

                          // Mostrar solo algunos meses para no saturar
                          if (mes == 1 ||
                              mes == 3 ||
                              mes == 6 ||
                              mes == 9 ||
                              mes == 12) {
                            final fecha = DateTime(anio, mes);
                            final nombreMes = DateFormat(
                              'MMM',
                              'es_ES',
                            ).format(fecha).toUpperCase();
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                nombreMes,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '€${value.toInt()}',
                            style: TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 50,
                        interval: _getHorizontalInterval(),
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  minX: 1,
                  maxX: 12,
                  minY: 0,
                  maxY: _getMaxY(),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (LineBarSpot spot) {
                        return Colors.blueGrey.withOpacity(0.8);
                      },
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final mes = spot.x.toInt();
                          final fecha = DateTime(anio, mes);
                          final nombreMes = DateFormat(
                            'MMMM',
                            'es_ES',
                          ).format(fecha);

                          return LineTooltipItem(
                            '$nombreMes\n€${spot.y.toStringAsFixed(2)}',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _buildSpots(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.blue,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    return datosMensuales.map((dato) {
      final mes = dato['mes'] as int;
      final total = dato['total'] as double;
      return FlSpot(mes.toDouble(), total);
    }).toList();
  }

  double _getMaxY() {
    if (datosMensuales.isEmpty) return 100;

    final maxValue = datosMensuales
        .map((d) => d['total'] as double)
        .reduce((a, b) => a > b ? a : b);

    // Añadir 20% de margen superior
    return maxValue * 1.2;
  }

  double _getHorizontalInterval() {
    final maxY = _getMaxY();

    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 500;
    return 1000;
  }
}
