
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/materias_repository.dart';
import 'materias_event.dart';
import 'materias_state.dart';

class MateriasBloc extends Bloc<MateriasEvent, MateriasState> {
  final MateriasRepository repository;

  MateriasBloc(this.repository) : super(MateriasInicial()) {
    on<CargarMaterias>((event, emit) async {
      emit(MateriasCargando());
      try {
        final materias = await repository.obtenerMaterias();
        emit(MateriasCargadas(materias));
      } catch (_) {
        emit(MateriasError('Error al cargar materias'));
      }
    });

    on<BuscarMaterias>((event, emit) async {
      emit(MateriasCargando());
      try {
        final materias = await repository.obtenerMaterias();
        final filtradas = materias.where((m) {
          final nombre = (m['nombre'] ?? '').toString().toLowerCase();
          return nombre.contains(event.query.toLowerCase());
        }).toList();
        emit(MateriasCargadas(filtradas));
      } catch (_) {
        emit(MateriasError('Error al buscar materias'));
      }
    });

    on<RefrescarMaterias>((event, emit) async {
      try {
        final materias = await repository.obtenerMaterias();
        emit(MateriasCargadas(materias));
      } catch (_) {
        emit(MateriasError('Error al refrescar materias'));
      }
      
    });
    on<EliminarMateria>((event, emit) async {
  try {
    await repository.eliminarMateria(event.materiaId);
    final materias = await repository.obtenerMaterias();
    emit(MateriasCargadas(materias));
  } catch (_) {
    emit(MateriasError('Error al eliminar la materia'));
  }
});

  }
}