import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarMateriaScreen extends StatelessWidget {
  const AgregarMateriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController profesorController = TextEditingController();
    final TextEditingController horarioController = TextEditingController();

    Future<void> _guardarMateria() async {
      final nombre = nombreController.text.trim();
      final profesor = profesorController.text.trim();
      final horario = horarioController.text.trim();

      if (nombre.isEmpty || profesor.isEmpty || horario.isEmpty) {
        _mostrarDialogo(
            context, "Campos incompletos", "Por favor completa todos los campos.");
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('materias').add({
          'nombre': nombre,
          'profesor': profesor,
          'horario': horario,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _mostrarDialogo(
            context, "¡Materia agregada!", "Se guardó exitosamente.");
        nombreController.clear();
        profesorController.clear();
        horarioController.clear();
      } catch (e) {
        _mostrarDialogo(
            context, "Error", "No se pudo guardar la materia: $e");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Materia"),
        backgroundColor: const Color(0xFF7C3AED),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                labelText: "Nombre de la materia",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: profesorController,
              decoration: InputDecoration(
                labelText: "Nombre del profesor",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: horarioController,
              decoration: InputDecoration(
                labelText: "Horario (ej: Lunes 10 AM)",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _guardarMateria,
              icon: const Icon(Icons.save),
              label: const Text("Guardar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogo(BuildContext context, String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}