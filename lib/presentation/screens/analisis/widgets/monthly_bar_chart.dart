import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/analisis_categoria_model.dart';
import '../../configuracion/widgets/icon_picker_dialog.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<AnalisisCategoriaModel> analisis;
  final double totalMes;

  const MonthlyBarChart({
    Key? key,
    required this.analisis,
    required this.totalMes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (analisis.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
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

    // Tomar máximo 8 categorías (las más altas)
    final categoriasTop = analisis.take(8).toList();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gastos por Categoría',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Container(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(categoriasTop),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (BarChartGroupData group) {
                        return Colors.blueGrey.withOpacity(0.8);
                      },
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final categoria = categoriasTop[groupIndex];
                        return BarTooltipItem(
                          '${categoria.categoriaNombre}\n',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '€${categoria.totalGastado.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= categoriasTop.length) {
                            return Text('');
                          }
                          final categoria = categoriasTop[value.toInt()];
                          final icono = IconPickerDialog.getIconData(
                            categoria.categoriaIcono,
                          );
                          final color = Color(
                            int.parse(
                              categoria.categoriaColor.replaceFirst(
                                '#',
                                '0xff',
                              ),
                            ),
                          );

                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Icon(icono, size: 20, color: color),
                          );
                        },
                        reservedSize: 40,
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
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(categoriasTop),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<AnalisisCategoriaModel> categorias,
  ) {
    return categorias.asMap().entries.map((entry) {
      final index = entry.key;
      final categoria = entry.value;
      final color = Color(
        int.parse(categoria.categoriaColor.replaceFirst('#', '0xff')),
      );

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: categoria.totalGastado,
            color: color,
            width: 20,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY(List<AnalisisCategoriaModel> categorias) {
    if (categorias.isEmpty) return 100;

    final maxValue = categorias
        .map((c) => c.totalGastado)
        .reduce((a, b) => a > b ? a : b);

    // Añadir 20% de margen superior
    return maxValue * 1.2;
  }
}
