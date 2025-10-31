import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/gastos_repository.dart';
import 'gastos_event.dart';
import 'gastos_state.dart';

/// Bloc que gestiona el estado de los Gastos
class GastosBloc extends Bloc<GastosEvent, GastosState> {
  final GastosRepository _gastosRepository;

  GastosBloc({required GastosRepository gastosRepository})
    : _gastosRepository = gastosRepository,
      super(GastosInitial()) {
    on<LoadGastos>(_onLoadGastos);
    on<AddGasto>(_onAddGasto);
    on<UpdateGasto>(_onUpdateGasto);
    on<DeleteGasto>(_onDeleteGasto);
  }

  /// Maneja el evento de cargar gastos
  Future<void> _onLoadGastos(
    LoadGastos event,
    Emitter<GastosState> emit,
  ) async {
    emit(GastosLoading());
    try {
      // Obtener gastos del mes con detalles
      final gastos = await _gastosRepository.getGastosConDetallesPorMes(
        event.mes,
        event.anio,
      );

      // Calcular total del mes
      final totalMes = await _gastosRepository.getTotalMes(
        event.mes,
        event.anio,
      );

      emit(
        GastosLoaded(
          gastos: gastos,
          totalMes: totalMes,
          mes: event.mes,
          anio: event.anio,
        ),
      );
    } catch (e) {
      emit(GastosError(message: 'Error al cargar gastos: ${e.toString()}'));
    }
  }

  /// Maneja el evento de agregar un gasto
  Future<void> _onAddGasto(AddGasto event, Emitter<GastosState> emit) async {
    try {
      await _gastosRepository.insertGasto(event.gasto);
      emit(const GastoAdded());

      // Recargar los gastos del mes actual
      final fecha = event.gasto.fecha;
      add(LoadGastos(mes: fecha.month, anio: fecha.year));
    } catch (e) {
      emit(GastosError(message: 'Error al agregar gasto: ${e.toString()}'));
    }
  }

  /// Maneja el evento de actualizar un gasto
  Future<void> _onUpdateGasto(
    UpdateGasto event,
    Emitter<GastosState> emit,
  ) async {
    try {
      await _gastosRepository.updateGasto(event.gasto);
      emit(const GastoUpdated());

      // Recargar los gastos del mes actual
      final fecha = event.gasto.fecha;
      add(LoadGastos(mes: fecha.month, anio: fecha.year));
    } catch (e) {
      emit(GastosError(message: 'Error al actualizar gasto: ${e.toString()}'));
    }
  }

  /// Maneja el evento de eliminar un gasto
  Future<void> _onDeleteGasto(
    DeleteGasto event,
    Emitter<GastosState> emit,
  ) async {
    try {
      // Guardar el estado actual para poder recargar el mismo mes
      final currentState = state;
      int mes = DateTime.now().month;
      int anio = DateTime.now().year;

      if (currentState is GastosLoaded) {
        mes = currentState.mes;
        anio = currentState.anio;
      }

      await _gastosRepository.deleteGasto(event.id);
      emit(const GastoDeleted());

      // Recargar los gastos del mismo mes
      add(LoadGastos(mes: mes, anio: anio));
    } catch (e) {
      emit(GastosError(message: 'Error al eliminar gasto: ${e.toString()}'));
    }
  }
}
