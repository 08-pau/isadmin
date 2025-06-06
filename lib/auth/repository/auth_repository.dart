// ✅ auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final query = await _firestore
        .collection('users')
        .where('Email', isEqualTo: email)
        .where('Password', isEqualTo: password)
        .get();

    if (query.docs.isNotEmpty) {
      final user = query.docs.first;
      final data = user.data();
      data['id'] = user.id;
      return data;
    }
    return null;
  }

  Future<void> registerUser(String name, String email, String password) async {
    await _firestore.collection('users').add({
      'Name': name,
      'Email': email,
      'Password': password,
      'CreateAt': FieldValue.serverTimestamp(), // ✅ Corregido
    });
  }
}
