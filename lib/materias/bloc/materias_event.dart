
abstract class MateriasEvent {}

class CargarMaterias extends MateriasEvent {}

class BuscarMaterias extends MateriasEvent {
  final String query;
  BuscarMaterias(this.query);
}
class EliminarMateria extends MateriasEvent {
  final String materiaId;
  EliminarMateria(this.materiaId);
}

class RefrescarMaterias extends MateriasEvent {}