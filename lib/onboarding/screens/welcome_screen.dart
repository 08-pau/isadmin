import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/welcome_bloc.dart';
import 'package:isadmin/inicio/screen/inicio_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo morado degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
              ),
            ),
          ),

          // Formas decorativas
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: PreciseBackgroundPainter(),
          ),

          // Contenido central
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.calendar_today, size: 60, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "Is@dmin",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "La mejor manera de controlar tus tareas diarias",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Botón en la parte inferior controlado por BLoC
          Positioned(
            bottom: 30,
            left: 20,
            child: BlocBuilder<WelcomeBloc, WelcomeState>(
              builder: (context, state) {
                if (state is WelcomeLoading) {
                  return const CircularProgressIndicator(color: Colors.white);
                }

                if (state is WelcomeReady) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      context.read<WelcomeBloc>().add(WelcomeCompleted());
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InicioScreen()),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Get Started"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF7C4DFF),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PreciseBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.06);

    canvas.drawCircle(Offset(0, 0), size.width * 0.6, paint);
    canvas.drawCircle(Offset(size.width, 0), size.width * 0.6, paint);

    final path = Path();
    path.moveTo(size.width * 0.7, size.height * 0.7);
    path.cubicTo(
      size.width * 0.35, size.height * 0.35,
      size.width * 0.7, size.height * 0.35,
      size.width * 0.75, size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.8, size.height * 0.65,
      size.width * 0.25, size.height * 0.7,
      size.width * 0.2, size.height * 0.45,
    );
    path.close();
    canvas.drawPath(path, paint);

    canvas.drawCircle(Offset(size.width * 0.5, size.height), size.width * 0.4, paint);
    canvas.drawCircle(Offset(size.width, size.height * 0.9), size.width * 0.4, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
