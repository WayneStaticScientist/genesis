import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

class GFormInput extends StatefulWidget {
  final String? icon;
  final String? label;
  final bool isPasswordField;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  const GFormInput({
    super.key,
    this.label,
    this.icon,
    this.validator,
    this.controller,
    this.keyboardType,
    this.isPasswordField = false,
  });

  @override
  State<GFormInput> createState() => _GFormInputState();
}

class _GFormInputState extends State<GFormInput> {
  bool _obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscurePassword && widget.isPasswordField,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        prefixIcon: widget.icon != null
            ? Iconify(widget.icon!, size: 20)
            : null,
        suffixIcon: widget.isPasswordField
            ? IconButton(
                icon: Icon(
                  !_obscurePassword ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        label: widget.label?.text(style: TextStyle(color: Colors.grey)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withAlpha(100)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withAlpha(100)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      validator: widget.validator,
    );
  }
}
