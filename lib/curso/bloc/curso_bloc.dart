import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/curso_repository.dart';
import 'curso_event.dart';
import 'curso_state.dart';

class CursoBloc extends Bloc<CursoEvent, CursoState> {
  final CursoRepository repository;

  CursoBloc(this.repository) : super(CursoInicial()) {
    on<CargarProgresoCurso>((event, emit) async {
      emit(CursoCargando());
      try {
        final progreso = await repository.calcularProgreso(event.materiaId);
        emit(CursoCargado(progreso));
      } catch (e) {
        emit(CursoError('Error al cargar el progreso'));
      }
    });
  }
}