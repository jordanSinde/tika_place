import 'package:flutter/material.dart';
import '../../common/widgets/destinations_card.dart';
import '../models/destination.dart';

class AnimatedDestinationCard extends StatefulWidget {
  final Destination destination;
  final VoidCallback onTap;
  final bool isLarge;

  const AnimatedDestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  State<AnimatedDestinationCard> createState() =>
      _AnimatedDestinationCardState();
}

class _AnimatedDestinationCardState extends State<AnimatedDestinationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

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
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: DestinationCard(
              destination: widget.destination,
              onTap: widget.onTap,
              isLarge: widget.isLarge,
            ),
          ),
        );
      },
    );
  }
}
