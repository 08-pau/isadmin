import 'package:equatable/equatable.dart';

abstract class NotasEvent extends Equatable {
  const NotasEvent();

  @override
  List<Object?> get props => [];
}

class CargarNotas extends NotasEvent {}

class AgregarNota extends NotasEvent {
  final String contenido;

  const AgregarNota(this.contenido);

  @override
  List<Object?> get props => [contenido];
}

class EditarNota extends NotasEvent {
  final String id;
  final String nuevoContenido;

  const EditarNota(this.id, this.nuevoContenido);

  @override
  List<Object?> get props => [id, nuevoContenido];
}

class EliminarNota extends NotasEvent {
  final String id;

  const EliminarNota(this.id);

  @override
  List<Object?> get props => [id];
}
