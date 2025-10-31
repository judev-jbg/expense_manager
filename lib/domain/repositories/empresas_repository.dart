import '../../data/models/empresa_model.dart';

/// Contrato del repositorio de Empresas
abstract class EmpresasRepository {
  /// Obtiene todas las empresas activas de una categoría
  Future<List<EmpresaModel>> getEmpresasPorCategoria(String categoriaId);

  /// Obtiene todas las empresas (activas e inactivas)
  Future<List<EmpresaModel>> getAllEmpresas();

  /// Obtiene una empresa por ID
  Future<EmpresaModel?> getEmpresaById(String id);

  /// Inserta una nueva empresa
  Future<void> insertEmpresa(EmpresaModel empresa);

  /// Actualiza una empresa existente
  Future<void> updateEmpresa(EmpresaModel empresa);

  /// Elimina una empresa
  Future<void> deleteEmpresa(String id);
}
