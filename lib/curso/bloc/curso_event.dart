abstract class CursoEvent {}

class CargarProgresoCurso extends CursoEvent {
  final String materiaId;
  CargarProgresoCurso(this.materiaId);
}