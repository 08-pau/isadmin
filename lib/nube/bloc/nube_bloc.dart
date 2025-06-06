import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/nube_repository.dart';
import 'nube_event.dart';
import 'nube_state.dart';

class NubeBloc extends Bloc<NubeEvent, NubeState> {
  final NubeRepository repository;

  NubeBloc({required this.repository}) : super(NubeInitial()) {
    on<CargarArchivos>(_onCargarArchivos);
    on<EliminarArchivo>(_onEliminarArchivo);
  }

  Future<void> _onCargarArchivos(
    CargarArchivos event,
    Emitter<NubeState> emit,
  ) async {
    emit(NubeLoading());
    try {
      final archivos = await repository.obtenerArchivos(event.materiaId);
      final filtrados = archivos.where((doc) {
        final descripcion = (doc['descripcion'] ?? '').toString().toLowerCase();
        return descripcion.contains(event.filtro.toLowerCase());
      }).toList();

      emit(filtrados.isEmpty ? NubeEmpty() : NubeLoaded(filtrados));
    } catch (e) {
      emit(NubeError('Error al cargar archivos: $e'));
    }
  }

  Future<void> _onEliminarArchivo(
    EliminarArchivo event,
    Emitter<NubeState> emit,
  ) async {
    try {
      await repository.eliminarArchivo(event.materiaId, event.archivoId);
      add(CargarArchivos(materiaId: event.materiaId));
    } catch (e) {
      emit(NubeError('Error al eliminar archivo'));
    }
  }
}

