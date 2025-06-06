part of 'agregar_materia_bloc.dart';

abstract class AgregarMateriaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AgregarMateriaInitial extends AgregarMateriaState {}

class AgregarMateriaLoading extends AgregarMateriaState {}

class AgregarMateriaSuccess extends AgregarMateriaState {}

class AgregarMateriaError extends AgregarMateriaState {
  final String mensaje;

  AgregarMateriaError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
