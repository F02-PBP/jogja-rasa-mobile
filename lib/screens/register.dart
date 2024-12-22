import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jogjarasa_mobile/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  String _selectedFood = "Pilih Makanan Favorit";
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final List<String> interestedFood = [
    "Pilih Makanan Favorit",
    "Soto",
    "Gudeg",
    "Bakpia",
    "Sate",
    "Nasi Goreng",
    "Olahan Ayam",
    "Olahan Ikan",
    "Olahan Mie",
    "Kopi",
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange[50]!,
              Colors.orange[100]!,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 12,
              shadowColor: Colors.orange.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.orange[50]!],
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: Colors.orange[800],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ayo daftar dan temukan makanan favoritmu!',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.brown[400],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: 'Masukkan username',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mohon masukkan username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Masukkan email',
                        icon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mohon masukkan email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Mohon masukkan email yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      buildTextField(
                        controller: _fullNameController,
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        icon: Icons.badge_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mohon masukkan nama lengkap';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!),
                          color: Colors.white,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedFood,
                          decoration: InputDecoration(
                            labelText: 'Makanan Favorit',
                            prefixIcon: Icon(Icons.restaurant,
                                color: Colors.orange[800]),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          items: interestedFood.map((String food) {
                            return DropdownMenuItem(
                              value: food,
                              child: Text(food),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedFood = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == "Pilih Makanan Favorit") {
                              return 'Pilih makanan favorit Anda';
                            }
                            return null;
                          },
                          dropdownColor: Colors.white,
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.orange[800]),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Masukkan password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mohon masukkan password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Konfirmasi Password',
                        hint: 'Konfirmasi password Anda',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password Anda';
                          }
                          if (value != _passwordController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final response = await request.postJson(
                                "https://jogja-rasa-production.up.railway.app/auth/register/",
                                jsonEncode({
                                  "username": _usernameController.text,
                                  "password": _passwordController.text,
                                  "email": _emailController.text,
                                  "full_name": _fullNameController.text,
                                  "interested_in": _selectedFood,
                                }));
                            if (context.mounted) {
                              if (response['status'] == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Registrasi berhasil!'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response['message']),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.orange[800],
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
        color: Colors.white,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !(isPasswordVisible ?? false) : false,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.orange[800]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ?? false
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.orange[800],
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        validator: validator,
      ),
    );
  }
}
