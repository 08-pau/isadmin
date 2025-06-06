import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_screen.dart';
import 'package:isadmin/auth/bloc/register/register_bloc.dart';



class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state is RegisterLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
            } else if (state is RegisterSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Se registró exitosamente')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            } else if (state is RegisterFailure) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Sign Up.',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Center(child: Image.asset('assets/registrar.jpg', height: 250)),
                const SizedBox(height: 30),
                const Text("Full Name"),
                const SizedBox(height: 5),
                TextField(controller: _nameController),
                const SizedBox(height: 20),
                const Text("Email"),
                const SizedBox(height: 5),
                TextField(controller: _emailController),
                const SizedBox(height: 20),
                const Text("Password"),
                const SizedBox(height: 5),
                TextField(controller: _passwordController, obscureText: true),
                const SizedBox(height: 20),
                const Text("Confirm Password"),
                const SizedBox(height: 5),
                TextField(controller: _confirmController, obscureText: true),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      context.read<RegisterBloc>().add(
                        RegisterSubmitted(
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                          confirmPassword: _confirmController.text,
                        ),
                      );
                    },
                    child: const Text("Register", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Already have an account? Log in",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
