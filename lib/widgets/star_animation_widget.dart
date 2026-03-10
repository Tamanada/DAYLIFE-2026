import 'dart:math';
import 'package:flutter/material.dart';

class StarAnimationWidget extends StatefulWidget {
  final int starCount;
  final VoidCallback? onComplete;

  const StarAnimationWidget({super.key, this.starCount = 8, this.onComplete});

  @override
  State<StarAnimationWidget> createState() => _StarAnimationWidgetState();
}

class _StarAnimationWidgetState extends State<StarAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_StarParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _particles = List.generate(widget.starCount, (_) => _StarParticle(
      angle: _random.nextDouble() * 2 * pi,
      speed: 80 + _random.nextDouble() * 120,
      size: 12 + _random.nextDouble() * 12,
    ));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete?.call();
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarBurstPainter(particles: _particles, progress: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _StarParticle {
  final double angle, speed, size;
  _StarParticle({required this.angle, required this.speed, required this.size});
}

class _StarBurstPainter extends CustomPainter {
  final List<_StarParticle> particles;
  final double progress;

  _StarBurstPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final distance = p.speed * progress;
      final x = center.dx + cos(p.angle) * distance;
      final y = center.dy + sin(p.angle) * distance;
      final starSize = p.size * (1.0 - progress * 0.5);

      canvas.save();
      canvas.translate(x, y);
      final paint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      _drawStar(canvas, starSize, paint);
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final outerR = size / 2;
    final innerR = size / 4;
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * pi / 5) - pi / 2;
      final point = Offset(cos(angle) * r, sin(angle) * r);
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarBurstPainter old) => old.progress != progress;
}

void showStarAnimation(BuildContext context, {int stars = 1}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200, height: 200,
                child: StarAnimationWidget(
                  starCount: stars * 4,
                  onComplete: () => entry.remove(),
                ),
              ),
              Text('+$stars', style: const TextStyle(
                color: Color(0xFFFFD700), fontSize: 28, fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
              )),
            ],
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
}
