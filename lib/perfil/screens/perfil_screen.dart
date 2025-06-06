import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../bloc/perfil_bloc.dart';
import '../bloc/perfil_event.dart';
import '../bloc/perfil_state.dart';
// Importa tu repositorio de estadísticas
import 'package:isadmin/perfil/repository/estadisticas_repository.dart';

class PerfilScreen extends StatelessWidget {
  final String uid;

  const PerfilScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PerfilBloc(repository: context.read())..add(CargarPerfil(uid)),
      child: _PerfilContenido(uid: uid),
    );
  }
}

class _PerfilContenido extends StatefulWidget {
  final String uid;
  
  const _PerfilContenido({super.key, required this.uid});

  @override
  State<_PerfilContenido> createState() => _PerfilContenidoState();
}

class _PerfilContenidoState extends State<_PerfilContenido> {
  // Paleta de colores morados consistente con StudentDrawer
  final Color primaryPurple = const Color(0xFF7C3AED);
  final Color lightPurple = const Color(0xFFB794F4);
  final Color deepPurple = const Color(0xFF5B21B6);
  
  final EstadisticasRepository _estadisticasRepository = EstadisticasRepository();
  
  // Variables para las estadísticas
  Map<String, int> estadisticas = {
    'notas': 0,
    'materias': 0,
    'tareas': 0,
    'diasActivo': 0,
  };
  
  bool cargandoEstadisticas = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _inicializarPerfil();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Método principal de inicialización
  Future<void> _inicializarPerfil() async {
    // 1. Registrar actividad del día actual
    await _registrarActividadDiaria();
    
    // 2. Cargar estadísticas iniciales
    await _cargarEstadisticas();
    
    // 3. Configurar actualización automática
    _configurarActualizacionAutomatica();
  }

  // Registrar que el usuario estuvo activo hoy
  Future<void> _registrarActividadDiaria() async {
    try {
      await _estadisticasRepository.registrarActividadDiaria(widget.uid);
    } catch (e) {
      print('Error registrando actividad diaria: $e');
    }
  }

  Future<void> _cargarEstadisticas() async {
    try {
      final stats = await _estadisticasRepository.obtenerEstadisticas(widget.uid);
      if (mounted) {
        setState(() {
          estadisticas = stats;
          cargandoEstadisticas = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          cargandoEstadisticas = false;
        });
      }
    }
  }

  // Configurar actualización automática más eficiente
  void _configurarActualizacionAutomatica() {
    // Actualizar cada 60 segundos en lugar de 30 para reducir carga
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      if (mounted) {
        // Solo actualizar si la pantalla está visible
        try {
          final stats = await _estadisticasRepository.obtenerEstadisticas(widget.uid);
          if (mounted) {
            setState(() {
              estadisticas = stats;
            });
          }
        } catch (e) {
          print('Error en actualización automática: $e');
        }
      }
    });
  }

  // Método para refrescar manualmente
  Future<void> _refrescarEstadisticas() async {
    setState(() {
      cargandoEstadisticas = true;
    });
    
    // Registrar actividad nuevamente por si acaso
    await _registrarActividadDiaria();
    
    // Recargar estadísticas
    await _cargarEstadisticas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PerfilBloc, PerfilState>(
        builder: (context, state) {
          if (state is PerfilCargando) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [deepPurple, primaryPurple, lightPurple],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          } else if (state is PerfilCargado) {
            final userData = state.userData;
            final name = userData['Name']?.toString() ?? 'Usuario';
            final email = userData['Email']?.toString() ?? '';
            final fecha = _formatearFecha(userData['CreateAt']);

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [deepPurple, primaryPurple, lightPurple],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header con avatar y información básica
                    _buildHeader(context, name, userData),
                    
                    // Contenido con tarjetas de información
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: RefreshIndicator(
                          onRefresh: _refrescarEstadisticas,
                          color: primaryPurple,
                          child: ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                                                   const SizedBox(height: 20),
                              _buildSectionTitle('Información Personal'),
                              const SizedBox(height: 16),
                              _buildInfoCard(Icons.person_outline, 'Nombre Completo', name, primaryPurple),
                              const SizedBox(height: 12),
                              _buildInfoCard(Icons.email_outlined, 'Correo Electrónico', email, primaryPurple),
                              const SizedBox(height: 12),
                              _buildInfoCard(Icons.calendar_today_outlined, 'Fecha de Registro', fecha, primaryPurple),
                              const SizedBox(height: 32),
                              _buildSectionTitle('Mis Estadísticas'),
                              const SizedBox(height: 16),
                              
                              // Estadísticas reales
                              if (cargandoEstadisticas) 
                                _buildCargandoEstadisticas()
                              else
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatCard(
                                            'Tareas', 
                                            estadisticas['tareas'].toString(), 
                                            Icons.assignment_outlined, 
                                            primaryPurple
                                          )
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildStatCard(
                                            'Notas', 
                                            estadisticas['notas'].toString(), 
                                            Icons.note_outlined, 
                                            primaryPurple
                                          )
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatCard(
                                            'Cursos', 
                                            estadisticas['materias'].toString(), 
                                            Icons.school_outlined, 
                                            primaryPurple
                                          )
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildStatCard(
                                            'Días Activo', 
                                            estadisticas['diasActivo'].toString(), 
                                            Icons.today_outlined, 
                                            primaryPurple
                                          )
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildActividadInfo(),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is PerfilError) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [deepPurple, primaryPurple, lightPurple],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      state.mensaje,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refrescarEstadisticas,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryPurple,
                      ),
                      child: const Text('Intentar de nuevo'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildCargandoEstadisticas() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando estadísticas...',
            style: TextStyle(
              color: primaryPurple,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: primaryPurple.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.timeline, color: primaryPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Actividad Reciente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.circle, color: Colors.green, size: 12),
              const SizedBox(width: 8),
              Text(
                'Activo hoy - ${_formatearHora(DateTime.now())}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Días únicos activos: ${estadisticas['diasActivo']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, Map<String, dynamic> userData) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Botón de regreso
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                ),
              ),
              const Expanded(
                child: Text(
                  'Mi Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 44), // Balance visual
            ],
          ),
          
          const SizedBox(height: 16), // Reducido de 32 a 16
          
          // Avatar principal - más cercano al título
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: _getRandomColor(userData),
              child: Text(
                _getInitials(name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Solo el nombre del usuario
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: deepPurple,
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatearFecha(dynamic timestamp) {
    if (timestamp == null) return 'No disponible';
    try {
      final DateTime date = (timestamp is Timestamp)
          ? timestamp.toDate()
          : (timestamp is DateTime)
              ? timestamp
              : DateTime.tryParse(timestamp.toString()) ?? DateTime(2000);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return 'Fecha inválida';
    }
  }

  String _formatearHora(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Método para obtener las iniciales del nombre - igual que StudentDrawer
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    } else {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    }
  }

  // Método para obtener un color aleatorio basado en el nombre - igual que StudentDrawer
  Color _getRandomColor(Map<String, dynamic> userData) {
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