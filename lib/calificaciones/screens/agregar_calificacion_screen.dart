import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/calificaciones_bloc.dart';
import '../bloc/calificaciones_event.dart';

class AgregarCalificacionScreen extends StatefulWidget {
  final String materiaId;

  const AgregarCalificacionScreen({
    super.key,
    required this.materiaId,
  });

  @override
  State<AgregarCalificacionScreen> createState() => _AgregarCalificacionScreenState();
}

class _AgregarCalificacionScreenState extends State<AgregarCalificacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _notaController = TextEditingController();
  final _porcentajeObtenidoController = TextEditingController();
  final _porcentajeTotalController = TextEditingController();
  
  final violet = const Color(0xFF7C3AED);
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _notaController.dispose();
    _porcentajeObtenidoController.dispose();
    _porcentajeTotalController.dispose();
    super.dispose();
  }

  void _guardarCalificacion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final nombre = _nombreController.text.trim();
      final nota = double.tryParse(_notaController.text.trim()) ?? 0;
      final porcentajeObtenido = double.tryParse(_porcentajeObtenidoController.text.trim()) ?? 0;
      final porcentajeTotal = double.tryParse(_porcentajeTotalController.text.trim()) ?? 0;

      context.read<CalificacionesBloc>().add(
        AgregarCalificacion(
          materiaId: widget.materiaId,
          nombre: nombre,
          nota: nota,
          porcentajeObtenido: porcentajeObtenido,
          porcentajeTotal: porcentajeTotal,
        ),
      );

      // Simular un pequeño delay para mostrar el loading
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calificación agregada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
          'Agregar Calificación',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
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
                    Icons.assignment_turned_in,
                    size: 60,
                    color: violet,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Campo Nombre
              Text(
                'Nombre de la evaluación',
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
                  hintText: 'Ej: Examen parcial, Quiz, Tarea...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
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
                  prefixIcon: Icon(Icons.title, color: violet),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el nombre de la evaluación';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Campo Nota
              Text(
                'Nota obtenida',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: violet,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ej: 85, 92.5...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
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
                  prefixIcon: Icon(Icons.grade, color: violet),
                  suffixText: 'pts',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa la nota obtenida';
                  }
                  final nota = double.tryParse(value.trim());
                  if (nota == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  if (nota < 0 || nota > 100) {
                    return 'La nota debe estar entre 0 y 100';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Campos de porcentaje en fila
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Porcentaje obtenido',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: violet,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _porcentajeObtenidoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '15',
                            hintStyle: TextStyle(color: Colors.grey[400]),
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
                            prefixIcon: Icon(Icons.percent, color: violet),
                            suffixText: '%',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Requerido';
                            }
                            final porcentaje = double.tryParse(value.trim());
                            if (porcentaje == null) {
                              return 'Número inválido';
                            }
                            if (porcentaje < 0 || porcentaje > 100) {
                              return '0-100%';
                            }
                            return null;
                          },
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
                          'Porcentaje total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: violet,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _porcentajeTotalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '20',
                            hintStyle: TextStyle(color: Colors.grey[400]),
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
                            prefixIcon: Icon(Icons.percent_outlined, color: violet),
                            suffixText: '%',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Requerido';
                            }
                            final porcentaje = double.tryParse(value.trim());
                            if (porcentaje == null) {
                              return 'Número inválido';
                            }
                            if (porcentaje <= 0 || porcentaje > 100) {
                              return '1-100%';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Información adicional
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: violet.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: violet.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: violet, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'El porcentaje obtenido representa cuánto vale esta calificación del total de la materia.',
                        style: TextStyle(
                          color: violet.withOpacity(0.8),
                          fontSize: 14,
                        ),
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
                      onPressed: _isLoading ? null : _guardarCalificacion,
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
                              'Guardar',
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
    );
  }
}