import 'package:flutter/material.dart';
import 'dart:math';
import '../../features/weather/domain/entities/weather_condition.dart';

class AnimatedWeatherBackground extends StatefulWidget {
  final Widget child;
  final WeatherCondition condition;
  final bool isNight;
  final double windSpeed;

  const AnimatedWeatherBackground({
    super.key,
    required this.child,
    required this.condition,
    this.isNight = false,
    this.windSpeed = 0,
  });

  @override
  State<AnimatedWeatherBackground> createState() =>
      _AnimatedWeatherBackgroundState();
}

class _AnimatedWeatherBackgroundState extends State<AnimatedWeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _cloudAnimationController;
  late AnimationController _windAnimationController;
  late AnimationController _sunAnimationController;
  late AnimationController _moonAnimationController;
  late AnimationController _smokeAnimationController;

  @override
  void initState() {
    super.initState();
    _cloudAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _smokeAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _windAnimationController = AnimationController(
      duration: Duration(seconds: (30 / (widget.windSpeed + 1)).toInt()),
      vsync: this,
    )..repeat();

    _sunAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _moonAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloudAnimationController.dispose();
    _windAnimationController.dispose();
    _sunAnimationController.dispose();
    _moonAnimationController.dispose();
    _smokeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background gradient based on condition
          Container(
            decoration: BoxDecoration(
              gradient: _getBackgroundGradient(),
            ),
          ),

          if (widget.condition == WeatherCondition.misty) _buildMistAnimation(),

          if (widget.windSpeed > 1) _buildWindAnimation(),

          // Weather-specific animations
          if (!widget.isNight && widget.condition == WeatherCondition.clear)
            _buildSunAnimation(),
          if (widget.isNight) _buildMoonAnimation(),
          if (widget.condition == WeatherCondition.cloudy ||
              widget.condition == WeatherCondition.rainy ||
              widget.condition == WeatherCondition.thunderstorm)
            _buildCloudAnimation(),
          // 🌧️ Light Rain
          if (widget.condition == WeatherCondition.rainy) _buildRainAnimation(),

          // ⛈️ Thunderstorm = rain + lightning
          if (widget.condition == WeatherCondition.thunderstorm) ...[
            _buildRainAnimation(),
            _buildLightningAnimation(),
          ],

          // ☁️ Clouds
          if (widget.condition == WeatherCondition.cloudy ||
              widget.condition == WeatherCondition.rainy ||
              widget.condition == WeatherCondition.thunderstorm)
            _buildCloudAnimation(),
          // 🌫️ Smoke/Mist
          if (widget.condition == WeatherCondition.smoke)
            _buildSmokeAnimation(),

          if (widget.condition != WeatherCondition.clear)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.25),
                  ],
                ),
              ),
            ),

          // Content
          SafeArea(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildRainAnimation() {
    return AnimatedBuilder(
      animation: _cloudAnimationController,
      builder: (_, __) {
        return Positioned.fill(
          child: CustomPaint(
            painter: RainPainter(
              animationValue: _cloudAnimationController.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmokeAnimation() {
    return AnimatedBuilder(
      animation: _smokeAnimationController,
      builder: (_, __) {
        return Positioned.fill(
          child: CustomPaint(
            painter: SmokePainter(
              animationValue: _smokeAnimationController.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLightningAnimation() {
    return AnimatedBuilder(
      animation: _cloudAnimationController,
      builder: (_, __) {
        return Positioned.fill(
          child: CustomPaint(
            painter: LightningPainter(
              animationValue: _cloudAnimationController.value,
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getBackgroundGradient() {
    if (widget.isNight) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0F2027),
          const Color(0xFF203A43),
          const Color(0xFF2C5364),
        ],
      );
    }

    switch (widget.condition) {
      case WeatherCondition.clear:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4FACFE), // sky blue
            Color(0xFF00C6FB),
            Color(0xFFB3E5FC),
          ],
        );

      case WeatherCondition.cloudy:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey.shade400,
            Colors.blueGrey.shade200,
          ],
        );

      case WeatherCondition.misty:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFB0BEC5),
            const Color(0xFFECEFF1),
          ],
        );

      case WeatherCondition.snowy:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE0E7FF),
            Color(0xFFF5F5F5),
          ],
        );

      case WeatherCondition.rainy:
      case WeatherCondition.thunderstorm:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF37474F),
            const Color(0xFF263238),
          ],
        );
      case WeatherCondition.smoke:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF9E9E9E),
            const Color(0xFFBDBDBD),
            const Color(0xFFE0E0E0),
          ],
        );

      default:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF90CAF9),
            Color(0xFFE3F2FD),
          ],
        );
    }
  }

  Widget _buildSunAnimation() {
    return AnimatedBuilder(
      animation: _sunAnimationController,
      builder: (context, child) {
        return Positioned(
          top: 80 + (_sunAnimationController.value * 20),
          right: 40,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.orange.withOpacity(0.8),
                  Colors.orange.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoonAnimation() {
    return AnimatedBuilder(
      animation: _moonAnimationController,
      builder: (context, child) {
        return Positioned(
          top: 60 + (_moonAnimationController.value * 10),
          right: 60,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFf4f1de),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFf4f1de).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CustomPaint(
              painter: CrescentMoonPainter(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCloudAnimation() {
    return AnimatedBuilder(
      animation: _cloudAnimationController,
      builder: (context, child) {
        return Positioned.fill(
          child: Transform.translate(
            offset: Offset(_cloudAnimationController.value * 800 - 300, 0),
            child: CustomPaint(
              painter: CloudPainter(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWindAnimation() {
    return AnimatedBuilder(
      animation: _windAnimationController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: WindPainter(
              animationValue: _windAnimationController.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMistAnimation() {
    return AnimatedBuilder(
      animation: _cloudAnimationController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: MistPainter(
              animationValue: _cloudAnimationController.value,
            ),
          ),
        );
      },
    );
  }
}

class CrescentMoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.fill;

    // Draw crescent moon by drawing two circles
    canvas.drawCircle(
      Offset(size.width / 2 + 8, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(CrescentMoonPainter oldDelegate) => false;
}

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Draw multiple cloud shapes
    _drawCloud(canvas, paint, Offset(100, 150), 50);
    _drawCloud(canvas, paint, Offset(400, 200), 60);
    _drawCloud(canvas, paint, Offset(700, 120), 55);
    _drawCloud(canvas, paint, Offset(1000, 180), 45);
  }

  void _drawCloud(Canvas canvas, Paint paint, Offset center, double radius) {
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center.translate(radius * 0.8, 0), radius * 0.9, paint);
    canvas.drawCircle(center.translate(radius * 1.6, 0), radius * 0.8, paint);
    canvas.drawCircle(center.translate(-radius * 0.8, 0), radius * 0.85, paint);
  }

  @override
  bool shouldRepaint(CloudPainter oldDelegate) => false;
}

class WindPainter extends CustomPainter {
  final double animationValue;

  WindPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Multiple wind line sets with different speeds for organic effect
    _drawWindLines(canvas, size, 0.12, 50, 1.0); // Fast wind lines
    _drawWindLines(canvas, size, 0.08, 40, 0.7); // Medium wind lines
    _drawWindLines(canvas, size, 0.05, 35, 0.5); // Slow wind lines
  }

  void _drawWindLines(
    Canvas canvas,
    Size size,
    double opacity,
    double lineLength,
    double speedMultiplier,
  ) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw subtle wind lines at sparse intervals
    for (int i = 0; i < 6; i++) {
      final yOffset = (i * size.height / 6) + (50);
      final xOffset =
          ((animationValue * speedMultiplier * size.width * 1.5) - size.width);

      // Stagger the wind lines for more natural effect
      final staggaredX = xOffset + (i * 80);

      canvas.drawLine(
        Offset(staggaredX, yOffset),
        Offset(staggaredX + lineLength, yOffset),
        paint,
      );

      // Draw second set of wind lines offset by half width
      if (staggaredX + size.width < size.width * 1.5) {
        canvas.drawLine(
          Offset(staggaredX + size.width, yOffset),
          Offset(staggaredX + size.width + lineLength, yOffset),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(WindPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

class MistPainter extends CustomPainter {
  final double animationValue;

  MistPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw thick mist layers with varying opacity
    final mistColors = [
      Colors.white.withOpacity(0.15),
      Colors.white.withOpacity(0.12),
      Colors.white.withOpacity(0.18),
      Colors.white.withOpacity(0.1),
    ];

    // Draw multiple horizontal mist bands
    for (int i = 0; i < 40; i++) {
      final paint = Paint()
        ..color = mistColors[i % mistColors.length]
        ..style = PaintingStyle.fill;

      final yOffset = (i * size.height / 40) + (animationValue * 20 - 10);
      final waveOffset = (animationValue * 100) * (i % 2 == 0 ? 1 : -1);

      // Create wavy mist lines
      final path = _createMistPath(size.width, yOffset + waveOffset);
      canvas.drawPath(path, paint);
    }

    // Draw additional thick mist overlay
    final heavyMistPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final rect = Rect.fromLTWH(
        0,
        (i * size.height / 5),
        size.width,
        size.height / 5,
      );
      canvas.drawRect(rect, heavyMistPaint);
    }
  }

  Path _createMistPath(double width, double baseY) {
    final path = Path();
    path.moveTo(0, baseY);

    for (double x = 0; x <= width; x += 20) {
      final y = baseY + (10 * sin((x / width) * pi));
      path.lineTo(x, y);
    }

    path.lineTo(width, baseY + 15);
    path.lineTo(width, baseY);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(MistPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

class RainPainter extends CustomPainter {
  final double animationValue;

  RainPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final random = Random(1);

    for (int i = 0; i < 120; i++) {
      final x = random.nextDouble() * size.width;
      final y =
          (random.nextDouble() * size.height + animationValue * size.height) %
              size.height;

      canvas.drawLine(
        Offset(x, y),
        Offset(x + 2, y + 10),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) => true;
}

class LightningPainter extends CustomPainter {
  final double animationValue;

  LightningPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue < 0.95) return; // flash occasionally

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(size.width * 0.6, 0);
    path.lineTo(size.width * 0.55, size.height * 0.3);
    path.lineTo(size.width * 0.65, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LightningPainter oldDelegate) => true;
}

class SmokePainter extends CustomPainter {
  final double animationValue;

  SmokePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.28)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 7; i++) {
      final x =
          (animationValue * size.width * 1.4 + i * 220) % size.width - 200;
      final y = size.height * 0.25 + i * 65;

      final rect = Rect.fromLTWH(x, y, 280, 120);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(90)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SmokePainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
