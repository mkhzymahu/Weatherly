import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import '../../features/weather/domain/entities/weather_condition.dart';

class LottieWeatherLoading extends StatefulWidget {
  final String? message;
  final WeatherCondition condition;
  final Color? backgroundColor;

  const LottieWeatherLoading({
    super.key,
    this.message,
    this.condition = WeatherCondition.misty,
    this.backgroundColor,
  });

  @override
  State<LottieWeatherLoading> createState() => _LottieWeatherLoadingState();
}

class _LottieWeatherLoadingState extends State<LottieWeatherLoading>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  final List<FloatingElement> _floatingElements = [];
  final Random _random = Random();
  bool _showTips = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    
    // Initialize floating elements based on condition
    _initializeFloatingElements();
    
    // Start tip rotation
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showTips = !_showTips;
        });
      }
    });
  }

  void _initializeFloatingElements() {
    _floatingElements.clear();
    
    int elementCount = 0;
    switch (widget.condition) {
      case WeatherCondition.clear:
        elementCount = 8;
        break;
      case WeatherCondition.cloudy:
        elementCount = 12;
        break;
      case WeatherCondition.rainy:
        elementCount = 15;
        break;
      case WeatherCondition.snowy:
        elementCount = 20;
        break;
      case WeatherCondition.thunderstorm:
        elementCount = 10;
        break;
      case WeatherCondition.misty:
        elementCount = 6;
        break;
      case WeatherCondition.smoke:
      default:
        elementCount = 6;
    }
    
    for (int i = 0; i < elementCount; i++) {
      _floatingElements.add(FloatingElement(
        type: _getElementTypeForCondition(widget.condition, i),
        x: _random.nextDouble() * 300,
        y: _random.nextDouble() * 500,
        speed: 0.5 + _random.nextDouble() * 1.5,
        size: 10 + _random.nextDouble() * 30,
        opacity: 0.3 + _random.nextDouble() * 0.7,
      ));
    }
  }

  FloatingElementType _getElementTypeForCondition(
      WeatherCondition condition, int index) {
    switch (condition) {
      case WeatherCondition.clear:
        return FloatingElementType.sun;
      case WeatherCondition.cloudy:
        return FloatingElementType.cloud;
      case WeatherCondition.rainy:
        return FloatingElementType.raindrop;
      case WeatherCondition.snowy:
        return FloatingElementType.snowflake;
      case WeatherCondition.thunderstorm:
        return FloatingElementType.lightning;
      case WeatherCondition.misty:
      case WeatherCondition.smoke:
      default:
        final types = FloatingElementType.values;
        return types[index % types.length];
    }
  }

  String _getLottieAsset() {
    switch (widget.condition) {
      case WeatherCondition.clear:
        return 'assets/lottie/sunny_loading.json';
      case WeatherCondition.cloudy:
        return 'assets/lottie/cloudy_loading.json';
      case WeatherCondition.rainy:
        return 'assets/lottie/rainy_loading.json';
      case WeatherCondition.snowy:
        return 'assets/lottie/snowy_loading.json';
      case WeatherCondition.thunderstorm:
        return 'assets/lottie/thunderstorm_loading.json';
      case WeatherCondition.misty:
        return 'assets/lottie/misty_loading.json';
      case WeatherCondition.smoke:
      default:
        return 'assets/lottie/weather_loading.json';
    }
  }

  String _getConditionMessage() {
    switch (widget.condition) {
      case WeatherCondition.clear:
        return 'Enjoy the sunshine! ☀️';
      case WeatherCondition.cloudy:
        return 'Perfect day for a walk! ☁️';
      case WeatherCondition.rainy:
        return 'Don\'t forget your umbrella! ☔';
      case WeatherCondition.snowy:
        return 'Bundle up, it\'s cold! ❄️';
      case WeatherCondition.thunderstorm:
        return 'Stay safe indoors! ⚡';
      case WeatherCondition.misty:
        return 'Walking in the mist! 🌫️';
      case WeatherCondition.smoke:
      default:
        return 'Loading your weather experience...';
    }
  }

  List<String> _getWeatherTips() {
    return [
      '💡 Tip: Pull down to refresh weather data',
      '🌡️ Temperature is measured 1.5m above ground',
      '🌬️ Wind speed affects how cold it feels',
      '💧 Humidity above 60% feels muggy',
      '☀️ UV index peaks between 10am and 4pm',
      '🌙 Clear nights are usually colder',
      '🌪️ Low pressure often brings storms',
    ];
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getBackgroundGradient(),
        ),
      ),
      child: Stack(
        children: [
          // Floating elements background
          ..._floatingElements.map((element) {
            return Positioned(
              left: element.x,
              top: element.y,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      sin(_pulseController.value * 2 * pi + element.x) * 10,
                    ),
                    child: Opacity(
                      opacity: element.opacity * 0.7,
                      child: _buildFloatingElement(element),
                    ),
                  );
                },
              ),
            );
          }).toList(),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lottie Animation
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: Lottie.asset(
                            _getLottieAsset(),
                            animate: true,
                            repeat: true,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackAnimation();
                            },
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Loading message with gradient
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                Colors.white,
                                theme.primaryColor.withOpacity(0.8),
                                Colors.white,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              tileMode: TileMode.mirror,
                            ).createShader(bounds);
                          },
                          child: Text(
                            widget.message ?? _getConditionMessage(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Animated dots
                        _buildAnimatedDots(),
                        const SizedBox(height: 30),

                        // Progress indicator
                        SizedBox(
                          width: 250,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: null,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.8),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Weather tips carousel
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _showTips
                              ? _buildWeatherTip()
                              : _buildWeatherFact(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Skip button (optional)
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                // Optional: Add skip functionality
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withOpacity(0.7),
              ),
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingElement(FloatingElement element) {
    switch (element.type) {
      case FloatingElementType.sun:
        return Icon(
          Icons.wb_sunny,
          size: element.size,
          color: Colors.yellow.withOpacity(element.opacity),
        );
      case FloatingElementType.cloud:
        return Icon(
          Icons.cloud,
          size: element.size,
          color: Colors.white.withOpacity(element.opacity),
        );
      case FloatingElementType.raindrop:
        return Icon(
          Icons.water_drop,
          size: element.size,
          color: Colors.blue.withOpacity(element.opacity),
        );
      case FloatingElementType.snowflake:
        return Icon(
          Icons.ac_unit,
          size: element.size,
          color: Colors.white.withOpacity(element.opacity),
        );
      case FloatingElementType.lightning:
        return Icon(
          Icons.flash_on,
          size: element.size,
          color: Colors.yellow.withOpacity(element.opacity),
        );
    }
  }

  Widget _buildFallbackAnimation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _pulseController.value * 2 * pi,
              child: Icon(
                Icons.wb_sunny,
                size: 100,
                color: Colors.yellow.withOpacity(0.8),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Loading...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_pulseController.value + delay) % 1.0;
            final scale = 0.5 + sin(value * 2 * pi).abs() * 0.5;
            final opacity = 0.3 + scale * 0.7;

            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(opacity * 0.5),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildWeatherTip() {
    final tips = _getWeatherTips();
    final tip = tips[_random.nextInt(tips.length)];

    return SizedBox(
      width: 300,
      child: Text(
        tip,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.8),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildWeatherFact() {
    final facts = [
      '🌡️ Lightning is 5 times hotter than the sun!',
      '❄️ Snowflakes always have 6 sides',
      '☁️ Clouds can weigh over 1 million pounds',
      '🌪️ Tornado winds can exceed 300 mph',
      '🌈 Rainbows are actually full circles',
      '🌊 The ocean influences 70% of weather',
      '🌬️ Wind doesn\'t make a sound until it hits something',
    ];
    final fact = facts[_random.nextInt(facts.length)];

    return SizedBox(
      width: 300,
      child: Text(
        fact,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.8),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  List<Color> _getBackgroundGradient() {
    switch (widget.condition) {
      case WeatherCondition.clear:
        return [
          const Color(0xFF87CEEB).withOpacity(0.9),
          const Color(0xFF1E90FF).withOpacity(0.9),
          const Color(0xFF0000FF).withOpacity(0.9),
        ];
      case WeatherCondition.cloudy:
        return [
          const Color(0xFFB0C4DE).withOpacity(0.9),
          const Color(0xFF778899).withOpacity(0.9),
          const Color(0xFF708090).withOpacity(0.9),
        ];
      case WeatherCondition.rainy:
        return [
          const Color(0xFF4682B4).withOpacity(0.9),
          const Color(0xFF5F9EA0).withOpacity(0.9),
          const Color(0xFF2F4F4F).withOpacity(0.9),
        ];
      case WeatherCondition.snowy:
        return [
          const Color(0xFFF0F8FF).withOpacity(0.9),
          const Color(0xFFE6E6FA).withOpacity(0.9),
          const Color(0xFFD8BFD8).withOpacity(0.9),
        ];
      case WeatherCondition.thunderstorm:
        return [
          const Color(0xFF2F4F4F).withOpacity(0.9),
          const Color(0xFF363636).withOpacity(0.9),
          Colors.black.withOpacity(0.9),
        ];
      case WeatherCondition.misty:
      case WeatherCondition.smoke:
      default:
        return [
          Colors.blue.shade900.withOpacity(0.9),
          Colors.blue.shade800.withOpacity(0.9),
          Colors.blue.shade600.withOpacity(0.9),
        ];
    }
  }
}

enum FloatingElementType {
  sun,
  cloud,
  raindrop,
  snowflake,
  lightning,
}

class FloatingElement {
  final FloatingElementType type;
  final double x;
  final double y;
  final double speed;
  final double size;
  final double opacity;

  FloatingElement({
    required this.type,
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}
