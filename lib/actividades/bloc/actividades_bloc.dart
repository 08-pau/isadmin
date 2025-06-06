import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/actividades_repository.dart';
import 'actividades_event.dart';
import 'actividades_state.dart';

class ActividadesBloc extends Bloc<ActividadesEvent, ActividadesState> {
  final ActividadesRepository repository;

  ActividadesBloc({required this.repository}) : super(ActividadesInitial()) {
    on<CargarActividades>(_onCargarActividades);
    on<EliminarActividad>(_onEliminarActividad);
    on<EditarActividad>(_onEditarActividad);
    on<CambiarEstadoActividad>(_onCambiarEstadoActividad); // ✅ Agregado
  }

  void _onCargarActividades(
    CargarActividades event,
    Emitter<ActividadesState> emit,
  ) async {
    emit(ActividadesLoading());
    try {
      final stream = repository.obtenerActividades(event.materiaId);
      await emit.forEach<QuerySnapshot>(
        stream,
        onData: (snapshot) => ActividadesCargadas(snapshot.docs),
        onError: (_, __) => ActividadesError("Error al cargar actividades"),
      );
    } catch (e) {
      emit(ActividadesError("Error inesperado"));
    }
  }

  void _onEliminarActividad(
    EliminarActividad event,
    Emitter<ActividadesState> emit,
  ) async {
    try {
      await repository.eliminarActividad(event.materiaId, event.actividadId);
    } catch (_) {
      emit(ActividadesError("Error al eliminar actividad"));
    }
  }

  void _onEditarActividad(
    EditarActividad event,
    Emitter<ActividadesState> emit,
  ) async {
    try {
      await repository.editarActividad(
        materiaId: event.materiaId,
        actividadId: event.actividadId,
        titulo: event.titulo,
        descripcion: event.descripcion,
        urgencia: event.urgencia,
      );
    } catch (_) {
      emit(ActividadesError("Error al editar actividad"));
    }
  }

  void _onCambiarEstadoActividad(
    CambiarEstadoActividad event,
    Emitter<ActividadesState> emit,
  ) async {
    try {
      await repository.cambiarEstadoActividad(
        materiaId: event.materiaId,
        actividadId: event.actividadId,
        nuevoEstado: event.nuevoEstado,
      );
    } catch (_) {
      emit(ActividadesError("Error al cambiar estado de actividad"));
    }
  }
}
