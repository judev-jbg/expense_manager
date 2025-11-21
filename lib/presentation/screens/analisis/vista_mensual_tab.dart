import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/analisis_categoria_model.dart';
import '../../../data/repositories/gastos_repository_impl.dart';
import '../../widgets/month_selector.dart';
import 'widgets/stats_summary_card.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/category_breakdown_card.dart';

class VistaMensualTab extends StatefulWidget {
  @override
  State<VistaMensualTab> createState() => _VistaMensualTabState();
}

class _VistaMensualTabState extends State<VistaMensualTab> {
  late int _mesActual;
  late int _anioActual;

  final _gastosRepository = GastosRepositoryImpl();

  bool _cargando = false;
  List<AnalisisCategoriaModel> _analisis = [];
  double _totalMes = 0;
  double _promedioDiario = 0;
  String? _mayorGastoNombre;
  double? _mayorGastoImporte;
  int _diasTranscurridos = 0;

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _mesActual = ahora.month;
    _anioActual = ahora.year;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
    });

    try {
      final analisis = await _gastosRepository.getAnalisisPorCategoriaMes(
        _mesActual,
        _anioActual,
      );

      final total = await _gastosRepository.getTotalMes(
        _mesActual,
        _anioActual,
      );

      final mayorGasto = await _gastosRepository.getMayorGastoMes(
        _mesActual,
        _anioActual,
      );

      final ahora = DateTime.now();
      final diasMes = DateTime(_anioActual, _mesActual + 1, 0).day;
      int diasTranscurridos;

      if (_mesActual == ahora.month && _anioActual == ahora.year) {
        diasTranscurridos = ahora.day;
      } else if (DateTime(_anioActual, _mesActual).isAfter(ahora)) {
        diasTranscurridos = 0;
      } else {
        diasTranscurridos = diasMes;
      }

      final promedio = diasTranscurridos > 0 ? total / diasTranscurridos : 0;

      setState(() {
        _analisis = analisis;
        _totalMes = total;
        _promedioDiario = promedio.toDouble();
        _diasTranscurridos = diasTranscurridos;

        if (mayorGasto != null) {
          _mayorGastoNombre = mayorGasto['nombre'] as String;
          _mayorGastoImporte = mayorGasto['importe'] as double;
        } else {
          _mayorGastoNombre = null;
          _mayorGastoImporte = null;
        }

        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onMonthChanged(int mes, int anio) {
    setState(() {
      _mesActual = mes;
      _anioActual = anio;
    });
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selector de mes horizontal
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: MonthSelector(
            selectedMonth: _mesActual,
            selectedYear: _anioActual,
            onMonthChanged: _onMonthChanged,
          ),
        ),

        // Contenido
        Expanded(
          child: _cargando
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _analisis.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _cargarDatos,
                      color: AppColors.primary,
                      child: ListView(
                        padding: EdgeInsets.only(bottom: 100),
                        children: [
                          // Resumen del mes
                          StatsSummaryCard(
                            totalMes: _totalMes,
                            promedioDiario: _promedioDiario,
                            mayorGastoNombre: _mayorGastoNombre,
                            mayorGastoImporte: _mayorGastoImporte,
                            diasTranscurridos: _diasTranscurridos,
                          ),

                          // Gráfico de barras
                          MonthlyBarChart(
                            analisis: _analisis,
                            totalMes: _totalMes,
                          ),

                          // Desglose por categoría
                          CategoryBreakdownCard(
                            analisis: _analisis,
                            totalMes: _totalMes,
                          ),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No hay gastos en este mes',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
