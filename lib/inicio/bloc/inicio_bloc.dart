import 'package:flutter_bloc/flutter_bloc.dart';
import 'inicio_event.dart';
import 'inicio_state.dart';

class InicioBloc extends Bloc<InicioEvent, InicioState> {
  InicioBloc() : super(InicioInitial()) {
    on<IniciarApp>((event, emit) {
      emit(InicioReady());
    });
  }
}
