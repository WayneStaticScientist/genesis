import 'package:flutter/material.dart';
import 'package:genesis/models/user_model.dart';

class AvatarIcon extends StatelessWidget {
  final String name;
  final Color? color;
  final Color? surfaceColor;
  const AvatarIcon({
    super.key,
    required this.name,
    this.color,
    this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final user = User.fromStorage();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.indigo, width: 2),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.indigoAccent,
        radius: 18,
        child: Text(
          user != null && user.firstName.isNotEmpty
              ? user.firstName[0].toUpperCase()
              : 'x',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
