import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isadmin/tareas/screens/tareas_screen.dart';
import 'package:isadmin/notas/screens/notes_home_screen.dart';
import 'package:isadmin/materias/screens/materias_screen.dart';
import 'package:isadmin/perfil/screens/perfil_screen.dart';
import 'package:isadmin/notas/bloc/notas_bloc.dart';

class StudentDrawer extends StatelessWidget {
  final Map<String, dynamic> userData;

  const StudentDrawer({super.key, required this.userData});

  // Paleta de colores morados consistente
  final Color primaryPurple = const Color(0xFF7C3AED);
  final Color lightPurple = const Color(0xFFB794F4);
  final Color deepPurple = const Color(0xFF5B21B6);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              deepPurple,
              primaryPurple,
              lightPurple,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del usuario
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: deepPurple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: _getRandomColor(),
                        child: Text(
                          _getInitials(userData['Name'] ?? ''),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                          const SizedBox(height: 6),
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

              const SizedBox(height: 24),

              // Título del menú
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Text(
                    "Menú", 
                    style: TextStyle(
                      color: Colors.white70, 
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Elementos del menú
              _buildMenuItem(Icons.check_circle_outline, "Tareas", context, onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TareasScreen()));
              }),

              _buildMenuItem(Icons.note_alt_outlined, "Notas", context, onTap: () {
                Navigator.pop(context);
                final bloc = context.read<NotasBloc>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: const NotesHomeScreen(),
                    ),
                  ),
                );
              }),

              _buildMenuItem(Icons.school, "Cursos", context, onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MateriasScreen()));
              }),

              _buildMenuItem(Icons.person, "Perfil", context, onTap: () {
                Navigator.pop(context);
               Navigator.push(context, MaterialPageRoute(
  builder: (_) => PerfilScreen(uid: userData['id']),
));

              }),

              const Spacer(),

              // Botón de cerrar sesión con efectos
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, BuildContext context,
      {required VoidCallback onTap}) {
    return _AnimatedMenuButton(
      icon: icon,
      title: title,
      onTap: onTap,
      isLogout: false,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return _AnimatedMenuButton(
      icon: Icons.logout,
      title: "Cerrar sesión",
      onTap: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      isLogout: true,
    );
  }

  // Método para obtener las iniciales del nombre
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    } else {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    }
  }

  // Método para obtener un color aleatorio basado en el nombre
  Color _getRandomColor() {
    final colors = [
      const Color(0xFFE91E63), // Rosa
      const Color(0xFF9C27B0), // Púrpura
      const Color(0xFF673AB7), // Púrpura profundo
      const Color(0xFF3F51B5), // Índigo
      const Color(0xFF2196F3), // Azul
      const Color(0xFF00BCD4), // Cian
      const Color(0xFF009688), // Verde azulado
      const Color(0xFF4CAF50), // Verde
      const Color(0xFF8BC34A), // Verde claro
      const Color(0xFFFF9800), // Naranja
      const Color(0xFFFF5722), // Naranja profundo
      const Color(0xFF795548), // Marrón
    ];
    
    // Usar el nombre del usuario para generar un índice consistente
    String name = userData['Name'] ?? 'Usuario';
    int hash = name.hashCode;
    int index = hash.abs() % colors.length;
    
    return colors[index];
  }
}

class _AnimatedMenuButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  const _AnimatedMenuButton({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isLogout,
  });

  @override
  State<_AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<_AnimatedMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.white.withOpacity(0.1),
      end: widget.isLogout 
          ? Colors.red.withOpacity(0.3)
          : Colors.white.withOpacity(0.3),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: widget.isLogout ? 20 : 8,
      ),
      height: 70,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(widget.isLogout ? 0.3 : 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(widget.isLogout ? 0.2 : 0.1),
                      blurRadius: widget.isLogout ? 8 : 6,
                      offset: Offset(0, widget.isLogout ? 4 : 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          widget.icon, 
                          color: Colors.white, 
                          size: widget.isLogout ? 24 : 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.title, 
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}