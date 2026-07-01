import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _KineticLoadingPageState();
}

class _KineticLoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    Future.delayed(Duration(seconds: 3)).then((value ){
      if(context.mounted){
        context.go('/auth/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // Level 0: The Deep Foundation
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Ambient Background Glow
          _buildBackgroundGlow(colorScheme.primaryContainer),

          // 2. The Spinner Assembly
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Secondary Outer Ring (Subtle)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primaryContainer.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),

                  // Primary Kinetic Element
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      // Mimics the border-width pulsing in your CSS keyframes
                      double borderWidth =
                          2.0 + (math.sin(_controller.value * math.pi) * 2.0);

                      return Transform.rotate(
                        angle: _controller.value * 2 * math.pi,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // Ambient Glow logic from your CSS
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primaryContainer.withOpacity(
                                  0.08,
                                ),
                                blurRadius: 48,
                                spreadRadius: 6,
                              ),
                            ],
                            border: Border.all(
                              color: colorScheme.primaryContainer,
                              width: borderWidth,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Core Pulse Point
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 3. Subliminal Branding Text
          Positioned(
            bottom: 48,
            child: Opacity(
              opacity: 0.2,
              child: Text(
                'KINETIC INTELLIGENCE',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 4.0,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow(Color color) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            color.withOpacity(0.03),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
