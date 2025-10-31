import '../../core/database/database_helper.dart';
import '../../domain/repositories/empresas_repository.dart';
import '../models/empresa_model.dart';

/// Implementación del repositorio de Empresas
class EmpresasRepositoryImpl implements EmpresasRepository {
  final DatabaseHelper _databaseHelper;

  EmpresasRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  @override
  Future<List<EmpresaModel>> getEmpresasPorCategoria(String categoriaId) async {
    try {
      final empresasMap = await _databaseHelper.getEmpresasPorCategoria(
        categoriaId,
      );
      return empresasMap.map((map) => EmpresaModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener empresas por categoría: $e');
    }
  }

  @override
  Future<List<EmpresaModel>> getAllEmpresas() async {
    try {
      final empresasMap = await _databaseHelper.getAllEmpresas();
      return empresasMap.map((map) => EmpresaModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener todas las empresas: $e');
    }
  }

  @override
  Future<EmpresaModel?> getEmpresaById(String id) async {
    try {
      final empresaMap = await _databaseHelper.getEmpresaById(id);
      if (empresaMap == null) return null;
      return EmpresaModel.fromMap(empresaMap);
    } catch (e) {
      throw Exception('Error al obtener empresa por ID: $e');
    }
  }

  @override
  Future<void> insertEmpresa(EmpresaModel empresa) async {
    try {
      await _databaseHelper.insertEmpresa(empresa.toMap());
    } catch (e) {
      throw Exception('Error al insertar empresa: $e');
    }
  }

  @override
  Future<void> updateEmpresa(EmpresaModel empresa) async {
    try {
      final result = await _databaseHelper.updateEmpresa(empresa.toMap());
      if (result == 0) {
        throw Exception('No se encontró la empresa para actualizar');
      }
    } catch (e) {
      throw Exception('Error al actualizar empresa: $e');
    }
  }

  @override
  Future<void> deleteEmpresa(String id) async {
    try {
      final result = await _databaseHelper.deleteEmpresa(id);
      if (result == 0) {
        throw Exception('No se encontró la empresa para eliminar');
      }
    } catch (e) {
      throw Exception('Error al eliminar empresa: $e');
    }
  }
}
