import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const PerfilScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF7C3AED);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Perfil del Usuario'),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF3F4F6),
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundImage: const AssetImage('assets/profile.jpg'),
            ),
            const SizedBox(height: 16),
            Text(
              userData['Name'] ?? 'Usuario',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userData['Email'] ?? '',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildInfoCard(
                    icon: Icons.person,
                    title: 'Nombre',
                    value: userData['Name'] ?? '',
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    title: 'Correo',
                    value: userData['Email'] ?? '',
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Fecha de registro',
                    value: _formatearFecha(userData['CreateAt']),
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(dynamic timestamp) {
    if (timestamp == null) return 'No disponible';
    try {
      final DateTime date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return 'Fecha inválida';
    }
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}