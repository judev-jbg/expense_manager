import 'package:equatable/equatable.dart';

/// Modelo de datos para un Gasto
class GastoModel extends Equatable {
  final String id;
  final String nombre;
  final double importe;
  final DateTime fecha;
  final String categoriaId;
  final String? empresaId;
  final String? notas;
  final String? configuracionRecurrenciaId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GastoModel({
    required this.id,
    required this.nombre,
    required this.importe,
    required this.fecha,
    required this.categoriaId,
    this.empresaId,
    this.notas,
    this.configuracionRecurrenciaId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una instancia desde un Map (de SQLite)
  factory GastoModel.fromMap(Map<String, dynamic> map) {
    return GastoModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      importe: map['importe'] as double,
      fecha: DateTime.fromMillisecondsSinceEpoch(map['fecha'] as int),
      categoriaId: map['categoria_id'] as String,
      empresaId: map['empresa_id'] as String?,
      notas: map['notas'] as String?,
      configuracionRecurrenciaId:
          map['configuracion_recurrencia_id'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convierte la instancia a Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'importe': importe,
      'fecha': fecha.millisecondsSinceEpoch,
      'categoria_id': categoriaId,
      'empresa_id': empresaId,
      'notas': notas,
      'configuracion_recurrencia_id': configuracionRecurrenciaId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Crea una copia con valores modificados
  GastoModel copyWith({
    String? id,
    String? nombre,
    double? importe,
    DateTime? fecha,
    String? categoriaId,
    String? empresaId,
    String? notas,
    String? configuracionRecurrenciaId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GastoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      importe: importe ?? this.importe,
      fecha: fecha ?? this.fecha,
      categoriaId: categoriaId ?? this.categoriaId,
      empresaId: empresaId ?? this.empresaId,
      notas: notas ?? this.notas,
      configuracionRecurrenciaId:
          configuracionRecurrenciaId ?? this.configuracionRecurrenciaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    importe,
    fecha,
    categoriaId,
    empresaId,
    notas,
    configuracionRecurrenciaId,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'GastoModel(id: $id, nombre: $nombre, importe: $importe, fecha: $fecha, categoriaId: $categoriaId, esRecurrente: ${configuracionRecurrenciaId != null})';
  }
}
