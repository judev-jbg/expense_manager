import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio para gestionar notificaciones locales
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // ✨ NUEVO: Callbacks estáticos
  static Function(String)? onNotificationTap;

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Inicializar zonas horarias
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Madrid'));

    // Configuración de Android con action buttons
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    print('✅ NotificationService inicializado');
  }

  /// Callback cuando se toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notificación tocada: ${response.payload}');
    print('🔔 Action ID: ${response.actionId}');

    if (response.payload != null &&
        response.payload!.startsWith('instancia_')) {
      final instanciaId = response.payload!.replaceFirst('instancia_', '');
      print('📋 Procesando instancia: $instanciaId');

      // Usar callback estático
      if (onNotificationTap != null) {
        onNotificationTap!(instanciaId);
      } else {
        print('⚠️ onNotificationTap callback no configurado');
      }
    }
  }

  /// Solicita todos los permisos necesarios
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    bool notificationGranted = true;
    if (androidPlugin != null) {
      notificationGranted =
          await androidPlugin.requestNotificationsPermission() ?? false;
    }

    bool scheduleGranted = await requestScheduleExactAlarmPermission();

    print(
      '📋 Permisos - Notificaciones: $notificationGranted, Alarmas: $scheduleGranted',
    );

    return notificationGranted && scheduleGranted;
  }

  /// Solicita permiso para programar alarmas exactas
  Future<bool> requestScheduleExactAlarmPermission() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestExactAlarmsPermission();
        return granted ?? true;
      }
      return true;
    } catch (e) {
      print('⚠️ Error al solicitar permiso de alarmas: $e');
      return true;
    }
  }

  /// Verifica si tiene permiso para alarmas exactas
  Future<bool> canScheduleExactAlarms() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final granted = await androidPlugin.canScheduleExactNotifications();
        return granted ?? true;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  /// Muestra una notificación inmediata
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'gastos_recurrentes',
      'Gastos Recurrentes',
      channelDescription: 'Notificaciones para gastos recurrentes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);

    print('✅ Notificación mostrada: $title');
  }

  /// Muestra notificación de gasto recurrente con botones de acción
  Future<void> showRecurrenteNotification({
    required int id,
    required String nombreGasto,
    required double importe,
    required String instanciaId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // ✨ NUEVO: Notificación con action buttons
    final androidDetails = AndroidNotificationDetails(
      'gastos_recurrentes',
      'Gastos Recurrentes',
      channelDescription: 'Notificaciones para gastos recurrentes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      // ✨ NUEVO: Action buttons
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'confirmar',
          '✓ Confirmar',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'ver',
          '👁 Ver detalles',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      '💰 $nombreGasto - Pago Recurrente',
      'Recuerda confirmar tu pago de €${importe.toStringAsFixed(2)}',
      details,
      payload: 'instancia_$instanciaId',
    );

    print('✅ Notificación recurrente enviada: $nombreGasto');
  }

  /// Programa una notificación para una fecha específica
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final canSchedule = await canScheduleExactAlarms();

    if (!canSchedule) {
      print('⚠️ No hay permiso para alarmas exactas. Solicitando...');
      final granted = await requestScheduleExactAlarmPermission();

      if (!granted) {
        print('❌ No se puede programar notificación sin permiso');
        throw Exception('Se requiere permiso de alarmas exactas');
      }
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'gastos_recurrentes',
      'Gastos Recurrentes',
      channelDescription: 'Notificaciones para gastos recurrentes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    print('✅ Notificación programada para: $scheduledDate');
  }

  /// Cancela una notificación por ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print('❌ Notificación cancelada: $id');
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('❌ Todas las notificaciones canceladas');
  }

  /// Obtiene notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Verifica si hay notificaciones pendientes
  Future<bool> hasPendingNotifications() async {
    final pending = await getPendingNotifications();
    return pending.isNotEmpty;
  }
}
