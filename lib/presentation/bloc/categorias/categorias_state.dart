import 'package:equatable/equatable.dart';
import '../../../data/models/categoria_model.dart';

/// Estados del Bloc de Categorías
abstract class CategoriasState extends Equatable {
  const CategoriasState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class CategoriasInitial extends CategoriasState {}

/// Estado de carga
class CategoriasLoading extends CategoriasState {}

/// Estado cuando las categorías se cargaron exitosamente
class CategoriasLoaded extends CategoriasState {
  final List<CategoriaModel> categorias;

  const CategoriasLoaded({required this.categorias});

  @override
  List<Object?> get props => [categorias];
}

/// Estado de error
class CategoriasError extends CategoriasState {
  final String message;

  const CategoriasError({required this.message});

  @override
  List<Object?> get props => [message];
}
