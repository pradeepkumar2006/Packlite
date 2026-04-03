import 'package:flutter/material.dart';

class PackLiteLogo extends StatelessWidget {
  final double size;
  final Color color;

  const PackLiteLogo({
    super.key,
    this.size = 100,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/app_icon_fg.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
