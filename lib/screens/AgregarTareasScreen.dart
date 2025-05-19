import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarTareasScreen extends StatefulWidget {
  const AgregarTareasScreen({super.key});

  @override
  State<AgregarTareasScreen> createState() => _AgregarTareasScreenState();
}

class _AgregarTareasScreenState extends State<AgregarTareasScreen> {
  final _nombreController = TextEditingController();
  final _detalleController = TextEditingController();
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();

  Future<void> _pickDate(bool isInicio) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        if (isInicio) {
          _fechaInicio = date;
        } else {
          _fechaFin = date;
        }
      });
    }
  }

  Future<void> _guardarTarea() async {
    await FirebaseFirestore.instance.collection('tareas').add({
      'nombre': _nombreController.text,
      'detalle': _detalleController.text,
      'fechaInicio': _fechaInicio,
      'fechaFin': _fechaFin,
      'estado': 'pendiente',
      'createdAt': FieldValue.serverTimestamp(),
    });
    Navigator.pop(context);
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
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        title: const Text("Agregar Tarea", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.2),
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
                  hintText: "Ej. Leer capítulo 3",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel("Fecha de Inicio"),
              ListTile(
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: Text("${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}"),
                trailing: const Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
                onTap: () => _pickDate(true),
              ),
              const SizedBox(height: 20),

              _buildLabel("Fecha de Fin"),
              ListTile(
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: Text("${_fechaFin.day}/${_fechaFin.month}/${_fechaFin.year}"),
                trailing: const Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
                onTap: () => _pickDate(false),
              ),
              const SizedBox(height: 20),

              _buildLabel("Detalle de la Tarea"),
              TextField(
                controller: _detalleController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Describe la tarea...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                icon: const Icon(Icons.add_task),
                label: const Text("Agregar Tarea", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _guardarTarea,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
