part of 'tareas_bloc.dart';

abstract class TareasState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TareasInitial extends TareasState {}

class TareasLoading extends TareasState {}

class TareasCargadas extends TareasState {
  final List<QueryDocumentSnapshot> tareas;

  TareasCargadas(this.tareas);

  @override
  List<Object?> get props => [tareas];
}

class TareasError extends TareasState {
  final String mensaje;

  TareasError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
