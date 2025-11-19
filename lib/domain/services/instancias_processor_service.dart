import '../../core/database/database_helper.dart';
import '../../data/models/configuracion_recurrencia_model.dart';
import '../../data/models/instancia_recurrente_model.dart';
import 'notification_service.dart';
import 'generador_instancias_service.dart';

/// Servicio que procesa instancias recurrentes y programa notificaciones
class InstanciasProcessorService {
  final _databaseHelper = DatabaseHelper();
  final _notificationService = NotificationService();
  final _generadorInstancias = GeneradorInstanciasService();

  /// Procesa todas las instancias pendientes y programa notificaciones
  Future<void> procesarInstanciasPendientes() async {
    print('\n🔄 Iniciando procesamiento de instancias pendientes...');

    try {
      // 1. Obtener instancias pendientes de hoy
      final instanciasPendientesHoy = await _databaseHelper
          .getInstanciasPendientesHoy();

      print('📋 Instancias pendientes hoy: ${instanciasPendientesHoy.length}');

      // 2. Procesar cada instancia y programar notificación
      for (var instanciaMap in instanciasPendientesHoy) {
        await _procesarYNotificarInstancia(instanciaMap);
      }

      // 3. Verificar instancias que necesitan re-notificación
      await _procesarRenotificaciones();

      // 4. Marcar como SALTADA las instancias con 3+ intentos
      await _marcarInstanciasVencidas();

      // 5. Generar nuevas instancias para configuraciones activas
      await _generarNuevasInstancias();

      print('✅ Procesamiento completado\n');
    } catch (e) {
      print('❌ Error en procesamiento: $e');
    }
  }

  /// Procesa una instancia individual y programa su notificación
  Future<void> _procesarYNotificarInstancia(
    Map<String, dynamic> instanciaMap,
  ) async {
    try {
      final instancia = InstanciaRecurrenteModel.fromMap(instanciaMap);

      // Obtener configuración asociada
      final configMap = await _databaseHelper.getConfiguracionRecurrenciaById(
        instancia.configuracionRecurrenciaId,
      );

      if (configMap == null) {
        print('⚠️ Configuración no encontrada para instancia ${instancia.id}');
        return;
      }

      final configuracion = ConfiguracionRecurrenciaModel.fromMap(configMap);

      // Verificar que la configuración esté activa
      if (!configuracion.activa) {
        print('⏭️ Configuración inactiva, saltando instancia ${instancia.id}');
        return;
      }

      // Programar notificación
      final notificationId = instancia.id.hashCode.abs();

      await _notificationService.scheduleNotification(
        id: notificationId,
        title: '💰 ${configuracion.nombreGasto} - Pago Recurrente',
        body:
            'Recuerda confirmar tu pago de €${configuracion.importeBase.toStringAsFixed(2)}',
        scheduledDate: instancia.fechaNotificacion,
        payload: 'instancia_${instancia.id}',
      );

      // Incrementar contador de intentos
      final instanciaActualizada = instancia.copyWith(
        intentosNotificacion: instancia.intentosNotificacion + 1,
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateInstanciaRecurrente(
        instanciaActualizada.toMap(),
      );

      print('✅ Notificación programada para: ${configuracion.nombreGasto}');
    } catch (e) {
      print('❌ Error al procesar instancia: $e');
    }
  }

  /// Re-notifica instancias que aún están pendientes
  Future<void> _procesarRenotificaciones() async {
    try {
      final instanciasParaRenotificar = await _databaseHelper
          .getInstanciasParaRenotificacion();

      print(
        '🔔 Instancias para re-notificar: ${instanciasParaRenotificar.length}',
      );

      for (var instanciaMap in instanciasParaRenotificar) {
        final instancia = InstanciaRecurrenteModel.fromMap(instanciaMap);

        // Obtener configuración
        final configMap = await _databaseHelper.getConfiguracionRecurrenciaById(
          instancia.configuracionRecurrenciaId,
        );

        if (configMap == null) continue;

        final configuracion = ConfiguracionRecurrenciaModel.fromMap(configMap);

        // Re-notificar inmediatamente
        final notificationId = instancia.id.hashCode.abs();

        await _notificationService.showNotification(
          id: notificationId,
          title: '🔔 Recordatorio: ${configuracion.nombreGasto}',
          body:
              '¡No olvides confirmar tu pago de €${configuracion.importeBase.toStringAsFixed(2)}!',
          payload: 'instancia_${instancia.id}',
        );

        // Incrementar contador
        final instanciaActualizada = instancia.copyWith(
          intentosNotificacion: instancia.intentosNotificacion + 1,
          updatedAt: DateTime.now(),
        );

        await _databaseHelper.updateInstanciaRecurrente(
          instanciaActualizada.toMap(),
        );

        print('🔔 Re-notificación enviada: ${configuracion.nombreGasto}');
      }
    } catch (e) {
      print('❌ Error en re-notificaciones: $e');
    }
  }

  /// Marca como SALTADA las instancias con 3+ intentos
  Future<void> _marcarInstanciasVencidas() async {
    try {
      final marcadas = await _databaseHelper
          .marcarInstanciasVencidasComoSaltadas();

      if (marcadas > 0) {
        print('⏭️ Instancias marcadas como SALTADA: $marcadas');
      }
    } catch (e) {
      print('❌ Error al marcar instancias vencidas: $e');
    }
  }

  /// Genera nuevas instancias para configuraciones activas
  Future<void> _generarNuevasInstancias() async {
    try {
      final configuraciones = await _databaseHelper
          .getAllConfiguracionesRecurrencia(soloActivas: true);

      print('📝 Configuraciones activas: ${configuraciones.length}');

      for (var configMap in configuraciones) {
        final configuracion = ConfiguracionRecurrenciaModel.fromMap(configMap);

        // Obtener instancias existentes
        final instanciasExistentes = await _databaseHelper
            .getInstanciasPorConfiguracion(configuracion.id);

        // Contar instancias futuras (no confirmadas, no omitidas)
        final instanciasFuturas = instanciasExistentes.where((i) {
          final inst = InstanciaRecurrenteModel.fromMap(i);
          return inst.estado == EstadoInstancia.PENDIENTE &&
              inst.fechaEsperada.isAfter(DateTime.now());
        }).length;

        // Si hay menos de 3 instancias futuras, generar más
        if (instanciasFuturas < 3) {
          final faltantes = 3 - instanciasFuturas;

          await _generadorInstancias.generarYGuardarInstancias(
            configuracion,
            cantidadInstancias: faltantes,
          );

          print(
            '➕ Generadas $faltantes nuevas instancias para: ${configuracion.nombreGasto}',
          );
        }
      }
    } catch (e) {
      print('❌ Error al generar nuevas instancias: $e');
    }
  }

  /// Ejecuta el procesamiento completo (llamado por WorkManager)
  Future<bool> ejecutarProcesamientoDiario() async {
    try {
      print('⏰ Ejecutando procesamiento diario...');
      await procesarInstanciasPendientes();
      return true;
    } catch (e) {
      print('❌ Error en procesamiento diario: $e');
      return false;
    }
  }
}
