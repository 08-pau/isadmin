// perfil_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilRepository {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  Future<Map<String, dynamic>> obtenerPerfil(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception("Usuario no encontrado");
    }
    return doc.data()!..['id'] = doc.id;
  }
}