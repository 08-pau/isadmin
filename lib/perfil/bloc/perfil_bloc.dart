// perfil_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/perfil_repository.dart';
import 'perfil_event.dart';
import 'perfil_state.dart';

class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  final PerfilRepository repository;

  PerfilBloc({required this.repository}) : super(PerfilInicial()) {
    on<CargarPerfil>((event, emit) async {
      emit(PerfilCargando());
      try {
        final userData = await repository.obtenerPerfil(event.uid);
        emit(PerfilCargado(userData));
      } catch (e) {
        emit(PerfilError("Error al cargar perfil: \$e"));
      }
    });
  }
}
