// lib/features/bus_booking/services/ticket_download_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../providers/booking_provider.dart';
import '../providers/ticket_model.dart';

class TicketDownloadService {
  static final TicketDownloadService _instance =
      TicketDownloadService._internal();
  late pw.Font _regularFont;
  late pw.Font _boldFont;
  bool _initialized = false;
  static const String folderName = 'TIKA';

  factory TicketDownloadService() {
    return _instance;
  }

  TicketDownloadService._internal();

  // [Les autres méthodes restent identiques jusqu'à generateTicketPDF]
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Charger les polices pour le PDF
      final regularData =
          await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
      final boldData = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");

      _regularFont = pw.Font.ttf(regularData);
      _boldFont = pw.Font.ttf(boldData);

      // Créer le dossier TIKA s'il n'existe pas
      await _createTikaDirectory();

      _initialized = true;
    } catch (e) {
      print(
          'Erreur lors de l\'initialisation du service de téléchargement: $e');
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      final storage = await Permission.storage.status;
      final mediaLibrary = await Permission.mediaLibrary.status;

      if (storage != PermissionStatus.granted ||
          mediaLibrary != PermissionStatus.granted) {
        await Permission.storage.request();
        await Permission.mediaLibrary.request();

        final storageAfter = await Permission.storage.status;
        final mediaLibraryAfter = await Permission.mediaLibrary.status;

        return storageAfter == PermissionStatus.granted &&
            mediaLibraryAfter == PermissionStatus.granted;
      }
      return true;
    }
    return true;
  }

  Future<String> _getTikaPath() async {
    if (Platform.isAndroid) {
      // Utiliser le dossier Download public
      return '/storage/emulated/0/Download/$folderName';
    } else {
      // Pour iOS, utiliser un dossier visible dans Files app
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/$folderName';
    }
  }

  Future<void> _createTikaDirectory() async {
    final tikaPath = await _getTikaPath();
    final directory = Directory(tikaPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  Future<bool> isTicketDownloaded(String ticketId) async {
    final tikaPath = await _getTikaPath();
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final file = File('$tikaPath/Billet_$ticketId\_$dateStr.pdf');
    return file.exists();
  }

  Future<String?> getExistingTicketPath(String ticketId) async {
    final tikaPath = await _getTikaPath();
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final file = File('$tikaPath/Billet_$ticketId\_$dateStr.pdf');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  Future<String> generateTicketPDF(ExtendedTicket ticket) async {
    await initialize();

    final hasPermission = await _checkAndRequestPermissions();
    if (!hasPermission) {
      throw Exception('Permission de stockage refusée');
    }

    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Load the logo image
    final logoImageBytes = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(
      (logoImageBytes.buffer.asUint8List()),
    );
    //logo

    try {
      // Vérifier si le PDF existe déjà
      final existingPath = await getExistingTicketPath(ticket.id);
      if (existingPath != null) {
        return existingPath;
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.max,
              children: [
                // Contenu principal (tout sauf le pied de page)
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Header with logo and company name
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side - Logo and company name
                          pw.Row(
                            children: [
                              pw.Container(
                                height: 40,
                                width: 40,
                                child: pw.Image(logoImage),
                              ),
                              pw.SizedBox(width: 8),
                              pw.Text(
                                'TIKA PLACE',
                                style: pw.TextStyle(
                                  font: _boldFont,
                                  fontSize: 18,
                                  color: PdfColors.blue,
                                ),
                              ),
                            ],
                          ),
                          // Right side - Reference number
                          pw.Text(
                            'Ref: ${ticket.bookingReference}',
                            style: pw.TextStyle(
                              font: _regularFont,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      // Title
                      pw.Text(
                        'BILLET DE VOYAGE',
                        style: pw.TextStyle(
                          font: _boldFont,
                          fontSize: 22,
                        ),
                      ),
                      pw.Divider(thickness: 2),
                      pw.SizedBox(height: 20),

                      // Informations du trajet
                      _buildSection(
                        'INFORMATIONS DU TRAJET',
                        [
                          _buildInfoRow('Départ',
                              '${ticket.bus.departureCity} - ${dateFormat.format(ticket.bus.departureTime)}'),
                          _buildInfoRow('Arrivée',
                              '${ticket.bus.arrivalCity} - ${dateFormat.format(ticket.bus.arrivalTime)}'),
                          _buildInfoRow('Compagnie', ticket.bus.company),
                          _buildInfoRow(
                              'Bus N°', ticket.bus.registrationNumber),
                        ],
                      ),
                      pw.SizedBox(height: 20),

                      // Informations du passager
                      _buildSection(
                        'INFORMATIONS PASSAGER',
                        [
                          _buildInfoRow('Nom', ticket.passengerName),
                          _buildInfoRow('Téléphone', ticket.phoneNumber),
                          if (ticket.cniNumber != null)
                            _buildInfoRow('CNI', ticket.cniNumber!),
                          _buildInfoRow('Siège', ticket.formattedSeatNumber),
                        ],
                      ),
                      pw.SizedBox(height: 20),

                      // Informations de paiement
                      _buildSection(
                        'DÉTAILS DU PAIEMENT',
                        [
                          _buildInfoRow('Montant', '${ticket.totalPrice} FCFA'),
                          _buildInfoRow('Mode',
                              _formatPaymentMethod(ticket.paymentMethod)),
                          _buildInfoRow(
                              'Date', dateFormat.format(ticket.purchaseDate)),
                        ],
                      ),

                      pw.SizedBox(height: 10),

                      // Code QR
                      pw.Container(
                        height: 100,
                        child: pw.Center(
                          child: _buildQRCode(ticket),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pied de page (toujours en bas)
                pw.Container(
                  //margin: const pw.EdgeInsets.only(top: 10),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Notes importantes:',
                        style: pw.TextStyle(font: _boldFont, fontSize: 10),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '• Ce billet est valable uniquement pour la date et l\'heure indiquées; '
                        '• Présentez-vous au moins 30 minutes avant le départ; '
                        '• Une pièce d\'identité peut être demandée',
                        style: pw.TextStyle(font: _regularFont, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Sauvegarder dans le dossier TIKA
      final tikaPath = await _getTikaPath();
      final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
      final fileName = 'Billet_${ticket.id}_$dateStr.pdf';
      final file = File('$tikaPath/$fileName');

      await file.writeAsBytes(await pdf.save());

      // Notifier le système sur Android
      if (Platform.isAndroid) {
        try {
          const channel = MethodChannel('com.tikaplace/file_utils');
          await channel.invokeMethod('scanFile', {'path': file.path});
        } catch (e) {
          print('Erreur lors de la notification du système: $e');
        }
      }

      return file.path;
    } catch (e) {
      throw Exception('Erreur lors de la génération du PDF: $e');
    }
  }

  // Méthodes helpers pour la génération du PDF
  pw.Widget _buildSection(String title, List<pw.Widget> content) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 14,
            ),
          ),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 5),
          ...content,
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: _boldFont,
                fontSize: 10,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: _regularFont,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildQRCode(ExtendedTicket ticket) {
    return pw.BarcodeWidget(
      barcode: pw.Barcode.qrCode(),
      data: ticket.qrCode,
      width: 100,
      height: 100,
    );
  }

  String _formatPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.mtnMoney:
        return 'MTN Mobile Money';
    }
  }

  Future<List<String>> generateMultipleTicketsPDF(
      List<ExtendedTicket> tickets) async {
    final paths = <String>[];

    for (final ticket in tickets) {
      try {
        final path = await generateTicketPDF(ticket);
        paths.add(path);
      } catch (e) {
        print(
            'Erreur lors de la génération du PDF pour le ticket ${ticket.id}: $e');
      }
    }

    return paths;
  }

  // Nettoyer les anciens PDFs
  Future<void> cleanOldTickets() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final ticketsDir = Directory('${directory.path}/tickets');

      if (await ticketsDir.exists()) {
        final files = await ticketsDir.list().toList();
        final now = DateTime.now();

        for (var entity in files) {
          if (entity is File) {
            final stat = await entity.stat();
            // Supprimer les fichiers de plus de 30 jours
            if (now.difference(stat.changed).inDays > 30) {
              await entity.delete();
            }
          }
        }
      }
    } catch (e) {
      print('Erreur lors du nettoyage des anciens tickets: $e');
    }
  }
}

final ticketDownloadService = TicketDownloadService();
