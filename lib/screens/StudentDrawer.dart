import 'package:flutter/material.dart';
import 'materias_screen.dart';
import 'tareas_screen.dart';
import 'notes_home_screen.dart';
import 'PerfilScreen.dart';

class StudentDrawer extends StatelessWidget {
  final Map<String, dynamic> userData;

  const StudentDrawer({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF7C3AED),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con el nombre del usuario
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "¡Hola, ${userData['Name']}!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Administra tu día 👋",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const Divider(color: Colors.white38),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Menú", style: TextStyle(color: Colors.white70, fontSize: 14)),
            ),
            const SizedBox(height: 10),

            _buildMenuItem(Icons.check_circle_outline, "Tareas", context, onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TareasScreen()),
              );
            }),

            _buildMenuItem(Icons.note_alt_outlined, "Notas", context, onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotesHomeScreen()),
              );
            }),

            _buildMenuItem(Icons.school, "Cursos", context, onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MateriasScreen()),
              );
            }),

            _buildMenuItem(Icons.person, "Perfil", context, onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PerfilScreen(userData: userData),
                ),
              );
            }),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),

            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
