import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
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
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  'Grafico de barras por categoria',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final categoriasTop = analisis.take(8).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gastos por categoria',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(categoriasTop),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (BarChartGroupData group) {
                      return AppColors.primaryDark.withValues(alpha: 0.9);
                    },
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final categoria = categoriasTop[groupIndex];
                      return BarTooltipItem(
                        '${categoria.categoriaNombre}\n',
                        TextStyle(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '€${categoria.totalGastado.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppColors.primary,
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
                            categoria.categoriaColor.replaceFirst('#', '0xff'),
                          ),
                        );

                        return Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Icon(icono, size: 18, color: color),
                        );
                      },
                      reservedSize: 36,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '€${value.toInt()}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
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
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxY(categoriasTop) / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.background,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(categoriasTop),
              ),
            ),
          ),
        ],
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
            width: 16,
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

    return maxValue * 1.2;
  }
}
