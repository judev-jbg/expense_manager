import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/analisis_categoria_model.dart';
import '../../../data/repositories/gastos_repository_impl.dart';
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
      // Cargar análisis por categoría
      final analisis = await _gastosRepository.getAnalisisPorCategoriaMes(
        _mesActual,
        _anioActual,
      );

      // Calcular total del mes
      final total = await _gastosRepository.getTotalMes(
        _mesActual,
        _anioActual,
      );

      // Obtener mayor gasto
      final mayorGasto = await _gastosRepository.getMayorGastoMes(
        _mesActual,
        _anioActual,
      );

      // Calcular días transcurridos del mes
      final ahora = DateTime.now();
      final diasMes = DateTime(_anioActual, _mesActual + 1, 0).day;
      int diasTranscurridos;

      if (_mesActual == ahora.month && _anioActual == ahora.year) {
        // Mes actual: días hasta hoy
        diasTranscurridos = ahora.day;
      } else if (DateTime(_anioActual, _mesActual).isAfter(ahora)) {
        // Mes futuro: 0 días
        diasTranscurridos = 0;
      } else {
        // Mes pasado: todos los días del mes
        diasTranscurridos = diasMes;
      }

      // Calcular promedio diario
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mesPrevio() {
    setState(() {
      if (_mesActual == 1) {
        _mesActual = 12;
        _anioActual--;
      } else {
        _mesActual--;
      }
    });
    _cargarDatos();
  }

  void _mesSiguiente() {
    setState(() {
      if (_mesActual == 12) {
        _mesActual = 1;
        _anioActual++;
      } else {
        _mesActual++;
      }
    });
    _cargarDatos();
  }

  String _getNombreMes(int mes) {
    final fecha = DateTime(_anioActual, mes);
    return DateFormat('MMMM yyyy', 'es_ES').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selector de mes
        Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: _cargando ? null : _mesPrevio,
              ),
              Text(
                _getNombreMes(_mesActual),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: _cargando ? null : _mesSiguiente,
              ),
            ],
          ),
        ),

        // Contenido
        Expanded(
          child: _cargando
              ? Center(child: CircularProgressIndicator())
              : _analisis.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay gastos en este mes',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: ListView(
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
                      MonthlyBarChart(analisis: _analisis, totalMes: _totalMes),

                      // Desglose por categoría
                      CategoryBreakdownCard(
                        analisis: _analisis,
                        totalMes: _totalMes,
                      ),

                      SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
