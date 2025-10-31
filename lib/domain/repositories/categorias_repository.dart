import '../../data/models/categoria_model.dart';

/// Contrato del repositorio de Categorías
abstract class CategoriasRepository {
  /// Obtiene todas las categorías ordenadas
  Future<List<CategoriaModel>> getAllCategorias();

  /// Obtiene una categoría por ID
  Future<CategoriaModel?> getCategoriaById(String id);

  /// Inserta una nueva categoría
  Future<void> insertCategoria(CategoriaModel categoria);

  /// Actualiza una categoría existente
  Future<void> updateCategoria(CategoriaModel categoria);

  /// Elimina una categoría
  Future<void> deleteCategoria(String id);
}
