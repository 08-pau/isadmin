abstract class CursoState {}

class CursoInicial extends CursoState {}

class CursoCargando extends CursoState {}

class CursoCargado extends CursoState {
  final double progreso;
  CursoCargado(this.progreso);
}

class CursoError extends CursoState {
  final String mensaje;
  CursoError(this.mensaje);
}