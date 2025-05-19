import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  late TextEditingController _nombreController;
  late String _estado;
  late DateTime _fechaInicio;
  late DateTime _fechaFin;

  final List<String> estados = ['pendiente', 'completada', 'anulada'];
  final dateFormat = DateFormat('dd/MM/yyyy');
  final violet = const Color(0xFF7C3AED);

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

  Future<void> _guardarCambios() async {
    await FirebaseFirestore.instance.collection('tareas').doc(widget.id).update({
      'nombre': _nombreController.text,
      'estado': _estado,
      'fechaInicio': _fechaInicio,
      'fechaFin': _fechaFin,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarea actualizada')),
    );

    Navigator.pop(context);
  }

  Future<void> _pickDate(bool esInicio) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: esInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0FF),
      appBar: AppBar(
        backgroundColor: violet,
        elevation: 0,
        title: const Text("Editar Tarea", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: violet.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Nombre de la Tarea"),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  hintText: "Ej. Estudiar para examen",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel("Estado"),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: estados.map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(estado[0].toUpperCase() + estado.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _estado = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              _buildLabel("Fecha de Inicio"),
              ListTile(
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: Text(dateFormat.format(_fechaInicio)),
                trailing: const Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
                onTap: () => _pickDate(true),
              ),
              const SizedBox(height: 20),

              _buildLabel("Fecha de Fin"),
              ListTile(
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: Text(dateFormat.format(_fechaFin)),
                trailing: const Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
                onTap: () => _pickDate(false),
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Guardar Cambios", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: violet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _guardarCambios,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
