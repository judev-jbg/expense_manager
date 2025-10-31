import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/empresas_repository.dart';
import 'empresas_event.dart';
import 'empresas_state.dart';

/// Bloc que gestiona el estado de las Empresas
class EmpresasBloc extends Bloc<EmpresasEvent, EmpresasState> {
  final EmpresasRepository _empresasRepository;

  EmpresasBloc({required EmpresasRepository empresasRepository})
    : _empresasRepository = empresasRepository,
      super(EmpresasInitial()) {
    on<LoadEmpresasPorCategoria>(_onLoadEmpresasPorCategoria);
    on<LoadAllEmpresas>(_onLoadAllEmpresas);
    on<AddEmpresa>(_onAddEmpresa);
    on<UpdateEmpresa>(_onUpdateEmpresa);
    on<DeleteEmpresa>(_onDeleteEmpresa);
  }

  /// Maneja el evento de cargar empresas por categoría
  Future<void> _onLoadEmpresasPorCategoria(
    LoadEmpresasPorCategoria event,
    Emitter<EmpresasState> emit,
  ) async {
    emit(EmpresasLoading());
    try {
      final empresas = await _empresasRepository.getEmpresasPorCategoria(
        event.categoriaId,
      );
      emit(EmpresasLoaded(empresas: empresas));
    } catch (e) {
      emit(EmpresasError(message: 'Error al cargar empresas: ${e.toString()}'));
    }
  }

  /// Maneja el evento de cargar todas las empresas
  Future<void> _onLoadAllEmpresas(
    LoadAllEmpresas event,
    Emitter<EmpresasState> emit,
  ) async {
    emit(EmpresasLoading());
    try {
      final empresas = await _empresasRepository.getAllEmpresas();
      emit(EmpresasLoaded(empresas: empresas));
    } catch (e) {
      emit(EmpresasError(message: 'Error al cargar empresas: ${e.toString()}'));
    }
  }

  /// Maneja el evento de agregar una empresa
  Future<void> _onAddEmpresa(
    AddEmpresa event,
    Emitter<EmpresasState> emit,
  ) async {
    try {
      await _empresasRepository.insertEmpresa(event.empresa);
      // Recargar empresas de la misma categoría
      add(LoadEmpresasPorCategoria(categoriaId: event.empresa.categoriaId));
    } catch (e) {
      emit(EmpresasError(message: 'Error al agregar empresa: ${e.toString()}'));
    }
  }

  /// Maneja el evento de actualizar una empresa
  Future<void> _onUpdateEmpresa(
    UpdateEmpresa event,
    Emitter<EmpresasState> emit,
  ) async {
    try {
      await _empresasRepository.updateEmpresa(event.empresa);
      // Recargar empresas de la misma categoría
      add(LoadEmpresasPorCategoria(categoriaId: event.empresa.categoriaId));
    } catch (e) {
      emit(
        EmpresasError(message: 'Error al actualizar empresa: ${e.toString()}'),
      );
    }
  }

  /// Maneja el evento de eliminar una empresa
  Future<void> _onDeleteEmpresa(
    DeleteEmpresa event,
    Emitter<EmpresasState> emit,
  ) async {
    try {
      // Guardar el estado actual para poder recargar
      final currentState = state;

      await _empresasRepository.deleteEmpresa(event.id);

      // Si había empresas cargadas, recargar todas
      if (currentState is EmpresasLoaded) {
        add(LoadAllEmpresas());
      }
    } catch (e) {
      emit(
        EmpresasError(message: 'Error al eliminar empresa: ${e.toString()}'),
      );
    }
  }
}
