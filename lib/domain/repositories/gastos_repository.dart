import '../../data/models/gasto_model.dart';
import '../../data/models/gasto_con_detalles_model.dart';

/// Contrato del repositorio de Gastos
abstract class GastosRepository {
  /// Obtiene gastos de un mes específico
  Future<List<GastoModel>> getGastosPorMes(int mes, int anio);

  /// Obtiene gastos de un mes con detalles de categoría y empresa
  Future<List<GastoConDetallesModel>> getGastosConDetallesPorMes(
    int mes,
    int anio,
  );

  /// Obtiene todos los gastos
  Future<List<GastoModel>> getAllGastos();

  /// Busca nombres de gastos para autocompletado
  Future<List<Map<String, dynamic>>> buscarNombresGastos(String query);

  /// Obtiene un gasto por ID
  Future<GastoModel?> getGastoById(String id);

  /// Inserta un nuevo gasto
  Future<void> insertGasto(GastoModel gasto);

  /// Actualiza un gasto existente
  Future<void> updateGasto(GastoModel gasto);

  /// Elimina un gasto
  Future<void> deleteGasto(String id);

  /// Calcula el total gastado en un mes
  Future<double> getTotalMes(int mes, int anio);
}
