import 'package:equatable/equatable.dart';

/// Modelo para datos de análisis por categoría
class AnalisisCategoriaModel extends Equatable {
  final String categoriaId;
  final String categoriaNombre;
  final String categoriaIcono;
  final String categoriaColor;
  final double totalGastado;
  final int cantidadGastos;

  const AnalisisCategoriaModel({
    required this.categoriaId,
    required this.categoriaNombre,
    required this.categoriaIcono,
    required this.categoriaColor,
    required this.totalGastado,
    required this.cantidadGastos,
  });

  /// Crea una instancia desde un Map
  factory AnalisisCategoriaModel.fromMap(Map<String, dynamic> map) {
    return AnalisisCategoriaModel(
      categoriaId: map['categoria_id'] as String,
      categoriaNombre: map['categoria_nombre'] as String,
      categoriaIcono: map['categoria_icono'] as String,
      categoriaColor: map['categoria_color'] as String,
      totalGastado: map['total_gastado'] as double,
      cantidadGastos: map['cantidad_gastos'] as int,
    );
  }

  /// Calcula el promedio de gasto por transacción
  double get promedioGasto {
    if (cantidadGastos == 0) return 0;
    return totalGastado / cantidadGastos;
  }

  @override
  List<Object?> get props => [
    categoriaId,
    categoriaNombre,
    categoriaIcono,
    categoriaColor,
    totalGastado,
    cantidadGastos,
  ];

  @override
  String toString() {
    return 'AnalisisCategoriaModel(categoria: $categoriaNombre, total: €$totalGastado, cantidad: $cantidadGastos)';
  }
}
