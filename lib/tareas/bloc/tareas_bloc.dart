import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../repository/tareas_repository.dart';

part 'tareas_event.dart';
part 'tareas_state.dart';

class TareasBloc extends Bloc<TareasEvent, TareasState> {
  final TareasRepository repository;

  TareasBloc({required this.repository}) : super(TareasInitial()) {
    on<CargarTareas>(_onCargarTareas);
    on<CambiarEstadoTarea>(_onCambiarEstado);
    on<EliminarTarea>(_onEliminarTarea);
  }

  Future<void> _onCargarTareas(CargarTareas event, Emitter<TareasState> emit) async {
    emit(TareasLoading());
    try {
      final tareas = await repository.obtenerTareasPorEstado(event.estado);
      emit(TareasCargadas(tareas));
    } catch (e) {
      emit(TareasError("Error al cargar tareas"));
    }
  }

  Future<void> _onCambiarEstado(CambiarEstadoTarea event, Emitter<TareasState> emit) async {
    await repository.cambiarEstado(event.id, event.nuevoEstado);
    add(CargarTareas('pendiente')); // puedes ajustar a estado actual
  }

  Future<void> _onEliminarTarea(EliminarTarea event, Emitter<TareasState> emit) async {
    await repository.eliminarTarea(event.id);
    add(CargarTareas('pendiente'));
  }
}
