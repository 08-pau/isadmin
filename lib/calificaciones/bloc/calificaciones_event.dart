import 'package:equatable/equatable.dart';

abstract class CalificacionesEvent extends Equatable {
  const CalificacionesEvent();

  @override
  List<Object> get props => [];
}

class CargarCalificaciones extends CalificacionesEvent {
  final String materiaId;

  const CargarCalificaciones(this.materiaId);

  @override
  List<Object> get props => [materiaId];
}

class AgregarCalificacion extends CalificacionesEvent {
  final String materiaId;
  final String nombre;
  final double nota;
  final double porcentajeObtenido;
  final double porcentajeTotal;

  const AgregarCalificacion({
    required this.materiaId,
    required this.nombre,
    required this.nota,
    required this.porcentajeObtenido,
    required this.porcentajeTotal,
  });

  @override
  List<Object> get props => [materiaId, nombre, nota, porcentajeObtenido, porcentajeTotal];
}

class EditarCalificacion extends CalificacionesEvent {
  final String materiaId;
  final String calificacionId;
  final String nombre;
  final double nota;
  final double porcentajeObtenido;
  final double porcentajeTotal;

  const EditarCalificacion({
    required this.materiaId,
    required this.calificacionId,
    required this.nombre,
    required this.nota,
    required this.porcentajeObtenido,
    required this.porcentajeTotal,
  });

  @override
  List<Object> get props => [materiaId, calificacionId, nombre, nota, porcentajeObtenido, porcentajeTotal];
}

class EliminarCalificacion extends CalificacionesEvent {
  final String materiaId;
  final String calificacionId;

  const EliminarCalificacion({
    required this.materiaId,
    required this.calificacionId,
  });

  @override
  List<Object> get props => [materiaId, calificacionId];
}
