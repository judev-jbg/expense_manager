import '../../data/models/gasto_model.dart';
import '../../data/models/gasto_con_detalles_model.dart';
import '../../data/models/gasto_sugerencia_model.dart';
import '../../data/models/adjunto_model.dart';
import '../../data/models/analisis_categoria_model.dart';

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

  /// Busca sugerencias de gastos para autocompletado
  Future<List<GastoSugerenciaModel>> buscarSugerencias(String query);

  /// Obtiene todos los adjuntos de un gasto
  Future<List<AdjuntoModel>> getAdjuntosPorGasto(String gastoId);

  /// Inserta un nuevo adjunto
  Future<void> insertAdjunto(AdjuntoModel adjunto);

  /// Elimina un adjunto
  Future<void> deleteAdjunto(String id);

  /// Obtiene el análisis por categoría de un mes
  Future<List<AnalisisCategoriaModel>> getAnalisisPorCategoriaMes(
    int mes,
    int anio,
  );

  /// Obtiene el análisis por mes de un año
  Future<List<Map<String, dynamic>>> getAnalisisPorMesAnio(int anio);

  /// Obtiene el mayor gasto de un mes
  Future<Map<String, dynamic>?> getMayorGastoMes(int mes, int anio);

  /// Busca gastos con filtros avanzados
  Future<List<GastoConDetallesModel>> buscarGastosConFiltros({
    String? textoBusqueda,
    String? categoriaId,
    String? empresaId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });
}
