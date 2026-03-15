import 'package:flutter/material.dart';
import 'package:genesis/utils/theme.dart';

class DefaultFormfield extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool? editable;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final VoidCallback? ontap;
  const DefaultFormfield({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.controller,
    this.validator,
    this.ontap,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GTheme.reverse(context).withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        readOnly: editable == null ? false : !editable!,
        onTap: () => ontap?.call(),
        validator: validator,
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: GTheme.reverse(context)),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          labelStyle: const TextStyle(fontSize: 14),
          hintStyle: TextStyle(
            color: GTheme.reverse(context).withAlpha(100),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
