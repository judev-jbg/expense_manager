import '../../core/database/database_helper.dart';
import '../../domain/repositories/gastos_repository.dart';
import '../models/gasto_model.dart';
import '../models/gasto_con_detalles_model.dart';
import '../models/gasto_sugerencia_model.dart';
import '../models/adjunto_model.dart';
import '../models/analisis_categoria_model.dart';

/// Implementación del repositorio de Gastos
class GastosRepositoryImpl implements GastosRepository {
  final DatabaseHelper _databaseHelper;

  GastosRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  @override
  Future<List<GastoModel>> getGastosPorMes(int mes, int anio) async {
    try {
      final gastosMap = await _databaseHelper.getGastosPorMes(mes, anio);
      return gastosMap.map((map) => GastoModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener gastos por mes: $e');
    }
  }

  @override
  Future<List<GastoConDetallesModel>> getGastosConDetallesPorMes(
    int mes,
    int anio,
  ) async {
    try {
      final db = await _databaseHelper.database;

      // Calcular timestamps del inicio y fin del mes
      final inicioMes = DateTime(anio, mes, 1).millisecondsSinceEpoch;
      final finMes = DateTime(
        anio,
        mes + 1,
        0,
        23,
        59,
        59,
      ).millisecondsSinceEpoch;

      // Query con JOIN para obtener nombres de categoría y empresa
      final results = await db.rawQuery(
        '''
        SELECT 
          g.*,
          c.nombre as categoria_nombre,
          e.nombre as empresa_nombre
        FROM ${DatabaseHelper.tableGastos} g
        INNER JOIN ${DatabaseHelper.tableCategorias} c ON g.categoria_id = c.id
        LEFT JOIN ${DatabaseHelper.tableEmpresas} e ON g.empresa_id = e.id
        WHERE g.fecha >= ? AND g.fecha <= ?
        ORDER BY g.fecha DESC
      ''',
        [inicioMes, finMes],
      );

      return results.map((map) => GastoConDetallesModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener gastos con detalles: $e');
    }
  }

  @override
  Future<List<GastoModel>> getAllGastos() async {
    try {
      final gastosMap = await _databaseHelper.getAllGastos();
      return gastosMap.map((map) => GastoModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener todos los gastos: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> buscarNombresGastos(String query) async {
    try {
      return await _databaseHelper.buscarNombresGastos(query);
    } catch (e) {
      throw Exception('Error al buscar nombres de gastos: $e');
    }
  }

  @override
  Future<GastoModel?> getGastoById(String id) async {
    try {
      final gastoMap = await _databaseHelper.getGastoById(id);
      if (gastoMap == null) return null;
      return GastoModel.fromMap(gastoMap);
    } catch (e) {
      throw Exception('Error al obtener gasto por ID: $e');
    }
  }

  @override
  Future<void> insertGasto(GastoModel gasto) async {
    try {
      await _databaseHelper.insertGasto(gasto.toMap());
    } catch (e) {
      throw Exception('Error al insertar gasto: $e');
    }
  }

  @override
  Future<void> updateGasto(GastoModel gasto) async {
    try {
      final result = await _databaseHelper.updateGasto(gasto.toMap());
      if (result == 0) {
        throw Exception('No se encontró el gasto para actualizar');
      }
    } catch (e) {
      throw Exception('Error al actualizar gasto: $e');
    }
  }

  @override
  Future<void> deleteGasto(String id) async {
    try {
      final result = await _databaseHelper.deleteGasto(id);
      if (result == 0) {
        throw Exception('No se encontró el gasto para eliminar');
      }
    } catch (e) {
      throw Exception('Error al eliminar gasto: $e');
    }
  }

  @override
  Future<double> getTotalMes(int mes, int anio) async {
    try {
      return await _databaseHelper.getTotalMes(mes, anio);
    } catch (e) {
      throw Exception('Error al calcular total del mes: $e');
    }
  }

  @override
  Future<List<GastoSugerenciaModel>> buscarSugerencias(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final results = await _databaseHelper.buscarNombresGastos(query);

      return results.map((map) => GastoSugerenciaModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al buscar sugerencias: $e');
    }
  }

  @override
  Future<List<AdjuntoModel>> getAdjuntosPorGasto(String gastoId) async {
    try {
      final adjuntosMap = await _databaseHelper.getAdjuntosPorGasto(gastoId);
      return adjuntosMap.map((map) => AdjuntoModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener adjuntos: $e');
    }
  }

  @override
  Future<void> insertAdjunto(AdjuntoModel adjunto) async {
    try {
      await _databaseHelper.insertAdjunto(adjunto.toMap());
    } catch (e) {
      throw Exception('Error al insertar adjunto: $e');
    }
  }

  @override
  Future<void> deleteAdjunto(String id) async {
    try {
      final result = await _databaseHelper.deleteAdjunto(id);
      if (result == 0) {
        throw Exception('No se encontró el adjunto para eliminar');
      }
    } catch (e) {
      throw Exception('Error al eliminar adjunto: $e');
    }
  }

  @override
  Future<List<AnalisisCategoriaModel>> getAnalisisPorCategoriaMes(
    int mes,
    int anio,
  ) async {
    try {
      final analisisMap = await _databaseHelper.getAnalisisPorCategoriaMes(
        mes,
        anio,
      );
      return analisisMap
          .map((map) => AnalisisCategoriaModel.fromMap(map))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener análisis por categoría: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAnalisisPorMesAnio(int anio) async {
    try {
      return await _databaseHelper.getAnalisisPorMesAnio(anio);
    } catch (e) {
      throw Exception('Error al obtener análisis por mes: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getMayorGastoMes(int mes, int anio) async {
    try {
      return await _databaseHelper.getMayorGastoMes(mes, anio);
    } catch (e) {
      throw Exception('Error al obtener mayor gasto: $e');
    }
  }

  @override
  Future<List<GastoConDetallesModel>> buscarGastosConFiltros({
    String? textoBusqueda,
    String? categoriaId,
    String? empresaId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final resultados = await _databaseHelper.buscarGastosConFiltros(
        textoBusqueda: textoBusqueda,
        categoriaId: categoriaId,
        empresaId: empresaId,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );

      return resultados
          .map((map) => GastoConDetallesModel.fromMap(map))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar gastos: $e');
    }
  }
}
