import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../bloc/gastos/gastos_bloc.dart';
import '../../bloc/gastos/gastos_event.dart';
import '../../bloc/gastos/gastos_state.dart';
import '../agregar_gasto/agregar_gasto_screen.dart';
import 'widgets/gasto_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _mesActual;
  late int _anioActual;

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _mesActual = ahora.month;
    _anioActual = ahora.year;
    initializeDateFormatting('es_ES');

    // Cargar gastos del mes actual
    context.read<GastosBloc>().add(
      LoadGastos(mes: _mesActual, anio: _anioActual),
    );
  }

  /// Cambia al mes anterior
  void _mesPrevio() {
    setState(() {
      if (_mesActual == 1) {
        _mesActual = 12;
        _anioActual--;
      } else {
        _mesActual--;
      }
    });
    context.read<GastosBloc>().add(
      LoadGastos(mes: _mesActual, anio: _anioActual),
    );
  }

  /// Cambia al mes siguiente
  void _mesSiguiente() {
    setState(() {
      if (_mesActual == 12) {
        _mesActual = 1;
        _anioActual++;
      } else {
        _mesActual++;
      }
    });
    context.read<GastosBloc>().add(
      LoadGastos(mes: _mesActual, anio: _anioActual),
    );
  }

  /// Obtiene el nombre del mes en español
  String _getNombreMes(int mes) {
    final fecha = DateTime(_anioActual, mes);
    return DateFormat('MMMM yyyy', 'es_ES').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestor de Gastos'), centerTitle: true),
      body: Column(
        children: [
          // Selector de mes
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: _mesPrevio,
                ),
                Text(
                  _getNombreMes(_mesActual),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: _mesSiguiente,
                ),
              ],
            ),
          ),

          // Total del mes
          BlocBuilder<GastosBloc, GastosState>(
            builder: (context, state) {
              if (state is GastosLoaded) {
                return Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        'Total del mes',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '€${state.totalMes.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),

          // Lista de gastos
          Expanded(
            child: BlocConsumer<GastosBloc, GastosState>(
              listener: (context, state) {
                // Mostrar mensajes de éxito
                if (state is GastoAdded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is GastoDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else if (state is GastosError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is GastosLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is GastosLoaded) {
                  if (state.gastos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay gastos este mes',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Toca el botón + para agregar uno',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: state.gastos.length,
                    itemBuilder: (context, index) {
                      return GastoCard(gastoConDetalles: state.gastos[index]);
                    },
                  );
                }

                if (state is GastosError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error al cargar gastos',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<GastosBloc>().add(
                              LoadGastos(mes: _mesActual, anio: _anioActual),
                            );
                          },
                          child: Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                return Center(child: Text('Estado inicial'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegar a la pantalla de agregar gasto
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgregarGastoScreen()),
          );

          // Si se agregó un gasto, recargar la lista
          if (resultado == true) {
            context.read<GastosBloc>().add(
              LoadGastos(mes: _mesActual, anio: _anioActual),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
