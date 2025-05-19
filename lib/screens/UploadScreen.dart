import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'upload_service.dart';

class UploadScreen extends StatefulWidget {
  final String materiaId;
  const UploadScreen({super.key, required this.materiaId});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final picker = ImagePicker();
  final TextEditingController _descripcionController = TextEditingController();
  File? _archivoSeleccionado;
  String? _tipoSeleccionado;

  Future<void> subirArchivoConfirmado() async {
    if (_archivoSeleccionado == null || _tipoSeleccionado == null) return;

    final url = await UploadService.subirArchivo(
      archivo: _archivoSeleccionado!,
      tipo: _tipoSeleccionado!,
      materiaId: widget.materiaId,
      descripcion: _descripcionController.text.trim(),
    );

    if (url != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Archivo subido')),
      );
      setState(() {
        _archivoSeleccionado = null;
        _tipoSeleccionado = null;
        _descripcionController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error al subir archivo')),
      );
    }
  }

  Future<void> seleccionarArchivo(String tipo) async {
    File? archivo;
    if (tipo == 'imagen') {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) archivo = File(picked.path);
    } else {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        archivo = File(result.files.single.path!);
      }
    }

    if (archivo != null) {
      setState(() {
        _archivoSeleccionado = archivo;
        _tipoSeleccionado = tipo;
      });
    }
  }

  Widget _buildPreview() {
    if (_archivoSeleccionado == null) return const SizedBox.shrink();

    if (_tipoSeleccionado == 'imagen') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_archivoSeleccionado!, height: 200, fit: BoxFit.cover),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _archivoSeleccionado!.path.split('/').last,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subir archivo'),
        backgroundColor: const Color(0xFF7C3AED),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPreview(),
              const SizedBox(height: 10),
              TextField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: const Icon(Icons.description, color: Color(0xFF7C3AED)),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => seleccionarArchivo('imagen'),
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text('Imagen', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => seleccionarArchivo('documento'),
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text('Documento', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload, color: Colors.white),
                label: const Text('Subir archivo', style: TextStyle(color: Colors.white)),
                onPressed: subirArchivoConfirmado,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
