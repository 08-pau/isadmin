abstract class MateriasState {}

class MateriasInicial extends MateriasState {}

class MateriasCargando extends MateriasState {}

class MateriasCargadas extends MateriasState {
  final List<Map<String, dynamic>> materias;
  MateriasCargadas(this.materias);
}

class MateriasError extends MateriasState {
  final String mensaje;
  MateriasError(this.mensaje);
}
