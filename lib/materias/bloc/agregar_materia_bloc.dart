import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:isadmin/materias/repository/materias_repository.dart';

part 'agregar_materia_event.dart';
part 'agregar_materia_state.dart';

class AgregarMateriaBloc extends Bloc<AgregarMateriaEvent, AgregarMateriaState> {
  final MateriasRepository repository;

  AgregarMateriaBloc({required this.repository}) : super(AgregarMateriaInitial()) {
    on<EnviarMateria>(_onEnviarMateria);
  }

  Future<void> _onEnviarMateria(
    EnviarMateria event,
    Emitter<AgregarMateriaState> emit,
  ) async {
    emit(AgregarMateriaLoading());
    try {
      await repository.agregarMateria(
        nombre: event.nombre,
        profesor: event.profesor,
        horario: event.horario,
      );
      emit(AgregarMateriaSuccess());
    } catch (e) {
      emit(AgregarMateriaError(e.toString()));
    }
  }
}
