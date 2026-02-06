import 'package:flutter/material.dart';
import 'dart:math';

class WeatherLoadingScreen extends StatefulWidget {
  final String? message;
  
  const WeatherLoadingScreen({super.key, this.message});

  @override
  State<WeatherLoadingScreen> createState() => _WeatherLoadingScreenState();
}

class _WeatherLoadingScreenState extends State<WeatherLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<Cloud> _clouds = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Create floating clouds
    for (int i = 0; i < 8; i++) {
      _clouds.add(Cloud(
        x: _random.nextDouble() * 300,
        y: _random.nextDouble() * 400,
        speed: 0.5 + _random.nextDouble() * 1.0,
        size: 40 + _random.nextDouble() * 60,
      ));
    }
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade900,
            Colors.blue.shade800,
            Colors.blue.shade600,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated clouds
          for (final cloud in _clouds)
            Positioned(
              left: cloud.x,
              top: cloud.y,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      sin(_controller.value * 2 * pi + cloud.x) * 20,
                      0,
                    ),
                    child: Opacity(
                      opacity: 0.7,
                      child: Container(
                        width: cloud.size,
                        height: cloud.size * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(cloud.size),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Sun
          Positioned(
            top: 100,
            right: 50,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.yellow.shade300,
                          Colors.orange.shade600,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Weather icon animation
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * 2 * pi,
                      child: Icon(
                        Icons.wb_sunny,
                        size: 100,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Bouncing dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            sin(_controller.value * 2 * pi + index * 0.5) * 10,
                          ),
                          child: Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 40),

                // Loading text with typing effect
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.blue.shade200,
                        Colors.white,
                      ],
                      stops: const [0.3, 0.5, 0.7],
                      tileMode: TileMode.mirror,
                    ).createShader(bounds);
                  },
                  child: Text(
                    widget.message ?? 'Loading weather...',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Progress bar
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: null,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                // Fun weather facts (optional)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.7 + sin(_controller.value * 2 * pi) * 0.3,
                      child: Text(
                        _getRandomWeatherFact(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRandomWeatherFact() {
    final facts = [
      'Did you know? Lightning can heat the air to 30,000°C!',
      'The highest temperature ever recorded was 56.7°C in Death Valley.',
      'Snowflakes are always six-sided due to water molecule structure.',
      'Clouds can weigh over a million pounds!',
      'Raindrops are actually shaped like hamburger buns, not teardrops.',
      'The windiest place on Earth is Commonwealth Bay, Antarctica.',
      'A single thunderstorm can release enough energy to power a city.',
    ];
    return facts[_random.nextInt(facts.length)];
  }
}

class Cloud {
  final double x;
  final double y;
  final double speed;
  final double size;

  Cloud({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
  });
}