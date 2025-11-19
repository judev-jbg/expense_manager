import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../../core/database/database_helper.dart';
import '../../data/models/configuracion_recurrencia_model.dart';
import '../../data/models/instancia_recurrente_model.dart';
import 'notification_service.dart';
import 'generador_instancias_service.dart';

/// Servicio para gestionar tareas en background de gastos recurrentes
class RecurrentesBackgroundService {
  static const int DAILY_CHECK_ID = 1;
  static const String DAILY_CHECK_NAME = 'daily_recurrentes_check';

  /// Inicializa el servicio de alarmas
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
    print('✅ AndroidAlarmManager inicializado');
  }

  /// Programa la verificación diaria de instancias recurrentes
  /// Se ejecutará todos los días a las 9:00 AM
  static Future<void> scheduleDailyCheck() async {
    try {
      // Calcular las 9:00 AM de mañana
      final now = DateTime.now();
      final tomorrow9AM = DateTime(
        now.year,
        now.month,
        now.day + 1,
        9, // 9:00 AM
        0,
        0,
      );

      await AndroidAlarmManager.periodic(
        const Duration(days: 1),
        DAILY_CHECK_ID,
        dailyCheckCallback,
        startAt: tomorrow9AM,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );

      print('✅ Verificación diaria programada para las 9:00 AM');
    } catch (e) {
      print('❌ Error al programar verificación diaria: $e');
    }
  }

  /// Cancela la verificación diaria
  static Future<void> cancelDailyCheck() async {
    await AndroidAlarmManager.cancel(DAILY_CHECK_ID);
    print('❌ Verificación diaria cancelada');
  }

  /// Callback que se ejecuta diariamente
  /// IMPORTANTE: Debe ser una función top-level o static
  @pragma('vm:entry-point')
  static Future<void> dailyCheckCallback() async {
    print('\n========================================');
    print('🔄 EJECUTANDO VERIFICACIÓN DIARIA');
    print('Hora: ${DateTime.now()}');
    print('========================================\n');

    try {
      await _verificarYNotificarInstanciasPendientes();
      await _generarNuevasInstanciasParaConfiguracionesActivas();
      await _marcarInstanciasVencidasComoSaltadas();
    } catch (e) {
      print('❌ Error en verificación diaria: $e');
    }

    print('\n========================================');
    print('✅ VERIFICACIÓN DIARIA COMPLETADA');
    print('========================================\n');
  }

  /// Verifica instancias pendientes que necesitan notificación HOY
  static Future<void> _verificarYNotificarInstanciasPendientes() async {
    final dbHelper = DatabaseHelper();

    // 1. Obtener instancias que deben notificarse hoy
    final instanciasPendientes = await dbHelper.getInstanciasPendientesHoy();

    print('📋 Instancias pendientes para hoy: ${instanciasPendientes.length}');

    if (instanciasPendientes.isEmpty) {
      print('✅ No hay instancias pendientes para notificar');
      return;
    }

    final notificationService = NotificationService();
    await notificationService.initialize();

    // 2. Procesar cada instancia
    for (var instanciaMap in instanciasPendientes) {
      try {
        final instancia = InstanciaRecurrenteModel.fromMap(instanciaMap);

        // Obtener configuración asociada
        final configMap = await dbHelper.getConfiguracionRecurrenciaById(
          instancia.configuracionRecurrenciaId,
        );

        if (configMap == null) {
          print(
            '⚠️ Configuración no encontrada para instancia ${instancia.id}',
          );
          continue;
        }

        final config = ConfiguracionRecurrenciaModel.fromMap(configMap);

        // Enviar notificación
        await notificationService.showRecurrenteNotification(
          id: instancia.id.hashCode,
          nombreGasto: config.nombreGasto,
          importe: config.importeBase,
          instanciaId: instancia.id,
        );

        // Incrementar contador de intentos
        final instanciaActualizada = instancia.copyWith(
          intentosNotificacion: instancia.intentosNotificacion + 1,
          updatedAt: DateTime.now(),
        );

        await dbHelper.updateInstanciaRecurrente(instanciaActualizada.toMap());

        print(
          '✅ Notificación enviada para: ${config.nombreGasto} (intento ${instanciaActualizada.intentosNotificacion})',
        );
      } catch (e) {
        print('❌ Error al procesar instancia: $e');
      }
    }
  }

  /// Genera nuevas instancias para configuraciones activas que lo necesiten
  static Future<void>
  _generarNuevasInstanciasParaConfiguracionesActivas() async {
    final dbHelper = DatabaseHelper();
    final generador = GeneradorInstanciasService();

    // Obtener todas las configuraciones activas
    final configuracionesActivas = await dbHelper
        .getAllConfiguracionesRecurrencia(soloActivas: true);

    print('📋 Configuraciones activas: ${configuracionesActivas.length}');

    for (var configMap in configuracionesActivas) {
      try {
        final config = ConfiguracionRecurrenciaModel.fromMap(configMap);

        // Verificar si esta configuración necesita más instancias
        final instanciasExistentes = await dbHelper
            .getInstanciasPorConfiguracion(config.id);

        // Contar solo instancias PENDIENTES futuras
        final instanciasPendientesFuturas = instanciasExistentes.where((i) {
          final instancia = InstanciaRecurrenteModel.fromMap(i);
          return instancia.estado == EstadoInstancia.PENDIENTE &&
              instancia.fechaEsperada.isAfter(DateTime.now());
        }).length;

        // Si tiene menos de 3 instancias pendientes futuras, generar más
        if (instanciasPendientesFuturas < 3) {
          final cantidadAGenerar = 3 - instanciasPendientesFuturas;

          await generador.generarYGuardarInstancias(
            config,
            cantidadInstancias: cantidadAGenerar,
          );

          print(
            '✅ Se generaron $cantidadAGenerar instancia(s) para: ${config.nombreGasto}',
          );
        }
      } catch (e) {
        print('❌ Error al generar instancias: $e');
      }
    }
  }

  /// Marca como SALTADA las instancias con 3+ intentos de notificación
  static Future<void> _marcarInstanciasVencidasComoSaltadas() async {
    final dbHelper = DatabaseHelper();

    final cantidadMarcadas = await dbHelper
        .marcarInstanciasVencidasComoSaltadas();

    if (cantidadMarcadas > 0) {
      print('⚠️ Se marcaron $cantidadMarcadas instancia(s) como SALTADA');
    }
  }

  /// Ejecuta verificación manual (para testing)
  static Future<void> executeManualCheck() async {
    print('\n🔧 EJECUTANDO VERIFICACIÓN MANUAL');
    await dailyCheckCallback();
  }
}
