part of 'tareas_bloc.dart';

abstract class TareasEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CargarTareas extends TareasEvent {
  final String estado;

  CargarTareas(this.estado);

  @override
  List<Object?> get props => [estado];
}

class CambiarEstadoTarea extends TareasEvent {
  final String id;
  final String nuevoEstado;

  CambiarEstadoTarea({required this.id, required this.nuevoEstado});

  @override
  List<Object?> get props => [id, nuevoEstado];
}

class EliminarTarea extends TareasEvent {
  final String id;

  EliminarTarea(this.id);

  @override
  List<Object?> get props => [id];
}
