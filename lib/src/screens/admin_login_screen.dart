import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:approb/src/firebase/firebase_config.dart';
import 'package:approb/src/utils/constants.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Introduceți email și parolă.";
        _isLoading = false;
      });
      return;
    }

    final user = await FirebaseConfig.signInWithEmailAndPassword(email, password);

    if (!mounted) return;

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isAdmin", true);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/calendar_screen');
    } else {
      setState(() {
        _errorMessage = "Autentificare eșuată.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Login"),
        backgroundColor: kPrimaryColor,  // Folosim culoarea primară din constants.dart
      ),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),  // Folosim padding-ul din constants.dart
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Autentificare Admin",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Parolă",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _login,
                    icon: const Icon(Icons.login),
                    label: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Autentificare"),
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
