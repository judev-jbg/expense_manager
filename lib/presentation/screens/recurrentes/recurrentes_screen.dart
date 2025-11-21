import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/database_helper.dart';
import '../../../data/models/configuracion_recurrencia_model.dart';
import '../../../data/models/instancia_recurrente_model.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../home/home_screen.dart';
import '../analisis/analisis_screen.dart';
import 'widgets/recurrente_detail_dialog.dart';

class RecurrentesScreen extends StatefulWidget {
  @override
  State<RecurrentesScreen> createState() => _RecurrentesScreenState();
}

class _RecurrentesScreenState extends State<RecurrentesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _databaseHelper = DatabaseHelper();

  bool _cargando = false;
  List<ConfiguracionRecurrenciaModel> _configuraciones = [];
  Map<String, List<InstanciaRecurrenteModel>> _instanciasPorConfig = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
    });

    try {
      final soloActivas = _tabController.index == 0;

      final configuracionesMap = await _databaseHelper
          .getAllConfiguracionesRecurrencia(soloActivas: soloActivas);

      final configuraciones = configuracionesMap
          .map((map) => ConfiguracionRecurrenciaModel.fromMap(map))
          .toList();

      final Map<String, List<InstanciaRecurrenteModel>> instancias = {};

      for (var config in configuraciones) {
        final instanciasMap = await _databaseHelper
            .getInstanciasPorConfiguracion(config.id);

        instancias[config.id] = instanciasMap
            .map((map) => InstanciaRecurrenteModel.fromMap(map))
            .toList();
      }

      setState(() {
        _configuraciones = configuraciones;
        _instanciasPorConfig = instancias;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                _buildHeader(),

                // Custom Tab Bar
                _buildTabBar(),

                // Content
                Expanded(
                  child: _cargando
                      ? Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildListaRecurrentes(soloActivos: true),
                            _buildListaRecurrentes(soloActivos: false),
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
                currentIndex: 2,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AnalisisScreen()),
                    );
                  } else if (index == 1) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Gastos recurrentes',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          _cargarDatos();
        },
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textOnPrimary,
        unselectedLabelColor: AppColors.textOnPrimary.withValues(alpha: 0.7),
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'Activos'),
          Tab(text: 'Todos'),
        ],
      ),
    );
  }

  Widget _buildListaRecurrentes({required bool soloActivos}) {
    if (_configuraciones.isEmpty) {
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
                Icons.repeat_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              soloActivos
                  ? 'No hay gastos recurrentes activos'
                  : 'No hay gastos recurrentes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Crea un gasto y activa "Es recurrente"',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: 100,
        ),
        itemCount: _configuraciones.length,
        itemBuilder: (context, index) {
          final config = _configuraciones[index];
          final instancias = _instanciasPorConfig[config.id] ?? [];

          return _buildRecurrenteCard(config, instancias);
        },
      ),
    );
  }

  Widget _buildRecurrenteCard(
    ConfiguracionRecurrenciaModel config,
    List<InstanciaRecurrenteModel> instancias,
  ) {
    final pendientes = instancias
        .where((i) => i.estado == EstadoInstancia.PENDIENTE)
        .length;
    final confirmadas = instancias
        .where((i) => i.estado == EstadoInstancia.CONFIRMADA)
        .length;
    final omitidas = instancias
        .where((i) => i.estado == EstadoInstancia.OMITIDA)
        .length;

    InstanciaRecurrenteModel? proximaInstancia;
    try {
      proximaInstancia = instancias
          .where((i) => i.estado == EstadoInstancia.PENDIENTE)
          .reduce((a, b) => a.fechaEsperada.isBefore(b.fechaEsperada) ? a : b);
    } catch (e) {}

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => _mostrarDetalles(config, instancias),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Icono circular
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: config.activa
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : AppColors.textLight.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.repeat,
                        color: config.activa
                            ? AppColors.accent
                            : AppColors.textLight,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),

                    // Nombre e importe
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.nombreGasto,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: config.activa
                                  ? AppColors.textPrimary
                                  : AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '€ ${config.importeBase.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Switch
                    Switch(
                      value: config.activa,
                      onChanged: (value) => _toggleActiva(config, value),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),

                // Frecuencia tag
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    config.descripcionFrecuencia,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Próxima fecha
                if (proximaInstancia != null) ...[
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        'Proximo: ${DateFormat('dd/MM/yyyy').format(proximaInstancia.fechaEsperada)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        '(Notif. ${DateFormat('dd/MM').format(proximaInstancia.fechaNotificacion)})',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: AppSpacing.md),
                Divider(color: AppColors.background, height: 1),
                SizedBox(height: AppSpacing.md),

                // Estadísticas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('Pendientes', pendientes, AppColors.accent),
                    _buildStat('Confirmados', confirmadas, AppColors.success),
                    _buildStat('Omitidas', omitidas, AppColors.textLight),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _mostrarDetalles(
    ConfiguracionRecurrenciaModel config,
    List<InstanciaRecurrenteModel> instancias,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RecurrenteDetailDialog(
        configuracion: config,
        instancias: instancias,
        onEliminar: () {
          Navigator.pop(context);
          _eliminarConfiguracion(config);
        },
        onActualizar: () {
          Navigator.pop(context);
          _cargarDatos();
        },
      ),
    );
  }

  Future<void> _toggleActiva(
    ConfiguracionRecurrenciaModel config,
    bool activa,
  ) async {
    try {
      final configActualizada = config.copyWith(
        activa: activa,
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateConfiguracionRecurrencia(
        configActualizada.toMap(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            activa
                ? 'Gasto recurrente activado'
                : 'Gasto recurrente desactivado',
          ),
          backgroundColor: activa ? AppColors.success : AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _cargarDatos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _eliminarConfiguracion(
    ConfiguracionRecurrenciaModel config,
  ) async {
    final confirmar = await _mostrarConfirmacionEliminar(config);

    if (confirmar != true) return;

    try {
      await _databaseHelper.deleteConfiguracionRecurrencia(config.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gasto recurrente eliminado'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _cargarDatos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool?> _mostrarConfirmacionEliminar(
    ConfiguracionRecurrenciaModel config,
  ) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Eliminar "${config.nombreGasto}"',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Se eliminarán todas las instancias pendientes y el historial.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(bottomSheetContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(color: AppColors.textLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(bottomSheetContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: AppColors.textOnPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }
}
