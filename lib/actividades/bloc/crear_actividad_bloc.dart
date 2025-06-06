import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'crear_actividad_event.dart';
import 'crear_actividad_state.dart';
import '../repository/actividades_repository.dart';
import '../helpers/notificaciones_helper.dart';

class CrearActividadBloc
    extends Bloc<CrearActividadEvent, CrearActividadState> {
  final ActividadesRepository repository;

  CrearActividadBloc({required this.repository})
    : super(CrearActividadInitial()) {
    on<CrearActividadRequested>(_onCrearActividad);
  }

  Future<void> _onCrearActividad(
    CrearActividadRequested event,
    Emitter<CrearActividadState> emit,
  ) async {
    emit(CrearActividadLoading());

    try {
      print('🔍 Iniciando validaciones...');

      // ✅ VALIDACIONES COMPLETAS ANTES DE GUARDAR
      if (event.titulo.trim().isEmpty) {
        emit(CrearActividadFailure('El título es obligatorio'));
        return;
      }

      if (event.materiaId.trim().isEmpty) {
        emit(CrearActividadFailure('ID de materia no válido'));
        return;
      }

      // ✅ VALIDAR FECHAS NO SEAN NULL
      if (event.fechaEntrega == null) {
        emit(CrearActividadFailure('La fecha de entrega es obligatoria'));
        return;
      }

      if (event.notificar) {
        // Validar fechas de notificación no sean null
        if (event.fechaInicioRango == null || event.fechaFinRango == null) {
          emit(
            CrearActividadFailure(
              'Las fechas de rango son obligatorias para notificaciones',
            ),
          );
          return;
        }

        if (event.fechaInicioRango!.isAfter(event.fechaFinRango!)) {
          emit(
            CrearActividadFailure(
              'La fecha de inicio debe ser anterior a la fecha fin',
            ),
          );
          return;
        }

        if (event.horasNotificacion.isEmpty) {
          emit(
            CrearActividadFailure(
              'Debe seleccionar al menos una hora para las notificaciones',
            ),
          );
          return;
        }

        // Validar formato de horas
        for (final hora in event.horasNotificacion) {
          if (hora.trim().isEmpty) {
            emit(CrearActividadFailure('Hora vacía encontrada'));
            return;
          }

          final partes = hora.trim().split(':');
          if (partes.length != 2) {
            emit(CrearActividadFailure('Formato de hora inválido: $hora'));
            return;
          }

          final horaInt = int.tryParse(partes[0]);
          final minutoInt = int.tryParse(partes[1]);

          if (horaInt == null ||
              minutoInt == null ||
              horaInt < 0 ||
              horaInt > 23 ||
              minutoInt < 0 ||
              minutoInt > 59) {
            emit(CrearActividadFailure('Hora fuera de rango: $hora'));
            return;
          }
        }
      }

      print('✅ Validaciones completadas');
      print('📝 Guardando actividad: ${event.titulo}');

      // 1️⃣ Guardar actividad en base de datos CON MANEJO DE ERRORES
      try {
        await repository.agregarActividad(
          materiaId: event.materiaId.trim(),
          titulo: event.titulo.trim(),
          descripcion: event.descripcion.trim(),
          urgencia: event.urgencia,
          fechaEntrega: event.fechaEntrega,
          notificar: event.notificar,
          horasNotificacion: event.horasNotificacion,
          fechaInicioRango: event.fechaInicioRango,
          fechaFinRango: event.fechaFinRango,
          estado: event.estado, // ✅ NUEVO CAMPO ENVIADO
        );

        print('✅ Actividad guardada en base de datos');
      } catch (repositoryError) {
        print('❌ Error en repository: $repositoryError');
        emit(
          CrearActividadFailure(
            'Error al guardar en base de datos: $repositoryError',
          ),
        );
        return;
      }

      // 2️⃣ SI el usuario activó notificaciones, programarlas automáticamente
      if (event.notificar &&
          event.horasNotificacion.isNotEmpty &&
          event.fechaInicioRango != null &&
          event.fechaFinRango != null) {
        print("🔔 Usuario activó notificaciones, programando...");

        try {
          // ✅ Inicializar notificaciones
          final permisosOk =
              await NotificationService.inicializarNotificaciones();

          if (permisosOk) {
            // 🎯 Programar todas las notificaciones automáticamente
            await NotificationService.programarNotificacionesMultiples(
              titulo: event.titulo.trim(),
              descripcion: event.descripcion.trim(),
              fechaInicio: event.fechaInicioRango!,
              fechaFin: event.fechaFinRango!,
              horas: event.horasNotificacion,
            );

            print("✅ Notificaciones programadas automáticamente");
          } else {
            print("⚠️ No se obtuvieron permisos para notificaciones");
            // No fallar el proceso, solo advertir
          }
        } catch (notificationError) {
          print("❌ Error al programar notificaciones: $notificationError");
          // No fallar el proceso principal, las notificaciones son secundarias
          // Pero podríamos mostrar una advertencia al usuario
        }
      }

      emit(CrearActividadSuccess());
    } catch (e, stackTrace) {
      print('❌ Error CRÍTICO al crear actividad: $e');
      print('❌ Stack trace: $stackTrace');

      // Mensaje de error más específico
      String mensajeError = 'Error desconocido al crear la actividad';

      if (e.toString().contains('Timestamp')) {
        mensajeError =
            'Error al procesar las fechas. Verifique que todas las fechas sean válidas.';
      } else if (e.toString().contains('permission')) {
        mensajeError =
            'Error de permisos. Verifique los permisos de la aplicación.';
      } else if (e.toString().contains('network')) {
        mensajeError = 'Error de conexión. Verifique su conexión a internet.';
      } else {
        mensajeError = 'Error al crear la actividad: ${e.toString()}';
      }

      emit(CrearActividadFailure(mensajeError));
    }
  }
}
