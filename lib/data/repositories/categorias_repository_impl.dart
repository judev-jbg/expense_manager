import '../../core/database/database_helper.dart';
import '../../domain/repositories/categorias_repository.dart';
import '../models/categoria_model.dart';

/// Implementación del repositorio de Categorías
class CategoriasRepositoryImpl implements CategoriasRepository {
  final DatabaseHelper _databaseHelper;

  CategoriasRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  @override
  Future<List<CategoriaModel>> getAllCategorias() async {
    try {
      final categoriasMap = await _databaseHelper.getAllCategorias();
      return categoriasMap.map((map) => CategoriaModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  @override
  Future<CategoriaModel?> getCategoriaById(String id) async {
    try {
      final categoriaMap = await _databaseHelper.getCategoriaById(id);
      if (categoriaMap == null) return null;
      return CategoriaModel.fromMap(categoriaMap);
    } catch (e) {
      throw Exception('Error al obtener categoría por ID: $e');
    }
  }

  @override
  Future<void> insertCategoria(CategoriaModel categoria) async {
    try {
      await _databaseHelper.insertCategoria(categoria.toMap());
    } catch (e) {
      throw Exception('Error al insertar categoría: $e');
    }
  }

  @override
  Future<void> updateCategoria(CategoriaModel categoria) async {
    try {
      final result = await _databaseHelper.updateCategoria(categoria.toMap());
      if (result == 0) {
        throw Exception('No se encontró la categoría para actualizar');
      }
    } catch (e) {
      throw Exception('Error al actualizar categoría: $e');
    }
  }

  @override
  Future<void> deleteCategoria(String id) async {
    try {
      final result = await _databaseHelper.deleteCategoria(id);
      if (result == 0) {
        throw Exception('No se encontró la categoría para eliminar');
      }
    } catch (e) {
      throw Exception('Error al eliminar categoría: $e');
    }
  }
}
