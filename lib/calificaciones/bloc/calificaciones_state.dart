import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class CalificacionesState extends Equatable {
  const CalificacionesState();

  @override
  List<Object> get props => [];
}

class CalificacionesInicial extends CalificacionesState {}

class CalificacionesCargando extends CalificacionesState {}

class CalificacionesCargadas extends CalificacionesState {
  final List<QueryDocumentSnapshot> calificaciones;

  const CalificacionesCargadas(this.calificaciones);

  @override
  List<Object> get props => [calificaciones];
}

class CalificacionesError extends CalificacionesState {
  final String mensaje;

  const CalificacionesError(this.mensaje);

  @override
  List<Object> get props => [mensaje];
}
