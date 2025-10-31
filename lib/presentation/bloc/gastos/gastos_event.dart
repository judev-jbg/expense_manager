import 'package:equatable/equatable.dart';
import '../../../data/models/gasto_model.dart';

/// Eventos del Bloc de Gastos
abstract class GastosEvent extends Equatable {
  const GastosEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar gastos de un mes específico
class LoadGastos extends GastosEvent {
  final int mes;
  final int anio;

  const LoadGastos({required this.mes, required this.anio});

  @override
  List<Object?> get props => [mes, anio];
}

/// Evento para agregar un nuevo gasto
class AddGasto extends GastosEvent {
  final GastoModel gasto;

  const AddGasto({required this.gasto});

  @override
  List<Object?> get props => [gasto];
}

/// Evento para actualizar un gasto existente
class UpdateGasto extends GastosEvent {
  final GastoModel gasto;

  const UpdateGasto({required this.gasto});

  @override
  List<Object?> get props => [gasto];
}

/// Evento para eliminar un gasto
class DeleteGasto extends GastosEvent {
  final String id;

  const DeleteGasto({required this.id});

  @override
  List<Object?> get props => [id];
}
