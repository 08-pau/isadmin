part of 'editar_tarea_bloc.dart';

abstract class EditarTareaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GuardarCambiosTarea extends EditarTareaEvent {
  final String id;
  final String nombre;
  final String estado;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  GuardarCambiosTarea({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFin,
  });

  @override
  List<Object?> get props => [id, nombre, estado, fechaInicio, fechaFin];
}
