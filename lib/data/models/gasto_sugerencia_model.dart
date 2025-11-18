import 'package:equatable/equatable.dart';

/// Modelo para sugerencias de autocompletado de gastos
class GastoSugerenciaModel extends Equatable {
  final String nombre;
  final String categoriaId;
  final String categoriaNombre;
  final String? empresaId;
  final String? empresaNombre;
  final String? ultimaNota;

  const GastoSugerenciaModel({
    required this.nombre,
    required this.categoriaId,
    required this.categoriaNombre,
    this.empresaId,
    this.empresaNombre,
    this.ultimaNota,
  });

  /// Crea una instancia desde un Map
  factory GastoSugerenciaModel.fromMap(Map<String, dynamic> map) {
    return GastoSugerenciaModel(
      nombre: map['nombre'] as String,
      categoriaId: map['categoria_id'] as String,
      categoriaNombre: map['categoria_nombre'] as String,
      empresaId: map['empresa_id'] as String?,
      empresaNombre: map['empresa_nombre'] as String?,
      ultimaNota: map['notas'] as String?,
    );
  }

  /// Devuelve una representación para mostrar en el dropdown
  String get displayText {
    if (empresaNombre != null) {
      return '$nombre - $categoriaNombre / $empresaNombre';
    }
    return '$nombre - $categoriaNombre';
  }

  @override
  List<Object?> get props => [
    nombre,
    categoriaId,
    categoriaNombre,
    empresaId,
    empresaNombre,
    ultimaNota,
  ];

  @override
  String toString() {
    return 'GastoSugerenciaModel(nombre: $nombre, categoria: $categoriaNombre, empresa: $empresaNombre)';
  }
}
