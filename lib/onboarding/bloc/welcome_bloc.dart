import 'package:flutter_bloc/flutter_bloc.dart';

/// EVENTOS
abstract class WelcomeEvent {}

class WelcomeStarted extends WelcomeEvent {}

class WelcomeCompleted extends WelcomeEvent {}

/// ESTADOS
abstract class WelcomeState {}

class WelcomeInitial extends WelcomeState {}

class WelcomeLoading extends WelcomeState {}

class WelcomeReady extends WelcomeState {}

/// BLOC
class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc() : super(WelcomeInitial()) {
    on<WelcomeStarted>((event, emit) async {
      emit(WelcomeLoading());
      await Future.delayed(const Duration(seconds: 2)); // simula carga
      emit(WelcomeReady());
    });

    on<WelcomeCompleted>((event, emit) {
      // lógica futura aquí
    });
  }
}
