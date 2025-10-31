import 'package:equatable/equatable.dart';

/// Modelo de datos para una Empresa
class EmpresaModel extends Equatable {
  final String id;
  final String nombre;
  final String categoriaId;
  final bool activa;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmpresaModel({
    required this.id,
    required this.nombre,
    required this.categoriaId,
    required this.activa,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una instancia desde un Map (de SQLite)
  factory EmpresaModel.fromMap(Map<String, dynamic> map) {
    return EmpresaModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      categoriaId: map['categoria_id'] as String,
      activa: (map['activa'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convierte la instancia a Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria_id': categoriaId,
      'activa': activa ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Crea una copia con valores modificados
  EmpresaModel copyWith({
    String? id,
    String? nombre,
    String? categoriaId,
    bool? activa,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmpresaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoriaId: categoriaId ?? this.categoriaId,
      activa: activa ?? this.activa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    categoriaId,
    activa,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'EmpresaModel(id: $id, nombre: $nombre, categoriaId: $categoriaId, activa: $activa)';
  }
}
