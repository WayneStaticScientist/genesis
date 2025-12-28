import 'package:exui/exui.dart';
import 'package:flutter/material.dart';

class GFormButton extends StatelessWidget {
  final VoidCallback? onPress;
  final bool isLoading;
  final String label;
  const GFormButton({
    super.key,
    this.onPress,
    this.isLoading = false,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (isLoading) {
            return;
          }
          onPress?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : label.text(
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
