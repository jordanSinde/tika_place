import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AnimatedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AnimatedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => ShimmerLoading(
          width: width,
          height: height,
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
        fadeInDuration: const Duration(milliseconds: 500),
        fadeOutDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final double? width;
  final double? height;

  const ShimmerLoading({
    super.key,
    this.width,
    this.height,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1.0,
            alignment: AlignmentGeometryTween(
              begin: const Alignment(-1.0, 0.0),
              end: const Alignment(1.0, 0.0),
            ).evaluate(_shimmerController)!,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[300]!.withOpacity(0.0),
                    Colors.grey[300]!.withOpacity(0.5),
                    Colors.grey[300]!.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
