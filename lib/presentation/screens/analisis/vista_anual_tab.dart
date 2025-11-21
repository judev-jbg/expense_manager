import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/gastos_repository_impl.dart';
import 'widgets/yearly_summary_card.dart';
import 'widgets/yearly_line_chart.dart';
import 'widgets/monthly_breakdown_table.dart';

class VistaAnualTab extends StatefulWidget {
  @override
  State<VistaAnualTab> createState() => _VistaAnualTabState();
}

class _VistaAnualTabState extends State<VistaAnualTab> {
  late int _anioActual;

  final _gastosRepository = GastosRepositoryImpl();

  bool _cargando = false;
  List<Map<String, dynamic>> _datosMensuales = [];
  double _totalAnio = 0;
  double _promedioMensual = 0;
  String? _mesMayorGasto;
  double? _mayorGastoMes;

  @override
  void initState() {
    super.initState();
    _anioActual = DateTime.now().year;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
    });

    try {
      final datosMensuales = await _gastosRepository.getAnalisisPorMesAnio(
        _anioActual,
      );

      final totalAnio = datosMensuales
          .map((d) => d['total'] as double)
          .reduce((a, b) => a + b);

      final promedio = totalAnio / 12;

      String? mesMayor;
      double? gastoMayor;

      if (datosMensuales.isNotEmpty) {
        var maxDato = datosMensuales[0];
        for (var dato in datosMensuales) {
          if ((dato['total'] as double) > (maxDato['total'] as double)) {
            maxDato = dato;
          }
        }

        if ((maxDato['total'] as double) > 0) {
          final fecha = DateTime(_anioActual, maxDato['mes'] as int);
          mesMayor = DateFormat('MMMM', 'es_ES').format(fecha);
          mesMayor = mesMayor[0].toUpperCase() + mesMayor.substring(1);
          gastoMayor = maxDato['total'] as double;
        }
      }

      setState(() {
        _datosMensuales = datosMensuales;
        _totalAnio = totalAnio;
        _promedioMensual = promedio;
        _mesMayorGasto = mesMayor;
        _mayorGastoMes = gastoMayor;
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

  void _anioPrevio() {
    setState(() {
      _anioActual--;
    });
    _cargarDatos();
  }

  void _anioSiguiente() {
    setState(() {
      _anioActual++;
    });
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selector de año
        Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
                onPressed: _cargando ? null : _anioPrevio,
              ),
              Text(
                '$_anioActual',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.textPrimary),
                onPressed: _cargando ? null : _anioSiguiente,
              ),
            ],
          ),
        ),

        // Contenido
        Expanded(
          child: _cargando
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _totalAnio == 0
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _cargarDatos,
                      color: AppColors.primary,
                      child: ListView(
                        padding: EdgeInsets.only(bottom: 100),
                        children: [
                          YearlySummaryCard(
                            totalAnio: _totalAnio,
                            promedioMensual: _promedioMensual,
                            mesMayorGasto: _mesMayorGasto,
                            mayorGastoMes: _mayorGastoMes,
                          ),
                          YearlyLineChart(
                            datosMensuales: _datosMensuales,
                            anio: _anioActual,
                          ),
                          MonthlyBreakdownTable(
                            datosMensuales: _datosMensuales,
                            anio: _anioActual,
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
              Icons.show_chart_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No hay gastos en este año',
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
