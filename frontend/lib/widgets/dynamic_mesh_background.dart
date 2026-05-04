import 'package:flutter/material.dart';
import 'dart:math' as math;

class DynamicMeshBackground extends StatefulWidget {
  final Widget child;
  const DynamicMeshBackground({super.key, required this.child});

  @override
  State<DynamicMeshBackground> createState() => _DynamicMeshBackgroundState();
}

class _DynamicMeshBackgroundState extends State<DynamicMeshBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark Base
        Positioned.fill(child: Container(color: Colors.black)),
        
        // Animated Orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                _buildOrb(context, 0.2, 0.3, 300, Colors.deepPurple.withOpacity(0.15), 1.0),
                _buildOrb(context, 0.8, 0.7, 400, Colors.blue.withOpacity(0.1), 1.2),
                _buildOrb(context, 0.5, 0.2, 250, Colors.teal.withOpacity(0.12), 0.8),
              ],
            );
          },
        ),

        // Mesh Grid
        Positioned.fill(
          child: CustomPaint(
            painter: MeshGridPainter(),
          ),
        ),

        // Vignette
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),
        ),

        // Child
        widget.child,
      ],
    );
  }

  Widget _buildOrb(BuildContext context, double x, double y, double size, Color color, double speedMult) {
    final t = _controller.value * 2 * math.pi * speedMult;
    final dx = math.sin(t) * 50;
    final dy = math.cos(t) * 30;
    
    return Positioned(
      left: MediaQuery.of(context).size.width * x + dx - size/2,
      top: MediaQuery.of(context).size.height * y + dy - size/2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 100,
              spreadRadius: 20,
            )
          ],
        ),
      ),
    );
  }
}

class MeshGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;
    
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Add some diagonal lines for complexity
    final diagPaint = Paint()
      ..color = Colors.white.withOpacity(0.01)
      ..strokeWidth = 0.5;

    for (double i = -size.height; i < size.width; i += spacing * 4) {
       canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), diagPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
