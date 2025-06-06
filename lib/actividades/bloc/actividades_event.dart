abstract class ActividadesEvent {}

class CargarActividades extends ActividadesEvent {
  final String materiaId;
  CargarActividades(this.materiaId);
}

class EliminarActividad extends ActividadesEvent {
  final String materiaId;
  final String actividadId;
  EliminarActividad({required this.materiaId, required this.actividadId});
}

class EditarActividad extends ActividadesEvent {
  final String materiaId;
  final String actividadId;
  final String titulo;
  final String descripcion;
  final String urgencia;

  EditarActividad({
    required this.materiaId,
    required this.actividadId,
    required this.titulo,
    required this.descripcion,
    required this.urgencia,
  });
}

class CambiarEstadoActividad extends ActividadesEvent {
  final String materiaId;
  final String actividadId;
  final String nuevoEstado;

  CambiarEstadoActividad({
    required this.materiaId,
    required this.actividadId,
    required this.nuevoEstado,
  });
}
