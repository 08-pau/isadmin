// perfil_event.dart
import 'package:equatable/equatable.dart';

abstract class PerfilEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CargarPerfil extends PerfilEvent {
  final String uid;

  CargarPerfil(this.uid);

  @override
  List<Object?> get props => [uid];
}