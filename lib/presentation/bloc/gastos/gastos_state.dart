import 'package:equatable/equatable.dart';
import '../../../data/models/gasto_con_detalles_model.dart';

/// Estados del Bloc de Gastos
abstract class GastosState extends Equatable {
  const GastosState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class GastosInitial extends GastosState {}

/// Estado de carga
class GastosLoading extends GastosState {}

/// Estado cuando los gastos se cargaron exitosamente
class GastosLoaded extends GastosState {
  final List<GastoConDetallesModel> gastos;
  final double totalMes;
  final int mes;
  final int anio;

  const GastosLoaded({
    required this.gastos,
    required this.totalMes,
    required this.mes,
    required this.anio,
  });

  @override
  List<Object?> get props => [gastos, totalMes, mes, anio];
}

/// Estado de error
class GastosError extends GastosState {
  final String message;

  const GastosError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado cuando se agregó un gasto exitosamente
class GastoAdded extends GastosState {
  final String message;

  const GastoAdded({this.message = 'Gasto agregado correctamente'});

  @override
  List<Object?> get props => [message];
}

/// Estado cuando se actualizó un gasto exitosamente
class GastoUpdated extends GastosState {
  final String message;

  const GastoUpdated({this.message = 'Gasto actualizado correctamente'});

  @override
  List<Object?> get props => [message];
}

/// Estado cuando se eliminó un gasto exitosamente
class GastoDeleted extends GastosState {
  final String message;

  const GastoDeleted({this.message = 'Gasto eliminado correctamente'});

  @override
  List<Object?> get props => [message];
}
