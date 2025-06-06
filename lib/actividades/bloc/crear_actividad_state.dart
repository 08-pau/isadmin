abstract class CrearActividadState {}

class CrearActividadInitial extends CrearActividadState {}

class CrearActividadLoading extends CrearActividadState {}

class CrearActividadSuccess extends CrearActividadState {
  final String? mensaje;
  
  CrearActividadSuccess({this.mensaje});
}

class CrearActividadFailure extends CrearActividadState {
  final String error;
  
  CrearActividadFailure(this.error);
}