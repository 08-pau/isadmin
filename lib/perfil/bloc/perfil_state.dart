// perfil_state.dart
import 'package:equatable/equatable.dart';

abstract class PerfilState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PerfilInicial extends PerfilState {}

class PerfilCargando extends PerfilState {}

class PerfilCargado extends PerfilState {
  final Map<String, dynamic> userData;

  PerfilCargado(this.userData);

  @override
  List<Object?> get props => [userData];
}

class PerfilError extends PerfilState {
  final String mensaje;

  PerfilError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}