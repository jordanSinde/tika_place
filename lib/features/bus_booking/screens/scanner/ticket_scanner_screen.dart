//lib/features/bus_booking/screens/scanner/ticket_scanner_screen.dart
/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/config/theme/app_colors.dart';
import 'dart:convert';

import '../../../auth/providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';

class TicketScannerScreen extends ConsumerStatefulWidget {
  const TicketScannerScreen({super.key});

  @override
  ConsumerState<TicketScannerScreen> createState() =>
      _TicketScannerScreenState();
}

class _TicketScannerScreenState extends ConsumerState<TicketScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  bool _torchEnabled = false;
  bool _frontCamera = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un billet'),
        actions: [
          IconButton(
            icon: Icon(_torchEnabled ? Icons.flash_on : Icons.flash_off),
            onPressed: _isProcessing
                ? null
                : () {
                    setState(() {
                      _torchEnabled = !_torchEnabled;
                    });
                    _controller.toggleTorch();
                  },
          ),
          IconButton(
            icon: Icon(_frontCamera ? Icons.camera_front : Icons.camera_rear),
            onPressed: _isProcessing
                ? null
                : () {
                    setState(() {
                      _frontCamera = !_frontCamera;
                    });
                    _controller.switchCamera();
                  },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleScan,
          ),
          _buildOverlay(),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: const ShapeDecoration(
        shape: _ScannerOverlayShape(
          borderColor: AppColors.primary,
          borderWidth: 3.0,
          overlayColor: Colors.black54,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Placez le QR code dans le cadre',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScan(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final ticketData = _parseTicketData(barcodes.first.rawValue ?? '');
      if (ticketData == null) {
        _showError('QR code invalide');
        return;
      }

      await _controller.stop();
      if (!mounted) return;

      // Vérifier le ticket
      await _verifyTicket(ticketData);
    } catch (e) {
      _showError('Erreur lors de la vérification du billet');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Map<String, dynamic>? _parseTicketData(String rawValue) {
    try {
      return json.decode(rawValue) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> _verifyTicket(Map<String, dynamic> ticketData) async {
    try {
      final ticketId = ticketData['ticketId'].toString();
      final validatorId = ref.read(authProvider).user?.id ?? '';

      final result = await ref
          .read(ticketsProvider.notifier)
          .validateTicket(ticketId, validatorId);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketValidationResult(
            isValid: result,
            ticketData: ticketData,
          ),
        ),
      );

      // Redémarrer le scanner après la validation
      _controller.start();
    } catch (e) {
      _showError('Erreur lors de la validation du billet');
      _controller.start();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;

  const _ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = Colors.black54,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final scanAreaSize = width * 0.7;
    final left = (width - scanAreaSize) / 2;
    final top = (height - scanAreaSize) / 2;
    final scanArea = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    final backgroundPath = Path()..addRect(rect);
    final scanPath = Path()..addRect(scanArea);

    final resultPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      scanPath,
    );

    // Dessiner l'overlay
    canvas.drawPath(
      resultPath,
      Paint()..color = overlayColor,
    );

    // Dessiner le cadre de scan
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Coins du cadre
    final cornerSize = scanAreaSize * 0.15;
    _drawCorners(canvas, scanArea, cornerSize, borderPaint);
  }

  void _drawCorners(Canvas canvas, Rect rect, double cornerSize, Paint paint) {
    // Coin supérieur gauche
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + cornerSize)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.left + cornerSize, rect.top),
      paint,
    );

    // Coin supérieur droit
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerSize, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.top + cornerSize),
      paint,
    );

    // Coin inférieur gauche
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - cornerSize)
        ..lineTo(rect.left, rect.bottom)
        ..lineTo(rect.left + cornerSize, rect.bottom),
      paint,
    );

    // Coin inférieur droit
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerSize, rect.bottom)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.right, rect.bottom - cornerSize),
      paint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return _ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
    );
  }
}
*/