import 'package:expense_manager/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../../../data/models/configuracion_recurrencia_model.dart';
import '../../../data/models/instancia_recurrente_model.dart';
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

      // Cargar instancias para cada configuración
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gastos Recurrentes'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            _cargarDatos();
          },
          tabs: [
            Tab(icon: Icon(Icons.check_circle), text: 'Activos'),
            Tab(icon: Icon(Icons.list), text: 'Todos'),
          ],
        ),
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListaRecurrentes(soloActivos: true),
                _buildListaRecurrentes(soloActivos: false),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AnalisisScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Gastos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Análisis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: 'Recurrentes',
          ),
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
            Icon(Icons.repeat_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              soloActivos
                  ? 'No hay gastos recurrentes activos'
                  : 'No hay gastos recurrentes',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Crea un gasto y activa "Es recurrente"',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
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
    // Estadísticas
    final pendientes = instancias
        .where((i) => i.estado == EstadoInstancia.PENDIENTE)
        .length;
    final confirmadas = instancias
        .where((i) => i.estado == EstadoInstancia.CONFIRMADA)
        .length;
    final omitidas = instancias
        .where((i) => i.estado == EstadoInstancia.OMITIDA)
        .length;
    final saltadas = instancias
        .where((i) => i.estado == EstadoInstancia.SALTADA)
        .length;

    // Próxima instancia pendiente
    InstanciaRecurrenteModel? proximaInstancia;
    try {
      proximaInstancia = instancias
          .where((i) => i.estado == EstadoInstancia.PENDIENTE)
          .reduce((a, b) => a.fechaEsperada.isBefore(b.fechaEsperada) ? a : b);
    } catch (e) {
      // No hay instancias pendientes
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _mostrarDetalles(config, instancias),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Icono de estado
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: config.activa
                          ? Colors.orange.shade100
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.repeat,
                      color: config.activa
                          ? Colors.orange.shade700
                          : Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),

                  // Nombre e importe
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.nombreGasto,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: config.activa ? Colors.black : Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '€${config.importeBase.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Switch activa/inactiva
                  Switch(
                    value: config.activa,
                    onChanged: (value) => _toggleActiva(config, value),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Frecuencia
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  config.descripcionFrecuencia,
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                ),
              ),

              // Próxima fecha
              if (proximaInstancia != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Próximo: ${DateFormat('dd/MM/yyyy').format(proximaInstancia.fechaEsperada)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '(Notif: ${DateFormat('dd/MM').format(proximaInstancia.fechaNotificacion)})',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 12),
              Divider(height: 1),
              SizedBox(height: 8),

              // Estadísticas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Pendientes', pendientes, Colors.orange),
                  _buildStat('Confirmadas', confirmadas, Colors.green),
                  _buildStat('Omitidas', omitidas, Colors.grey),
                  if (saltadas > 0)
                    _buildStat('Saltadas', saltadas, Colors.red),
                ],
              ),
            ],
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
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  void _mostrarDetalles(
    ConfiguracionRecurrenciaModel config,
    List<InstanciaRecurrenteModel> instancias,
  ) {
    showDialog(
      context: context,
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
          backgroundColor: activa ? Colors.green : Colors.orange,
        ),
      );

      _cargarDatos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarConfiguracion(
    ConfiguracionRecurrenciaModel config,
  ) async {
    // Confirmar eliminación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Eliminar gasto recurrente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que deseas eliminar "${config.nombreGasto}"?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Se eliminarán todas las instancias pendientes y el historial.',
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await _databaseHelper.deleteConfiguracionRecurrencia(config.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gasto recurrente eliminado'),
          backgroundColor: Colors.orange,
        ),
      );

      _cargarDatos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
