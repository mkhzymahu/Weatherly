import 'package:flutter/material.dart';

class WeatherLoader extends StatefulWidget {
  final String? message;
  final Color? backgroundColor;

  const WeatherLoader({
    super.key,
    this.message,
    this.backgroundColor,
  });

  @override
  State<WeatherLoader> createState() => _WeatherLoaderState();
}

class _WeatherLoaderState extends State<WeatherLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.3, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.3), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
      color: widget.backgroundColor ?? Colors.blue.shade900.withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated sun/cloud
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sun
                    Transform.rotate(
                      angle: _rotationAnimation.value * 3.14159,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.yellow.withOpacity(_opacityAnimation.value),
                              Colors.orange.withOpacity(_opacityAnimation.value * 0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(_opacityAnimation.value * 0.5),
                              blurRadius: 20,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Cloud
                    Opacity(
                      opacity: 0.8,
                      child: Container(
                        width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(_opacityAnimation.value),
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(_opacityAnimation.value * 0.5),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // Typing text effect
            _TypingText(
              text: widget.message ?? 'Fetching weather data...',
              textStyle: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 30),

            // Weather icons carousel
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(5, (index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final offset = (index * 0.2 + _controller.value) % 1.0;
                      return Opacity(
                        opacity: offset < 0.5 ? offset * 2 : (1 - offset) * 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            _getWeatherIcon(index),
                            size: 30,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(int index) {
    final icons = [
      Icons.wb_sunny,
      Icons.cloud,
      Icons.grain,
      Icons.ac_unit,
      Icons.flash_on,
    ];
    return icons[index % icons.length];
  }
}

class _TypingText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;

  const _TypingText({
    required this.text,
    required this.textStyle,
  });

  @override
  State<_TypingText> createState() => __TypingTextState();
}

class __TypingTextState extends State<_TypingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textLengthAnimation;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * 100),
      vsync: this,
    )..forward();
    
    _textLengthAnimation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(_controller);
    
    _controller.addListener(() {
      setState(() {
        _displayText = widget.text.substring(0, _textLengthAnimation.value);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _displayText,
          style: widget.textStyle,
        ),
        AnimatedOpacity(
          opacity: _controller.isAnimating ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Container(
            width: 2,
            height: widget.textStyle.fontSize! * 1.5,
            margin: const EdgeInsets.only(left: 2),
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}