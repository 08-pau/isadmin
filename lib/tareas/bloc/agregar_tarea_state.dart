part of 'agregar_tarea_bloc.dart';

abstract class AgregarTareaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AgregarTareaInitial extends AgregarTareaState {}

class AgregarTareaLoading extends AgregarTareaState {}

class AgregarTareaSuccess extends AgregarTareaState {}

class AgregarTareaError extends AgregarTareaState {
  final String mensaje;

  AgregarTareaError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
