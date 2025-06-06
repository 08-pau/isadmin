import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/editar_tarea_bloc.dart';

class EditTaskScreen extends StatefulWidget {
  final String id;
  final Map<String, dynamic> tarea;

  const EditTaskScreen({
    super.key,
    required this.id,
    required this.tarea,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late String _estado;
  late DateTime _fechaInicio;
  late DateTime _fechaFin;

  final List<String> estados = ['pendiente', 'completada', 'anulada'];
  final dateFormat = DateFormat('dd/MM/yyyy');
  final violet = const Color(0xFF7C3AED);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.tarea['nombre']);
    _estado = widget.tarea['estado'] ?? 'pendiente';
    _fechaInicio = (widget.tarea['fechaInicio'] as Timestamp).toDate();
    _fechaFin = (widget.tarea['fechaFin'] as Timestamp).toDate();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      context.read<EditarTareaBloc>().add(GuardarCambiosTarea(
        id: widget.id,
        nombre: _nombreController.text.trim(),
        estado: _estado,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
      ));

      // Simular un pequeño delay para mostrar el loading
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate(bool esInicio) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: esInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: violet,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (esInicio) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'completada':
        return Colors.green;
      case 'anulada':
        return Colors.red;
      default:
        return Colors.orange;
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
          'Editar Tarea',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<EditarTareaBloc, EditarTareaState>(
        listener: (context, state) {
          if (state is EditarTareaSuccess) {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tarea actualizada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else if (state is EditarTareaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.mensaje}'),
                backgroundColor: Colors.red,
              ),
            );
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
                
                // Campo Nombre
                Text(
                  'Nombre de la tarea',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: violet,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    hintText: 'Ej: Estudiar para examen, Completar proyecto...',
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
                      return 'Por favor ingresa el nombre de la tarea';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Campo Estado
                Text(
                  'Estado de la tarea',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: violet,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _estado,
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
                      Icons.flag,
                      color: _getEstadoColor(_estado),
                    ),
                  ),
                  items: estados.map((estado) {
                    return DropdownMenuItem(
                      value: estado,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getEstadoColor(estado),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(estado[0].toUpperCase() + estado.substring(1)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _estado = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Campos de fecha en fila
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de inicio',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: violet,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _pickDate(true),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: violet, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      dateFormat.format(_fechaInicio),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de fin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: violet,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _pickDate(false),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: violet, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      dateFormat.format(_fechaFin),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Información de la tarea actual
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
                        'Editando: ${widget.tarea['nombre'] ?? 'Sin nombre'}',
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