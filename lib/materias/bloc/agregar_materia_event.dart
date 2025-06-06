part of 'agregar_materia_bloc.dart';

abstract class AgregarMateriaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EnviarMateria extends AgregarMateriaEvent {
  final String nombre;
  final String profesor;
  final String horario;

  EnviarMateria({
    required this.nombre,
    required this.profesor,
    required this.horario,
  });

  @override
  List<Object?> get props => [nombre, profesor, horario];
}
