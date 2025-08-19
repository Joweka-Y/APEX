import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!showText) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Name
        Text(
          'APEX',
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.blue,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          'CARS',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w300,
            color: (color ?? Colors.blue).withOpacity(0.7),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
