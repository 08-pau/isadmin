import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:isadmin/tareas/repository/tareas_repository.dart';

part 'agregar_tarea_event.dart';
part 'agregar_tarea_state.dart';

class AgregarTareaBloc extends Bloc<AgregarTareaEvent, AgregarTareaState> {
  final TareasRepository tareasRepository;

  AgregarTareaBloc({required this.tareasRepository}) : super(AgregarTareaInitial()) {
    on<EnviarTarea>(_onEnviarTarea);
  }

  Future<void> _onEnviarTarea(
    EnviarTarea event,
    Emitter<AgregarTareaState> emit,
  ) async {
    emit(AgregarTareaLoading());
    try {
      await tareasRepository.agregarTarea(
        nombre: event.nombre,
        detalle: event.detalle,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );
      emit(AgregarTareaSuccess());
    } catch (e) {
      emit(AgregarTareaError(e.toString()));
    }
  }
}
