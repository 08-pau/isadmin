import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repository/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository authRepository;

  RegisterBloc({required this.authRepository}) : super(RegisterInitial()) {
    on<RegisterSubmitted>((event, emit) async {
      emit(RegisterLoading());

      if (event.password != event.confirmPassword) {
        emit( RegisterFailure(error: 'Las contraseñas no coinciden'));
        return;
      }

      try {
        await authRepository.registerUser(event.name, event.email, event.password);
        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterFailure(error: e.toString()));
      }
    });
  }
}


