import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String?> subirArchivo({
    required File archivo,
    required String tipo,
    required String materiaId,
    required String descripcion,
  }) async {
    try {
      final String nombreArchivo =
          '${DateTime.now().millisecondsSinceEpoch}_${archivo.path.split('/').last}';

      final String carpeta = tipo == 'imagen' ? 'nube_imagenes' : 'nube_documentos';
      final contentType = tipo == 'imagen' ? 'image/jpeg' : 'application/pdf';
      final SettableMetadata metadata = SettableMetadata(contentType: contentType);

      final Reference ref = _storage.ref().child('$carpeta/$materiaId/$nombreArchivo');
      final UploadTask uploadTask = ref.putFile(archivo, metadata);
      final TaskSnapshot snapshot = await uploadTask;

      final String url = await snapshot.ref.getDownloadURL();

      await _firestore
          .collection('materias')
          .doc(materiaId)
          .collection('nube')
          .add({
        'url': url,
        'tipo': tipo,
        'nombre': nombreArchivo,
        'descripcion': descripcion,
        'fecha': Timestamp.now(),
        'path': ref.fullPath,
      });

      return url;
    } catch (e) {
      print('❌ Error al subir archivo: $e');
      return null;
    }
  }
}
