import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  // 🔧 Inicializar notificaciones
 // 🔧 Inicializar notificaciones (CON ZONA HORARIA CORRECTA)
static Future<bool> inicializarNotificaciones() async {
  try {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
    
    // ✅ CORRECCIÓN: Inicializar zonas horarias y configurar Costa Rica
    tz.initializeTimeZones();
    
    // Verificar que la zona horaria de Costa Rica esté disponible
    try {
      final costaRicaLocation = tz.getLocation('America/Costa_Rica');
      final ahora = tz.TZDateTime.now(costaRicaLocation);
      print("✅ Zona horaria Costa Rica configurada correctamente");
      print("🔍 Hora actual en Costa Rica: ${ahora.day}/${ahora.month}/${ahora.year} ${ahora.hour}:${ahora.minute}");
    } catch (e) {
      print("⚠️ Error al configurar zona horaria de Costa Rica: $e");
      print("⚠️ Usando zona horaria local por defecto");
    }

    const AndroidNotificationChannel canal = AndroidNotificationChannel(
      'actividades_id',
      'Recordatorios',
      description: 'Notificaciones de actividades programadas',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(canal);

    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        if (!result.isGranted) return false;
      }
    }

    return true;
  } catch (e) {
    print('❌ Error al inicializar notificaciones: $e');
    return false;
  }
}
  // 🛡️ MÉTODO COMPLETAMENTE CORREGIDO - ELIMINA TODOS LOS CASTS PELIGROSOS
  static void procesarDocumentoParaNotificaciones(DocumentSnapshot doc) {
    try {
      print('🔍 Iniciando procesamiento de documento: ${doc.id}');

      // ✅ VERIFICAR QUE EL DOCUMENTO EXISTE
      if (!doc.exists) {
        print('⚠️ Documento no existe: ${doc.id}');
        return;
      }

      // ✅ OBTENER DATOS DE FORMA COMPLETAMENTE SEGURA
      final rawData = doc.data();
      if (rawData == null) {
        print('⚠️ Datos del documento son null: ${doc.id}');
        return;
      }

      // ✅ CONVERSIÓN ULTRA SEGURA SIN CAST DIRECTO
      Map<String, dynamic> docData = <String, dynamic>{};

      if (rawData is Map<String, dynamic>) {
        docData = rawData;
      } else if (rawData is Map) {
        // Convertir cada entrada de forma segura
        rawData.forEach((key, value) {
          if (key != null) {
            docData[key.toString()] = value;
          }
        });
      } else {
        print('❌ Tipo de datos no compatible: ${rawData.runtimeType}');
        return;
      }

      // ✅ LECTURA SEGURA DE STRINGS
      final String titulo = _obtenerStringSeguro(
        docData,
        'titulo',
        'Sin título',
      );
      final String descripcion = _obtenerStringSeguro(
        docData,
        'descripcion',
        '',
      );
      final bool notificar = _obtenerBoolSeguro(docData, 'notificar', false);

      print('📋 Datos básicos extraídos:');
      print('   📌 Título: $titulo');
      print('   🔔 Notificar: $notificar');

      // ✅ MANEJO SEGURO DE LISTA DE HORAS
      final List<String> horas = _obtenerListaHorasSegura(docData);
      print('   ⏰ Horas extraídas: $horas');

      // ✅ CONVERSIÓN ULTRA SEGURA DE TIMESTAMPS
      final DateTime? fechaInicio = _convertirTimestampUltraSeguro(
        docData,
        'fechaInicioRango',
      );
      final DateTime? fechaFin = _convertirTimestampUltraSeguro(
        docData,
        'fechaFinRango',
      );

      print('   📅 Fecha inicio: $fechaInicio');
      print('   📅 Fecha fin: $fechaFin');

      // ✅ VALIDACIÓN COMPLETA ANTES DE PROGRAMAR
      if (_validarDatosParaNotificacion(
        notificar,
        fechaInicio,
        fechaFin,
        horas,
      )) {
        print('🔔 Datos válidos, programando notificaciones...');

        programarNotificacionesMultiples(
          titulo: titulo,
          descripcion: descripcion,
          fechaInicio: fechaInicio!,
          fechaFin: fechaFin!,
          horas: horas,
        );

        print('✅ Notificaciones programadas desde listener');
      } else {
        print(
          '⚠️ No se programaron notificaciones desde listener (datos inválidos)',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error CRÍTICO al procesar documento ${doc.id}: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  // 🛡️ NUEVO MÉTODO - Conversión ULTRA segura de Timestamp sin NINGÚN cast
  static DateTime? _convertirTimestampUltraSeguro(
    Map<String, dynamic> data,
    String campo,
  ) {
    try {
      print('🔍 Convirtiendo campo "$campo"...');

      // Obtener el valor sin cast
      final valor = data[campo];

      if (valor == null) {
        print('⚠️ Campo "$campo" es null');
        return null;
      }

      print('🔍 Tipo del valor: ${valor.runtimeType}');
      print('🔍 Valor: $valor');

      // Verificar si es Timestamp usando runtimeType en lugar de "is"
      if (valor.runtimeType.toString() == 'Timestamp') {
        try {
          // Usar reflexión o método dinámico para llamar toDate()
          final dynamic timestampObj = valor;
          final DateTime dateTime = timestampObj.toDate();
          print('✅ Timestamp convertido correctamente: $dateTime');
          return dateTime;
        } catch (e) {
          print('❌ Error al convertir Timestamp: $e');
          return null;
        }
      }

      // Si ya es DateTime
      if (valor is DateTime) {
        print('✅ Ya es DateTime: $valor');
        return valor;
      }

      // Si es un Map (Timestamp serializado)
      if (valor is Map) {
        try {
          final mapValue = valor;
          final seconds = mapValue['_seconds'];
          final nanoseconds = mapValue['_nanoseconds'] ?? 0;

          if (seconds != null && seconds is num) {
            final secondsInt = seconds.toInt();
            final nanosecondsInt =
                (nanoseconds is num) ? nanoseconds.toInt() : 0;
            final dateTime = DateTime.fromMillisecondsSinceEpoch(
              (secondsInt * 1000) + (nanosecondsInt ~/ 1000000),
            );
            print('✅ Map convertido a DateTime: $dateTime');
            return dateTime;
          }
        } catch (e) {
          print('❌ Error al procesar Map como timestamp: $e');
        }
      }

      // Si es String, intentar parsear
      if (valor is String && valor.isNotEmpty) {
        final dateTime = DateTime.tryParse(valor);
        if (dateTime != null) {
          print('✅ String parseado a DateTime: $dateTime');
          return dateTime;
        }
      }

      // Si es int (milisegundos)
      if (valor is int && valor > 0) {
        try {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(valor);
          print('✅ Int convertido a DateTime: $dateTime');
          return dateTime;
        } catch (e) {
          print('❌ Error al convertir int a DateTime: $e');
        }
      }

      print(
        '⚠️ Tipo no reconocido para timestamp "$campo": ${valor.runtimeType}',
      );
      return null;
    } catch (e) {
      print('❌ Error CRÍTICO al convertir timestamp "$campo": $e');
      return null;
    }
  }

  // 🛡️ MÉTODO HELPER - Obtener string de forma segura
  static String _obtenerStringSeguro(
    Map<String, dynamic> data,
    String key,
    String defaultValue,
  ) {
    try {
      final value = data[key];
      if (value == null) return defaultValue;
      return value.toString();
    } catch (e) {
      print('⚠️ Error al obtener string "$key": $e');
      return defaultValue;
    }
  }

  // 🛡️ MÉTODO HELPER - Obtener bool de forma segura
  static bool _obtenerBoolSeguro(
    Map<String, dynamic> data,
    String key,
    bool defaultValue,
  ) {
    try {
      final value = data[key];
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value != 0;
      return defaultValue;
    } catch (e) {
      print('⚠️ Error al obtener bool "$key": $e');
      return defaultValue;
    }
  }

  // 🛡️ MÉTODO HELPER - Obtener lista de horas de forma segura
  static List<String> _obtenerListaHorasSegura(Map<String, dynamic> data) {
    final List<String> horas = [];

    try {
      final horasData = data['horasNotification'];
      if (horasData == null) {
        print('⚠️ horasNotification es null');
        return horas;
      }

      if (horasData is List) {
        for (final hora in horasData) {
          if (hora != null) {
            final horaStr = hora.toString().trim();
            if (horaStr.isNotEmpty) {
              horas.add(horaStr);
            }
          }
        }
      } else {
        print('⚠️ horasNotification no es una lista: ${horasData.runtimeType}');
      }
    } catch (e) {
      print('❌ Error al procesar lista de horas: $e');
    }

    return horas;
  }

  // 🛡️ MÉTODO HELPER - Validar datos para notificación
  static bool _validarDatosParaNotificacion(
    bool notificar,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    List<String> horas,
  ) {
    if (!notificar) {
      print('   ❌ Notificaciones desactivadas');
      return false;
    }

    if (fechaInicio == null) {
      print('   ❌ Fecha inicio es null');
      return false;
    }

    if (fechaFin == null) {
      print('   ❌ Fecha fin es null');
      return false;
    }

    if (horas.isEmpty) {
      print('   ❌ Lista de horas está vacía');
      return false;
    }

    if (!fechaInicio.isBefore(fechaFin) &&
        !fechaInicio.isAtSameMomentAs(fechaFin)) {
      print('   ❌ Fecha inicio debe ser anterior o igual a fecha fin');
      return false;
    }

    return true;
  }

  // 🔁 MÉTODO PRINCIPAL - Programa notificaciones (FORMATO MEJORADO)
  static Future<void> programarNotificacionesMultiples({
    required String titulo,
    required String descripcion,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required List<String> horas,
  }) async {
    try {
      print("🔄 Programando notificaciones múltiples:");
      print("   📌 Título: $titulo");
      print("   📅 Desde: ${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year}");
      print("   📅 Hasta: ${fechaFin.day}/${fechaFin.month}/${fechaFin.year}");
      print("   ⏰ Horas: $horas");

      if (horas.isEmpty) {
        print("⚠️ No hay horas configuradas");
        return;
      }

      if (fechaInicio.isAfter(fechaFin)) {
        print("❌ Fecha de inicio no puede ser posterior a fecha fin");
        return;
      }

      int contador = 0;
      int errores = 0;
      
      // ✅ CORRECCIÓN: Usar zona horaria de Costa Rica explícitamente
      final costaRicaLocation = tz.getLocation('America/Costa_Rica');
      final ahora = tz.TZDateTime.now(costaRicaLocation);
      
      // ✅ También mostrar la hora local del sistema para comparar
      final ahoraLocal = DateTime.now();
      
      print("🌍 Zona horaria: America/Costa_Rica");
      print("🔍 Ahora (Costa Rica): ${ahora.day}/${ahora.month}/${ahora.year} ${ahora.hour}:${ahora.minute}:${ahora.second}");
      print("🔍 Ahora (Local): ${ahoraLocal.day}/${ahoraLocal.month}/${ahoraLocal.year} ${ahoraLocal.hour}:${ahoraLocal.minute}:${ahoraLocal.second}");

      DateTime fechaActual = DateTime(fechaInicio.year, fechaInicio.month, fechaInicio.day);
      final fechaFinNormalizada = DateTime(fechaFin.year, fechaFin.month, fechaFin.day);

      print("🔍 Fecha actual de inicio del bucle: ${fechaActual.day}/${fechaActual.month}/${fechaActual.year}");

      while (!fechaActual.isAfter(fechaFinNormalizada)) {
        print("📅 Procesando día: ${fechaActual.day}/${fechaActual.month}/${fechaActual.year}");
        
        for (final horaStr in horas) {
          try {
            final partes = horaStr.trim().split(':');
            if (partes.length != 2) {
              print('⚠️ Formato de hora inválido: $horaStr');
              errores++;
              continue;
            }

            final horaInt = int.tryParse(partes[0]);
            final minutoInt = int.tryParse(partes[1]);

            if (horaInt == null || minutoInt == null ||
                horaInt < 0 || horaInt > 23 ||
                minutoInt < 0 || minutoInt > 59) {
              print('⚠️ Hora fuera de rango: $horaStr');
              errores++;
              continue;
            }

            // ✅ CORRECCIÓN: Crear TZDateTime con zona horaria de Costa Rica
            final tiempoNotificacion = tz.TZDateTime(
              costaRicaLocation,
              fechaActual.year,
              fechaActual.month,
              fechaActual.day,
              horaInt,
              minutoInt,
            );

            final diferencia = tiempoNotificacion.difference(ahora).inSeconds;
            final diferenciaMinutos = (diferencia / 60).round();
            
            print("⏰ Evaluando: ${tiempoNotificacion.day}/${tiempoNotificacion.month} a las ${horaInt.toString().padLeft(2, '0')}:${minutoInt.toString().padLeft(2, '0')}");
            print("⏰ Diferencia: $diferencia segundos ($diferenciaMinutos minutos)");

            // ✅ Programar si es en el futuro (más de 10 segundos)
            if (diferencia >= 10) {
              final id = tiempoNotificacion.millisecondsSinceEpoch ~/ 1000;

              // 🎯 FORMATO MEJORADO DE LA NOTIFICACIÓN
              final String tituloNotificacion = '📌 Recordatorio de actividad';
              final String cuerpoNotificacion = _construirCuerpoNotificacion(titulo, descripcion);

              await flutterLocalNotificationsPlugin.zonedSchedule(
                id,
                tituloNotificacion,
                cuerpoNotificacion,
                tiempoNotificacion,
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'actividades_id',
                    'Recordatorios',
                    channelDescription: 'Notificaciones de actividades programadas',
                    importance: Importance.max,
                    priority: Priority.high,
                    icon: '@mipmap/ic_launcher',
                  ),
                ),
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime,
              );

              contador++;
              print("✅ Notificación #$contador programada para: ${tiempoNotificacion.day}/${tiempoNotificacion.month} a las ${horaInt.toString().padLeft(2, '0')}:${minutoInt.toString().padLeft(2, '0')} (en $diferenciaMinutos minutos)");
              print("   🎯 Título: $tituloNotificacion");
              print("   📝 Cuerpo: $cuerpoNotificacion");
            } else {
              if (diferencia < 0) {
                final minutosAtrasados = (-diferencia / 60).round();
                print("⏭️ Omitida: ${tiempoNotificacion.day}/${tiempoNotificacion.month} a las ${horaInt.toString().padLeft(2, '0')}:${minutoInt.toString().padLeft(2, '0')} (ya pasó hace $minutosAtrasados minutos)");
              } else {
                print("⏭️ Omitida: ${tiempoNotificacion.day}/${tiempoNotificacion.month} a las ${horaInt.toString().padLeft(2, '0')}:${minutoInt.toString().padLeft(2, '0')} (muy poco tiempo: $diferencia segundos)");
              }
            }
          } catch (e) {
            errores++;
            print('❌ Error al procesar hora $horaStr: $e');
          }
        }

        fechaActual = fechaActual.add(const Duration(days: 1));
      }

      print("🎉 Total de notificaciones programadas: $contador");
      if (errores > 0) {
        print("⚠️ Errores encontrados: $errores");
      }

    } catch (e, stackTrace) {
      print('❌ Error en programarNotificacionesMultiples: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  // 🎯 NUEVO MÉTODO - Construir el cuerpo de la notificación con formato mejorado
  static String _construirCuerpoNotificacion(String titulo, String descripcion) {
    final StringBuffer buffer = StringBuffer();
    
    // Agregar el título de la actividad con formato atractivo
    if (titulo.isNotEmpty && titulo != 'Sin título') {
      buffer.write('📋 $titulo');
    }
    
    // Agregar la descripción si existe
    if (descripcion.isNotEmpty) {
      if (buffer.isNotEmpty) {
        buffer.write('\n\n📝 '); // Doble salto de línea y emoji para descripción
      } else {
        buffer.write('📝 '); // Solo emoji si no hay título
      }
      buffer.write(descripcion);
    }
    
    // Agregar línea de separación visual
    if (buffer.isNotEmpty) {
      buffer.write('\n\n⏰ ¡No olvides esta actividad!');
    }
    
    // Si no hay título ni descripción, usar mensaje por defecto
    if (buffer.isEmpty) {
      buffer.write('🔔 Tienes una actividad programada\n\n⏰ ¡No te olvides!');
    }
    
    return buffer.toString();
  }

  // 🔄 LISTENER SEGURO - Escucha cambios en Firestore
  static void escucharCambiosActividades(String materiaId) {
    try {
      print('🎧 Iniciando listener para materia: $materiaId');

      FirebaseFirestore.instance
          .collection('materias')
          .doc(materiaId)
          .collection('actividades')
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
              try {
                print(
                  '📨 Cambios detectados en actividades. Total docs: ${snapshot.docs.length}',
                );

                for (DocumentChange change in snapshot.docChanges) {
                  switch (change.type) {
                    case DocumentChangeType.added:
                      print('➕ Nueva actividad detectada: ${change.doc.id}');
                      procesarDocumentoParaNotificaciones(change.doc);
                      break;
                    case DocumentChangeType.modified:
                      print('✏️ Actividad modificada: ${change.doc.id}');
                      procesarDocumentoParaNotificaciones(change.doc);
                      break;
                    case DocumentChangeType.removed:
                      print('🗑️ Actividad eliminada: ${change.doc.id}');
                      // TODO: Cancelar notificaciones relacionadas con esta actividad
                      break;
                  }
                }
              } catch (e, stackTrace) {
                print('❌ Error al procesar cambios en documentos: $e');
                print('❌ Stack trace: $stackTrace');
              }
            },
            onError: (error) {
              print('❌ Error en listener de actividades: $error');
            },
          );
    } catch (e) {
      print('❌ Error al configurar listener: $e');
    }
  }

  // 🧹 Cancelar todas las notificaciones
  static Future<void> cancelarTodasLasNotificaciones() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      print('✅ Todas las notificaciones canceladas');
    } catch (e) {
      print('❌ Error al cancelar notificaciones: $e');
    }
  }

  // 🔍 Obtener notificaciones pendientes (para debug)
  static Future<void> mostrarNotificacionesPendientes() async {
    try {
      final pendientes =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print('📋 Notificaciones pendientes: ${pendientes.length}');
      for (final notif in pendientes) {
        print('   ID: ${notif.id}, Título: ${notif.title}');
      }
    } catch (e) {
      print('❌ Error al obtener notificaciones pendientes: $e');
    }
  }
}