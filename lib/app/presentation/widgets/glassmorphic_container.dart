// lib/app/presentation/widgets/glassmorphic_container.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final double borderRadius;

  const GlassmorphicContainer({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: Colors.white.withOpacity(0.13)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}