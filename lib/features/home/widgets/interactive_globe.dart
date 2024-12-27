import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';

class InteractiveGlobe extends StatelessWidget {
  final List<MapLocation> locations;

  const InteractiveGlobe({
    super.key,
    required this.locations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Stack(
        children: [
          // Globe background
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/images/map.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Location markers
          ...locations.map((location) => _buildLocationMarker(location)),
          // Connection lines
          ...locations.map((location) => _buildConnectionLine(location)),
        ],
      ),
    );
  }

  Widget _buildLocationMarker(MapLocation location) {
    return Positioned(
      left: location.position.dx,
      top: location.position.dy,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: location.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          location.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionLine(MapLocation location) {
    return CustomPaint(
      painter: LinePainter(
        start: location.position,
        color: location.color.withOpacity(0.3),
      ),
    );
  }
}

class MapLocation {
  final String name;
  final Offset position;
  final Color color;

  const MapLocation({
    required this.name,
    required this.position,
    required this.color,
  });
}

class LinePainter extends CustomPainter {
  final Offset start;
  final Color color;

  LinePainter({
    required this.start,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        size.width / 2,
        size.height / 2,
        size.width / 2,
        size.height / 2,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => false;
}
