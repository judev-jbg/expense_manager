import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/categorias_repository.dart';
import 'categorias_event.dart';
import 'categorias_state.dart';

/// Bloc que gestiona el estado de las Categorías
class CategoriasBloc extends Bloc<CategoriasEvent, CategoriasState> {
  final CategoriasRepository _categoriasRepository;

  CategoriasBloc({required CategoriasRepository categoriasRepository})
    : _categoriasRepository = categoriasRepository,
      super(CategoriasInitial()) {
    on<LoadCategorias>(_onLoadCategorias);
    on<AddCategoria>(_onAddCategoria);
    on<UpdateCategoria>(_onUpdateCategoria);
    on<DeleteCategoria>(_onDeleteCategoria);
  }

  /// Maneja el evento de cargar categorías
  Future<void> _onLoadCategorias(
    LoadCategorias event,
    Emitter<CategoriasState> emit,
  ) async {
    emit(CategoriasLoading());
    try {
      final categorias = await _categoriasRepository.getAllCategorias();
      emit(CategoriasLoaded(categorias: categorias));
    } catch (e) {
      emit(
        CategoriasError(message: 'Error al cargar categorías: ${e.toString()}'),
      );
    }
  }

  /// Maneja el evento de agregar una categoría
  Future<void> _onAddCategoria(
    AddCategoria event,
    Emitter<CategoriasState> emit,
  ) async {
    try {
      await _categoriasRepository.insertCategoria(event.categoria);
      add(LoadCategorias()); // Recargar categorías
    } catch (e) {
      emit(
        CategoriasError(message: 'Error al agregar categoría: ${e.toString()}'),
      );
    }
  }

  /// Maneja el evento de actualizar una categoría
  Future<void> _onUpdateCategoria(
    UpdateCategoria event,
    Emitter<CategoriasState> emit,
  ) async {
    try {
      await _categoriasRepository.updateCategoria(event.categoria);
      add(LoadCategorias()); // Recargar categorías
    } catch (e) {
      emit(
        CategoriasError(
          message: 'Error al actualizar categoría: ${e.toString()}',
        ),
      );
    }
  }

  /// Maneja el evento de eliminar una categoría
  Future<void> _onDeleteCategoria(
    DeleteCategoria event,
    Emitter<CategoriasState> emit,
  ) async {
    try {
      await _categoriasRepository.deleteCategoria(event.id);
      add(LoadCategorias()); // Recargar categorías
    } catch (e) {
      emit(
        CategoriasError(
          message: 'Error al eliminar categoría: ${e.toString()}',
        ),
      );
    }
  }
}
