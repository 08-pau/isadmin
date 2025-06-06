import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:isadmin/tareas/repository/tareas_repository.dart';

part 'editar_tarea_event.dart';
part 'editar_tarea_state.dart';

class EditarTareaBloc extends Bloc<EditarTareaEvent, EditarTareaState> {
  final TareasRepository tareasRepository;

  EditarTareaBloc({required this.tareasRepository}) : super(EditarTareaInitial()) {
    on<GuardarCambiosTarea>(_onGuardarCambios);
  }

  Future<void> _onGuardarCambios(
    GuardarCambiosTarea event,
    Emitter<EditarTareaState> emit,
  ) async {
    emit(EditarTareaLoading());
    try {
      await tareasRepository.editarTarea(
        id: event.id,
        nombre: event.nombre,
        estado: event.estado,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );
      emit(EditarTareaSuccess());
    } catch (e) {
      emit(EditarTareaError(e.toString()));
    }
  }
}
