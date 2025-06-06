import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/upload_service.dart';

class UploadScreen extends StatefulWidget {
  final String materiaId;
  const UploadScreen({super.key, required this.materiaId});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with TickerProviderStateMixin {
  final picker = ImagePicker();
  final TextEditingController _descripcionController = TextEditingController();
  File? _archivoSeleccionado;
  String? _tipoSeleccionado;
  bool _isUploading = false;
  
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> subirArchivoConfirmado() async {
    if (_archivoSeleccionado == null || _tipoSeleccionado == null) {
      _mostrarMensaje('Por favor selecciona un archivo', esError: true);
      return;
    }

    if (_descripcionController.text.trim().isEmpty) {
      _mostrarMensaje('Por favor agrega una descripción', esError: true);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final url = await UploadService.subirArchivo(
      archivo: _archivoSeleccionado!,
      tipo: _tipoSeleccionado!,
      materiaId: widget.materiaId,
      descripcion: _descripcionController.text.trim(),
    );

    setState(() {
      _isUploading = false;
    });

    if (url != null) {
  _mostrarMensaje('✅ Archivo subido exitosamente');

  // Espera 1 segundo para mostrar el mensaje y luego cerrar con éxito
  await Future.delayed(const Duration(seconds: 1));

  // Cierra la pantalla y devuelve true para indicar éxito
  Navigator.pop(context, true);
} else {
  _mostrarMensaje('❌ Error al subir archivo', esError: true);
}

  }

  Future<void> seleccionarArchivo(String tipo, {bool usarCamara = false}) async {
    File? archivo;
    if (tipo == 'imagen') {
      final picked = await picker.pickImage(
        source: usarCamara ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) archivo = File(picked.path);
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'],
      );
      if (result != null && result.files.single.path != null) {
        archivo = File(result.files.single.path!);
      }
    }

    if (archivo != null) {
      setState(() {
        _archivoSeleccionado = archivo;
        _tipoSeleccionado = tipo;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              esError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: esError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildUploadArea(),
              const SizedBox(height: 24),
              _buildDescriptionField(),
              const SizedBox(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 32),
              _buildUploadButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Text(
        'Subir Archivo',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildUploadArea() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _archivoSeleccionado == null
            ? _buildEmptyUploadArea()
            : _buildPreviewArea(),
      ),
    );
  }

  Widget _buildEmptyUploadArea() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                size: 64,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Selecciona un archivo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elige una imagen desde galería, cámara\no un documento',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Archivo seleccionado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      _archivoSeleccionado = null;
                      _tipoSeleccionado = null;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPreview(),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_archivoSeleccionado == null) return const SizedBox.shrink();

    if (_tipoSeleccionado == 'imagen') {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _archivoSeleccionado!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.insert_drive_file, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _archivoSeleccionado!.path.split('/').last,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(_archivoSeleccionado!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _descripcionController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Descripción del archivo',
          labelStyle: TextStyle(color: Colors.grey[600]),
          hintText: 'Escribe una descripción detallada...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_outlined, 
                             color: Color(0xFF7C3AED), 
                             size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        const Text(
          'Seleccionar archivo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _buildActionButton(
              icon: Icons.photo_library_outlined,
              label: 'Galería',
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
              ),
              onPressed: () => seleccionarArchivo('imagen'),
            ),
            _buildActionButton(
              icon: Icons.camera_alt_outlined,
              label: 'Cámara',
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
              ),
              onPressed: () => seleccionarArchivo('imagen', usarCamara: true),
            ),
            _buildActionButton(
              icon: Icons.insert_drive_file_outlined,
              label: 'Documento',
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
              ),
              onPressed: () => seleccionarArchivo('documento'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: _archivoSeleccionado != null
            ? const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[400]!],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _archivoSeleccionado != null
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _archivoSeleccionado != null && !_isUploading
              ? subirArchivoConfirmado
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isUploading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(
                    Icons.cloud_upload_rounded,
                    color: _archivoSeleccionado != null 
                        ? Colors.white 
                        : Colors.grey[600],
                    size: 24,
                  ),
                const SizedBox(width: 12),
                Text(
                  _isUploading ? 'Subiendo...' : 'Subir Archivo',
                  style: TextStyle(
                    color: _archivoSeleccionado != null 
                        ? Colors.white 
                        : Colors.grey[600],
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}