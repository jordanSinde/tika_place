import 'dart:math';

import 'package:flutter/material.dart';

class ErrorBoundaryWidget extends StatelessWidget {
  final Widget child;

  const ErrorBoundaryWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e, stackTrace) {
          print('Error rendering widget: $e\n$stackTrace');
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(height: 8),
                Text('Error rendering content: ${e.toString().substring(
                      0,
                      min(
                        e.toString().length,
                        100,
                      ),
                    )}...'),
              ],
            ),
          );
        }
      },
    );
  }
}
