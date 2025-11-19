import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_helper.dart';
import '../../../data/models/configuracion_recurrencia_model.dart';
import '../../../data/models/instancia_recurrente_model.dart';
import '../../../data/models/gasto_model.dart';
import '../../../data/repositories/gastos_repository_impl.dart';
import '../../bloc/gastos/gastos_bloc.dart';
import '../../bloc/gastos/gastos_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home/home_screen.dart';

class ConfirmarInstanciaScreen extends StatefulWidget {
  final String instanciaId;

  const ConfirmarInstanciaScreen({Key? key, required this.instanciaId})
    : super(key: key);

  @override
  State<ConfirmarInstanciaScreen> createState() =>
      _ConfirmarInstanciaScreenState();
}

class _ConfirmarInstanciaScreenState extends State<ConfirmarInstanciaScreen> {
  final _databaseHelper = DatabaseHelper();
  final _gastosRepository = GastosRepositoryImpl();
  final _importeController = TextEditingController();
  final _notasController = TextEditingController();

  bool _cargando = true;
  InstanciaRecurrenteModel? _instancia;
  ConfiguracionRecurrenciaModel? _configuracion;
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _importeController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      // Cargar instancia
      final instanciaMap = await _databaseHelper.database.then(
        (db) => db.query(
          'instancias_recurrentes',
          where: 'id = ?',
          whereArgs: [widget.instanciaId],
        ),
      );

      if (instanciaMap.isEmpty) {
        _mostrarError('Instancia no encontrada');
        return;
      }

      final instancia = InstanciaRecurrenteModel.fromMap(instanciaMap.first);

      // Verificar que esté pendiente
      if (instancia.estado != EstadoInstancia.PENDIENTE) {
        _mostrarError('Esta instancia ya fue procesada');
        return;
      }

      // Cargar configuración
      final configMap = await _databaseHelper.getConfiguracionRecurrenciaById(
        instancia.configuracionRecurrenciaId,
      );

      if (configMap == null) {
        _mostrarError('Configuración no encontrada');
        return;
      }

      final configuracion = ConfiguracionRecurrenciaModel.fromMap(configMap);

      setState(() {
        _instancia = instancia;
        _configuracion = configuracion;
        _fechaSeleccionada = instancia.fechaEsperada;
        _importeController.text = configuracion.importeBase.toStringAsFixed(2);
        _notasController.text = configuracion.notasPlantilla ?? '';
        _cargando = false;
      });
    } catch (e) {
      _mostrarError('Error al cargar datos: $e');
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );

    // Volver a home después de 2 segundos
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(title: Text('Confirmar Gasto')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_instancia == null || _configuracion == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('No se pudieron cargar los datos')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmar Gasto Recurrente'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.repeat, color: Colors.orange.shade700),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _configuracion!.nombreGasto,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      _configuracion!.descripcionFrecuencia,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Fecha esperada: ${DateFormat('dd/MM/yyyy').format(_instancia!.fechaEsperada)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Pregunta
            Text(
              '¿Realizaste este pago?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Confirma los detalles o ajústalos si es necesario',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),

            // Campo: Importe
            TextField(
              controller: _importeController,
              decoration: InputDecoration(
                labelText: 'Importe',
                prefixText: '€',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            SizedBox(height: 16),

            // Campo: Fecha
            InkWell(
              onTap: _seleccionarFecha,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Fecha del gasto',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Campo: Notas
            TextField(
              controller: _notasController,
              decoration: InputDecoration(
                labelText: 'Notas (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),

            // Botones de acción
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botón: Confirmar
                ElevatedButton.icon(
                  icon: Icon(Icons.check_circle),
                  label: Text('Confirmar Pago'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _confirmarPago,
                ),
                SizedBox(height: 12),

                // Botón: Omitir
                OutlinedButton.icon(
                  icon: Icon(Icons.cancel),
                  label: Text('No lo realicé (omitir)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _omitirPago,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: Locale('es', 'ES'),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _confirmarPago() async {
    // Validar importe
    final importe = double.tryParse(_importeController.text);
    if (importe == null || importe <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor ingresa un importe válido'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Confirmando pago...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final uuid = Uuid();
      final gastoId = uuid.v4();
      final ahora = DateTime.now();

      // 1. Crear el gasto
      final gasto = GastoModel(
        id: gastoId,
        nombre: _configuracion!.nombreGasto,
        importe: importe,
        fecha: _fechaSeleccionada!,
        categoriaId: _configuracion!.categoriaId,
        empresaId: _configuracion!.empresaId,
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
        configuracionRecurrenciaId: _configuracion!.id,
        createdAt: ahora,
        updatedAt: ahora,
      );

      await _gastosRepository.insertGasto(gasto);

      // 2. Actualizar instancia como CONFIRMADA
      final instanciaActualizada = _instancia!.copyWith(
        estado: EstadoInstancia.CONFIRMADA,
        gastoId: gastoId,
        importeReal: importe,
        fechaConfirmacion: ahora,
        updatedAt: ahora,
      );

      await _databaseHelper.updateInstanciaRecurrente(
        instanciaActualizada.toMap(),
      );

      // Cerrar loading
      Navigator.of(context).pop();

      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Pago confirmado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Recargar gastos del mes
      context.read<GastosBloc>().add(
        LoadGastos(
          mes: _fechaSeleccionada!.month,
          anio: _fechaSeleccionada!.year,
        ),
      );

      // Volver a home
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      });
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al confirmar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _omitirPago() async {
    // Confirmar omisión
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Omitir este pago'),
        content: Text(
          '¿Estás seguro de que NO realizaste este pago?\n\n'
          'Esta instancia se marcará como omitida y no se creará ningún gasto.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Omitir', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // Actualizar instancia como OMITIDA
      final instanciaActualizada = _instancia!.copyWith(
        estado: EstadoInstancia.OMITIDA,
        fechaConfirmacion: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateInstanciaRecurrente(
        instanciaActualizada.toMap(),
      );

      // Cerrar loading
      Navigator.of(context).pop();

      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago omitido'), backgroundColor: Colors.orange),
      );

      // Volver a home
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      });
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al omitir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
