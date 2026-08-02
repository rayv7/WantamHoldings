import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/admin_store.dart';
import '../core/routes.dart';
import '../core/user_store.dart';

class RegistrationCard extends StatefulWidget {
  const RegistrationCard({super.key});

  @override
  State<RegistrationCard> createState() => _RegistrationCardState();
}

class _RegistrationCardState extends State<RegistrationCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedBranch = 'Westlands Branch';
  bool _obscurePassword = true;

  final _branches = [
    'Westlands Branch',
    'CBD Branch',
    'Mombasa Branch',
    'Kisumu Branch',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    UserStore.name = _nameController.text.trim();
    UserStore.email = _emailController.text.trim();
    UserStore.phone = _phoneController.text.trim();
    UserStore.branch = _selectedBranch;

    UserStore.save();

    final phone = _phoneController.text.trim();
    AdminStore.addAccount(AdminAccount(
      customerName: _nameController.text.trim(),
      phone: phone,
      email: _emailController.text.trim(),
      branchName: _selectedBranch,
    ));
    AdminStore.setPassword(phone, _passwordController.text);
    AdminStore.savePasswords();

    Routes.pushToDashboard(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: isMobile ? screenWidth * 0.90 : 420,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 22 : 32,
                vertical: isMobile ? 24 : 30,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
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
                  Image.asset(
                    "assets/logos/wantam_logo.jpeg",
                    height: isMobile ? 70 : 82,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Create Account",
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 25 : 29,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0A3A73),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Fill in your details to get started",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 12 : 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          hint: "Full Name",
                          icon: Icons.person_outline,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _emailController,
                          hint: "Email",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              v == null || !v.contains('@') ? 'Enter a valid email' : null,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _phoneController,
                          hint: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Enter your phone number' : null,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _passwordController,
                          hint: "Password",
                          icon: Icons.lock_outline,
                          obscure: true,
                          validator: (v) =>
                              v == null || v.length < 6 ? 'At least 6 characters' : null,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: "Confirm Password",
                          icon: Icons.lock_outline,
                          obscure: true,
                          validator: (v) =>
                              v != _passwordController.text ? 'Passwords do not match' : null,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: _selectedBranch,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.business_outlined),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.80),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
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
                          items: _branches.map((b) => DropdownMenuItem(
                                value: b,
                                child: Text(b, style: GoogleFonts.poppins()),
                              )).toList(),
                          onChanged: (v) {
                            if (v != null) _selectedBranch = v;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
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
                            color: const Color(0xFF0A3A73).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.person_add),
                        label: Text(
                          "CREATE ACCOUNT",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 12 : 13,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Login",
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure && _obscurePassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.80),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
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
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
    );
  }
}