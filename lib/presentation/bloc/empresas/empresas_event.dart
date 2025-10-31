import 'package:equatable/equatable.dart';
import '../../../data/models/empresa_model.dart';

/// Eventos del Bloc de Empresas
abstract class EmpresasEvent extends Equatable {
  const EmpresasEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar empresas de una categoría
class LoadEmpresasPorCategoria extends EmpresasEvent {
  final String categoriaId;

  const LoadEmpresasPorCategoria({required this.categoriaId});

  @override
  List<Object?> get props => [categoriaId];
}

/// Evento para cargar todas las empresas
class LoadAllEmpresas extends EmpresasEvent {}

/// Evento para agregar una nueva empresa
class AddEmpresa extends EmpresasEvent {
  final EmpresaModel empresa;

  const AddEmpresa({required this.empresa});

  @override
  List<Object?> get props => [empresa];
}

/// Evento para actualizar una empresa
class UpdateEmpresa extends EmpresasEvent {
  final EmpresaModel empresa;

  const UpdateEmpresa({required this.empresa});

  @override
  List<Object?> get props => [empresa];
}

/// Evento para eliminar una empresa
class DeleteEmpresa extends EmpresasEvent {
  final String id;

  const DeleteEmpresa({required this.id});

  @override
  List<Object?> get props => [id];
}
