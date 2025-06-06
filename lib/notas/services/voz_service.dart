import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class VozService {
  static const _channel = MethodChannel('com.isadmin.voz');

  static Future<String?> iniciarReconocimiento() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) return null;
    }

    try {
      final texto = await _channel.invokeMethod<String>('iniciarDictado');
      return texto;
    } on PlatformException catch (e) {
      print('Error al iniciar dictado: $e');
      return null;
    }
  }
}
