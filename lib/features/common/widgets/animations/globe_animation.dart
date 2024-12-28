import 'package:flutter/material.dart';
import '../../../../core/config/app_assets.dart';
import '../../../../core/config/constants.dart';

class GlobeAnimation extends StatefulWidget {
  const GlobeAnimation({super.key});

  @override
  State<GlobeAnimation> createState() => _GlobeAnimationState();
}

class _GlobeAnimationState extends State<GlobeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotateAnimation;
  late final Animation<Offset> _planeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.globeAnimationDuration,
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _planeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(-1.5, 0.0),
          end: const Offset(1.5, 0.0),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Globe rotatif
        AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (context, child) => Transform.rotate(
            angle: _rotateAnimation.value,
            child: Image.asset(
              AppAssets.globePath,
              width: 200,
              height: 200,
            ),
          ),
        ),
        // Avion qui vole
        AnimatedBuilder(
          animation: _planeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: _planeAnimation.value,
              child: Transform.rotate(
                angle: 0.3,
                child: Image.asset(
                  AppAssets.planePath,
                  width: 30,
                  height: 30,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
