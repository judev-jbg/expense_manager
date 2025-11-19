import 'package:equatable/equatable.dart';

/// Estados posibles de una instancia recurrente
enum EstadoInstancia {
  PENDIENTE, // Aún no notificada o esperando confirmación
  CONFIRMADA, // Usuario confirmó el gasto
  OMITIDA, // Usuario omitió esta ocurrencia
  SALTADA, // Se saltó automáticamente (3+ intentos de notificación)
}

/// Modelo para una instancia individual de un gasto recurrente
class InstanciaRecurrenteModel extends Equatable {
  final String id;
  final String configuracionRecurrenciaId;
  final DateTime fechaEsperada; // Día que "debió" ocurrir el gasto
  final DateTime
  fechaNotificacion; // Día que se notificará (fechaEsperada + N días)
  final DateTime? fechaConfirmacion; // Cuándo se confirmó
  final String? gastoId; // ID del gasto real cuando se confirma
  final double? importeReal; // Importe real (puede diferir del base)
  final EstadoInstancia estado;
  final int intentosNotificacion; // Contador de notificaciones enviadas
  final DateTime createdAt;
  final DateTime updatedAt;

  const InstanciaRecurrenteModel({
    required this.id,
    required this.configuracionRecurrenciaId,
    required this.fechaEsperada,
    required this.fechaNotificacion,
    this.fechaConfirmacion,
    this.gastoId,
    this.importeReal,
    required this.estado,
    this.intentosNotificacion = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una instancia desde un Map (de SQLite)
  factory InstanciaRecurrenteModel.fromMap(Map<String, dynamic> map) {
    return InstanciaRecurrenteModel(
      id: map['id'] as String,
      configuracionRecurrenciaId: map['configuracion_recurrencia_id'] as String,
      fechaEsperada: DateTime.fromMillisecondsSinceEpoch(
        map['fecha_esperada'] as int,
      ),
      fechaNotificacion: DateTime.fromMillisecondsSinceEpoch(
        map['fecha_notificacion'] as int,
      ),
      fechaConfirmacion: map['fecha_confirmacion'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['fecha_confirmacion'] as int,
            )
          : null,
      gastoId: map['gasto_id'] as String?,
      importeReal: map['importe_real'] as double?,
      estado: EstadoInstancia.values.firstWhere((e) => e.name == map['estado']),
      intentosNotificacion: map['intentos_notificacion'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convierte la instancia a Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'configuracion_recurrencia_id': configuracionRecurrenciaId,
      'fecha_esperada': fechaEsperada.millisecondsSinceEpoch,
      'fecha_notificacion': fechaNotificacion.millisecondsSinceEpoch,
      'fecha_confirmacion': fechaConfirmacion?.millisecondsSinceEpoch,
      'gasto_id': gastoId,
      'importe_real': importeReal,
      'estado': estado.name,
      'intentos_notificacion': intentosNotificacion,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  InstanciaRecurrenteModel copyWith({
    String? id,
    String? configuracionRecurrenciaId,
    DateTime? fechaEsperada,
    DateTime? fechaNotificacion,
    DateTime? fechaConfirmacion,
    String? gastoId,
    double? importeReal,
    EstadoInstancia? estado,
    int? intentosNotificacion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InstanciaRecurrenteModel(
      id: id ?? this.id,
      configuracionRecurrenciaId:
          configuracionRecurrenciaId ?? this.configuracionRecurrenciaId,
      fechaEsperada: fechaEsperada ?? this.fechaEsperada,
      fechaNotificacion: fechaNotificacion ?? this.fechaNotificacion,
      fechaConfirmacion: fechaConfirmacion ?? this.fechaConfirmacion,
      gastoId: gastoId ?? this.gastoId,
      importeReal: importeReal ?? this.importeReal,
      estado: estado ?? this.estado,
      intentosNotificacion: intentosNotificacion ?? this.intentosNotificacion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    configuracionRecurrenciaId,
    fechaEsperada,
    fechaNotificacion,
    fechaConfirmacion,
    gastoId,
    importeReal,
    estado,
    intentosNotificacion,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'InstanciaRecurrenteModel(id: $id, estado: $estado, fechaEsperada: $fechaEsperada)';
  }
}
