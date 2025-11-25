import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/gastos/gastos_bloc.dart';
import '../../bloc/gastos/gastos_event.dart';
import '../../bloc/gastos/gastos_state.dart';
import '../agregar_gasto/agregar_gasto_screen.dart';
import '../configuracion/configuracion_screen.dart';
import '../analisis/analisis_screen.dart';
import '../recurrentes/recurrentes_screen.dart';
import '../busqueda/busqueda_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/month_selector.dart';
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

  void _onMonthChanged(int mes, int anio) {
    setState(() {
      _mesActual = mes;
      _anioActual = anio;
    });
    context.read<GastosBloc>().add(
      LoadGastos(mes: _mesActual, anio: _anioActual),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal
            Column(
              children: [
                // Header oscuro
                _buildHeader(),

                // Sección con el card flotante y contenido principal
                Expanded(
                  child: Stack(
                    children: [
                      // Contenedor principal con fondo claro
                      Column(
                        children: [
                          // Espacio para la mitad superior del card
                          SizedBox(height: 70),
                          // Sección principal con fondo claro y esquinas redondeadas
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(AppRadius.xl),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Espacio para la mitad inferior del card
                                  SizedBox(height: 75),
                                  // Selector de meses
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: MonthSelector(
                                      selectedMonth: _mesActual,
                                      selectedYear: _anioActual,
                                      onMonthChanged: _onMonthChanged,
                                    ),
                                  ),
                                  // Lista de gastos
                                  Expanded(child: _buildGastosList()),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Card flotante del total
                      Positioned(
                        top: 0,
                        left: AppSpacing.lg * 3,
                        right: AppSpacing.lg * 3,
                        child: _buildTotalCard(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Bottom Navigation flotante
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNav(
                currentIndex: 1,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnalisisScreen()),
                    );
                  } else if (index == 2) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecurrentesScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () async {
            final resultado = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AgregarGastoScreen()),
            );

            if (resultado == true) {
              context.read<GastosBloc>().add(
                LoadGastos(mes: _mesActual, anio: _anioActual),
              );
            }
          },
          backgroundColor: AppColors.accent,
          child: Icon(Icons.add, color: AppColors.textOnPrimary),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primaryDark,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mis gastos',
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: AppColors.textOnPrimary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BusquedaScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.settings, color: AppColors.textOnPrimary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfiguracionScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return BlocBuilder<GastosBloc, GastosState>(
      builder: (context, state) {
        double total = 0;
        if (state is GastosLoaded) {
          total = state.totalMes;
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Total del mes',
                style: TextStyle(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                '€ ${total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGastosList() {
    return BlocConsumer<GastosBloc, GastosState>(
      listener: (context, state) {
        if (state is GastoAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          );
        } else if (state is GastoDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          );
        } else if (state is GastosError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is GastosLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is GastosLoaded) {
          if (state.gastos.isEmpty) {
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
                      Icons.receipt_long,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'No hay gastos este mes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Toca el botón + para agregar uno',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Error al cargar gastos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
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
    );
  }
}
