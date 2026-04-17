import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';

class WhiteFormfield extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool obscurePassword;
  final Widget? suffix;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final String? hint;
  const WhiteFormfield(
    this.label,
    this.icon, {
    this.hint,
    this.validator,
    required this.obscurePassword,
    this.isPassword = false,
    this.suffix,
    required this.controller,
    super.key,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GTheme.emmense(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: GTheme.isDark(context)
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: TextFormField(
        keyboardType: keyboardType,
        validator: validator,
        controller: controller,
        obscureText: isPassword && obscurePassword,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          hintText: hint,
          prefixIcon: Icon(icon, color: GTheme.primary(context)),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: GTheme.emmense(context),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
