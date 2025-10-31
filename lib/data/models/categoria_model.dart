import 'package:equatable/equatable.dart';

/// Modelo de datos para una Categoría
class CategoriaModel extends Equatable {
  final String id;
  final String nombre;
  final String icono;
  final String color;
  final int orden;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoriaModel({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.color,
    required this.orden,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una instancia desde un Map (de SQLite)
  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    return CategoriaModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      icono: map['icono'] as String,
      color: map['color'] as String,
      orden: map['orden'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convierte la instancia a Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'icono': icono,
      'color': color,
      'orden': orden,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Crea una copia con valores modificados
  CategoriaModel copyWith({
    String? id,
    String? nombre,
    String? icono,
    String? color,
    int? orden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoriaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      orden: orden ?? this.orden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    icono,
    color,
    orden,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'CategoriaModel(id: $id, nombre: $nombre, icono: $icono, color: $color)';
  }
}
