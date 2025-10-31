import 'package:equatable/equatable.dart';
import '../../../data/models/categoria_model.dart';

/// Eventos del Bloc de Categorías
abstract class CategoriasEvent extends Equatable {
  const CategoriasEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar todas las categorías
class LoadCategorias extends CategoriasEvent {}

/// Evento para agregar una nueva categoría
class AddCategoria extends CategoriasEvent {
  final CategoriaModel categoria;

  const AddCategoria({required this.categoria});

  @override
  List<Object?> get props => [categoria];
}

/// Evento para actualizar una categoría
class UpdateCategoria extends CategoriasEvent {
  final CategoriaModel categoria;

  const UpdateCategoria({required this.categoria});

  @override
  List<Object?> get props => [categoria];
}

/// Evento para eliminar una categoría
class DeleteCategoria extends CategoriasEvent {
  final String id;

  const DeleteCategoria({required this.id});

  @override
  List<Object?> get props => [id];
}
