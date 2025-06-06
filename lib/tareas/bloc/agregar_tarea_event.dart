part of 'agregar_tarea_bloc.dart';

abstract class AgregarTareaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EnviarTarea extends AgregarTareaEvent {
  final String nombre;
  final String detalle;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  EnviarTarea({
    required this.nombre,
    required this.detalle,
    required this.fechaInicio,
    required this.fechaFin,
  });

  @override
  List<Object?> get props => [nombre, detalle, fechaInicio, fechaFin];
}
