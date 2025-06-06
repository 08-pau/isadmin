part of 'editar_tarea_bloc.dart';

abstract class EditarTareaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EditarTareaInitial extends EditarTareaState {}

class EditarTareaLoading extends EditarTareaState {}

class EditarTareaSuccess extends EditarTareaState {}

class EditarTareaError extends EditarTareaState {
  final String mensaje;

  EditarTareaError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
