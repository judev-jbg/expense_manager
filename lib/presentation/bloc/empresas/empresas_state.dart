import 'package:equatable/equatable.dart';
import '../../../data/models/empresa_model.dart';

/// Estados del Bloc de Empresas
abstract class EmpresasState extends Equatable {
  const EmpresasState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class EmpresasInitial extends EmpresasState {}

/// Estado de carga
class EmpresasLoading extends EmpresasState {}

/// Estado cuando las empresas se cargaron exitosamente
class EmpresasLoaded extends EmpresasState {
  final List<EmpresaModel> empresas;

  const EmpresasLoaded({required this.empresas});

  @override
  List<Object?> get props => [empresas];
}

/// Estado de error
class EmpresasError extends EmpresasState {
  final String message;

  const EmpresasError({required this.message});

  @override
  List<Object?> get props => [message];
}
