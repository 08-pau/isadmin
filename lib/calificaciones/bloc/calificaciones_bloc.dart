import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/calificaciones_repository.dart';
import 'package:isadmin/calificaciones/bloc/calificaciones_event.dart';
import 'package:isadmin/calificaciones/bloc/calificaciones_state.dart';

class CalificacionesBloc extends Bloc<CalificacionesEvent, CalificacionesState> {
  final CalificacionesRepository repository;

  CalificacionesBloc({required this.repository}) : super(CalificacionesInicial()) {
    on<CargarCalificaciones>(_onCargar);
    on<AgregarCalificacion>(_onAgregar);
    on<EditarCalificacion>(_onEditar);
    on<EliminarCalificacion>(_onEliminar);
  }

  Future<void> _onCargar(CargarCalificaciones event, Emitter<CalificacionesState> emit) async {
    emit(CalificacionesCargando());
    try {
      final calificaciones = await repository.obtenerCalificaciones(event.materiaId);
      emit(CalificacionesCargadas(calificaciones));
    } catch (e) {
      emit(CalificacionesError('Error al cargar calificaciones'));
    }
  }

  Future<void> _onAgregar(AgregarCalificacion event, Emitter<CalificacionesState> emit) async {
    try {
      await repository.agregarCalificacion(
        materiaId: event.materiaId,
        nombre: event.nombre,
        nota: event.nota,
        porcentajeObtenido: event.porcentajeObtenido,
        porcentajeTotal: event.porcentajeTotal,
      );
      add(CargarCalificaciones(event.materiaId));
    } catch (_) {
      emit(CalificacionesError('No se pudo agregar calificación'));
    }
  }

  Future<void> _onEditar(EditarCalificacion event, Emitter<CalificacionesState> emit) async {
    try {
      await repository.editarCalificacion(
        materiaId: event.materiaId,
        calificacionId: event.calificacionId,
        nombre: event.nombre,
        nota: event.nota,
        porcentajeObtenido: event.porcentajeObtenido,
        porcentajeTotal: event.porcentajeTotal,
      );
      add(CargarCalificaciones(event.materiaId));
    } catch (_) {
      emit(CalificacionesError('No se pudo editar la calificación'));
    }
  }

  Future<void> _onEliminar(EliminarCalificacion event, Emitter<CalificacionesState> emit) async {
    try {
      await repository.eliminarCalificacion(
        materiaId: event.materiaId,
        calificacionId: event.calificacionId,
      );
      add(CargarCalificaciones(event.materiaId));
    } catch (_) {
      emit(CalificacionesError('No se pudo eliminar la calificación'));
    }
  }
}

