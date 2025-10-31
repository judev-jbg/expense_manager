import 'package:equatable/equatable.dart';
import 'gasto_model.dart';

/// Modelo extendido de Gasto que incluye los nombres de categoría y empresa
/// Útil para mostrar en la UI sin hacer múltiples queries
class GastoConDetallesModel extends Equatable {
  final GastoModel gasto;
  final String categoriaNombre;
  final String? empresaNombre; // Nullable

  const GastoConDetallesModel({
    required this.gasto,
    required this.categoriaNombre,
    this.empresaNombre,
  });

  /// Crea una instancia desde un Map con JOIN de tablas
  factory GastoConDetallesModel.fromMap(Map<String, dynamic> map) {
    return GastoConDetallesModel(
      gasto: GastoModel.fromMap(map),
      categoriaNombre: map['categoria_nombre'] as String,
      empresaNombre: map['empresa_nombre'] as String?,
    );
  }

  @override
  List<Object?> get props => [gasto, categoriaNombre, empresaNombre];

  @override
  String toString() {
    return 'GastoConDetallesModel(gasto: ${gasto.nombre}, categoria: $categoriaNombre, empresa: $empresaNombre)';
  }
}
