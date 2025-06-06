import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/actividades_bloc.dart';
import '../bloc/actividades_event.dart';
import '../bloc/actividades_state.dart';

import 'EditActivityScreen.dart';



class EditActivityScreen extends StatefulWidget {
  final String materiaId;
  final String actividadId;
  final Map<String, dynamic> actividad;

  const EditActivityScreen({
    super.key,
    required this.materiaId,
    required this.actividadId,
    required this.actividad,
  });

  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late String _urgencia;

  final List<String> urgenciaLevels = ['Baja', 'Normal', 'Urgente'];
  final violet = const Color(0xFF7C3AED);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.actividad['titulo'] ?? '');
    _descripcionController = TextEditingController(text: widget.actividad['descripcion'] ?? '');
    _urgencia = widget.actividad['urgencia'] ?? 'Normal';
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      context.read<ActividadesBloc>().add(EditarActividad(
  materiaId: widget.materiaId,
        actividadId: widget.actividadId,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        urgencia: _urgencia,
      ));

      // Simular un pequeño delay para mostrar el loading
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getUrgenciaColor(String urgencia) {
    switch (urgencia) {
      case 'Baja':
        return Colors.green;
      case 'Urgente':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getUrgenciaIcon(String urgencia) {
    switch (urgencia) {
      case 'Baja':
        return Icons.low_priority;
      case 'Urgente':
        return Icons.priority_high;
      default:
        return Icons.flag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: violet,
        elevation: 0,
        title: const Text(
          'Editar Actividad',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
     body: BlocListener<ActividadesBloc, ActividadesState>(
  listener: (context, state) {
    if (state is ActividadesError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.mensaje}'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (state is! ActividadesLoading && state is! ActividadesError) {
      // Suponiendo que si no hay error, y no está cargando, es éxito
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actividad actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  },


        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con icono
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: violet.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_note,
                      size: 60,
                      color: violet,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Campo Título
                Text(
                  'Título de la actividad',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: violet,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    hintText: 'Ej: Exposición de Historia, Proyecto Final...',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: violet, width: 2),
                    ),
                    prefixIcon: Icon(Icons.task_alt, color: violet),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el título de la actividad';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Campo Descripción
                Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: violet,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe los detalles de la actividad...',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: violet, width: 2),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Icon(Icons.description, color: violet),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa la descripción de la actividad';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Campo Urgencia
                Text(
                  'Nivel de urgencia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: violet,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _urgencia,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: violet, width: 2),
                    ),
                    prefixIcon: Icon(
                      _getUrgenciaIcon(_urgencia),
                      color: _getUrgenciaColor(_urgencia),
                    ),
                  ),
                  items: urgenciaLevels.map((urgencia) {
                    return DropdownMenuItem(
                      value: urgencia,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getUrgenciaColor(urgencia),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(urgencia),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _urgencia = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Información de la actividad actual
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: violet.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: violet.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: violet, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Información actual',
                            style: TextStyle(
                              color: violet,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Editando: ${widget.actividad['titulo'] ?? 'Sin título'}',
                        style: TextStyle(
                          color: violet.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Urgencia actual: ${widget.actividad['urgencia'] ?? 'Normal'}',
                        style: TextStyle(
                          color: violet.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: violet),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: violet, fontSize: 16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: violet,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Actualizar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}