import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../screens/dashboard_screen.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 380,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),

                  borderRadius: BorderRadius.circular(28),

                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 40,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset("assets/logos/wantam_logo.jpeg", height: 95),

                    const SizedBox(height: 18),

                    Text(
                      "Login",
                      style: GoogleFonts.poppins(
                        fontSize: 31,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A3A73),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Enter your credentials to continue",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Username or Email",

                        prefixIcon: const Icon(Icons.person_outline),

                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.80),

                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 18,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF0A3A73),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,

                      decoration: InputDecoration(
                        hintText: "Password",

                        prefixIcon: const Icon(Icons.lock_outline),

                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.80),

                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 18,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF0A3A73),
                            width: 2,
                          ),
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),

                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,

                      child: TextButton(
                        onPressed: () {},

                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0A3A73),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF0A3A73), Color(0xFF1565C0)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF0A3A73,
                              ).withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final result = await _apiService.login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Login successful"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DashboardScreen(),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),

                          icon: const Icon(Icons.login),

                          label: Text(
                            "LOGIN",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade400)),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "OR",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        Expanded(child: Divider(color: Colors.grey.shade400)),
                      ],
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {},

                        icon: const Icon(
                          Icons.fingerprint,
                          color: Color(0xFF0A3A73),
                        ),

                        label: Text(
                          "Login with Biometric",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0A3A73),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0A3A73)),
                          backgroundColor: Colors.white.withValues(alpha: 0.45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),

                        TextButton(
                          onPressed: () {},

                          child: Text(
                            "Sign Up",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0A3A73),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
