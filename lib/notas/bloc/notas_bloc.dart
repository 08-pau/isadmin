import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/notas_repository.dart';
import 'notas_event.dart';
import 'notas_state.dart';

class NotasBloc extends Bloc<NotasEvent, NotasState> {
  final NotasRepository repository;

  NotasBloc({required this.repository}) : super(NotasLoading()) {
    on<CargarNotas>(_onCargarNotas);
    on<AgregarNota>(_onAgregarNota);
    on<EditarNota>(_onEditarNota);
    on<EliminarNota>(_onEliminarNota);
  }

  Future<void> _onCargarNotas(CargarNotas event, Emitter<NotasState> emit) async {
    try {
      final snapshot = await repository.obtenerNotas();
      emit(NotasLoaded(snapshot.docs));
    } catch (e) {
      emit(NotasError('Error al cargar notas'));
    }
  }

  Future<void> _onAgregarNota(AgregarNota event, Emitter<NotasState> emit) async {
    await repository.agregarNota(event.contenido);
    add(CargarNotas());
  }

  Future<void> _onEditarNota(EditarNota event, Emitter<NotasState> emit) async {
    await repository.editarNota(event.id, event.nuevoContenido);
    add(CargarNotas());
  }

  Future<void> _onEliminarNota(EliminarNota event, Emitter<NotasState> emit) async {
    await repository.eliminarNota(event.id);
    add(CargarNotas());
  }
}
