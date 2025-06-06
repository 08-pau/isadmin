// lib/actividades/bloc/crear_actividad_event.dart

abstract class CrearActividadEvent {}

class CrearActividadRequested extends CrearActividadEvent {
  final String materiaId;
  final String titulo;
  final String descripcion;
  final String urgencia;
  final DateTime fechaEntrega;
  final bool notificar;
  final List<String> horasNotificacion;
  final DateTime fechaInicioRango;
  final DateTime fechaFinRango;
  final String estado; // ✅ NUEVO

  CrearActividadRequested({
    required this.materiaId,
    required this.titulo,
    required this.descripcion,
    required this.urgencia,
    required this.fechaEntrega,
    required this.notificar,
    required this.horasNotificacion,
    required this.fechaInicioRango,
    required this.fechaFinRango,
    required this.estado, // ✅ NUEVO
  });
}

