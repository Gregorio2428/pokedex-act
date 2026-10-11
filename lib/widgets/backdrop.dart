import 'package:flutter/material.dart';

/// Pastel gradient with soft "light blobs" so the glass has something to blur.
class PastelBackdrop extends StatelessWidget {
  const PastelBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD9EC), Color(0xFFE0D4FF), Color(0xFFCDEBFF)],
            ),
          ),
        ),
        _blob(top: -60, left: -50, size: 240, color: const Color(0xFFFF9CCB)),
        _blob(top: 260, right: -80, size: 280, color: const Color(0xFFA98BFF)),
        _blob(bottom: -70, left: 30, size: 260, color: const Color(0xFF8FD6FF)),
      ],
    );
  }

  Widget _blob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withAlpha(170), color.withAlpha(0)],
          ),
        ),
      ),
    );
  }
}