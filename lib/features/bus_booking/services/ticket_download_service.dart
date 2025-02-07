// lib/features/bus_booking/services/ticket_download_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
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

  factory TicketDownloadService() {
    return _instance;
  }

  TicketDownloadService._internal();

  // Méthode publique d'initialisation
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Charger les polices pour le PDF
      final regularData =
          await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
      final boldData = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");

      _regularFont = pw.Font.ttf(regularData);
      _boldFont = pw.Font.ttf(boldData);

      _initialized = true;
    } catch (e) {
      print(
          'Erreur lors de l\'initialisation du service de téléchargement: $e');
      // Vous pouvez gérer l'erreur comme vous le souhaitez
    }
  }

  // Vérifie si un ticket a déjà été téléchargé
  Future<bool> isTicketDownloaded(String ticketId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tickets/ticket_$ticketId.pdf');
    return file.exists();
  }

  // Retourne le chemin du fichier PDF s'il existe
  Future<String?> getExistingTicketPath(String ticketId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tickets/ticket_$ticketId.pdf');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  Future<String> generateTicketPDF(ExtendedTicket ticket) async {
    await initialize();
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

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
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // En-tête avec logo (si disponible)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'BILLET DE VOYAGE',
                      style: pw.TextStyle(
                        font: _boldFont,
                        fontSize: 24,
                      ),
                    ),
                    pw.Text(
                      'Ref: ${ticket.bookingReference}',
                      style: pw.TextStyle(
                        font: _regularFont,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
                    _buildInfoRow('Bus N°', ticket.bus.registrationNumber),
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
                    _buildInfoRow('Siège', ticket.seatNumber),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Informations de paiement
                _buildSection(
                  'DÉTAILS DU PAIEMENT',
                  [
                    _buildInfoRow('Montant', '${ticket.totalPrice} FCFA'),
                    _buildInfoRow(
                        'Mode', _formatPaymentMethod(ticket.paymentMethod)),
                    _buildInfoRow(
                        'Date', dateFormat.format(ticket.purchaseDate)),
                  ],
                ),

                pw.Spacer(),

                // Code QR
                pw.Center(
                  child: _buildQRCode(ticket),
                ),

                pw.SizedBox(height: 20),

                // Pied de page
                pw.Container(
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
                        '• Ce billet est valable uniquement pour la date et l\'heure indiquées\n'
                        '• Présentez-vous au moins 30 minutes avant le départ\n'
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

      // Créer le dossier tickets s'il n'existe pas
      final directory = await getApplicationDocumentsDirectory();
      final ticketsDir = Directory('${directory.path}/tickets');
      if (!await ticketsDir.exists()) {
        await ticketsDir.create(recursive: true);
      }

      // Sauvegarder le fichier
      final file = File('${ticketsDir.path}/ticket_${ticket.id}.pdf');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      throw Exception('Erreur lors de la génération du PDF: $e');
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
    // Créer un code barre simple avec les informations essentielles
    return pw.BarcodeWidget(
      barcode: pw.Barcode.qrCode(),
      data:
          'ID:${ticket.id}|REF:${ticket.bookingReference}|SEAT:${ticket.seatNumber}',
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
      default:
        return method.toString();
    }
  }
}

final ticketDownloadService = TicketDownloadService();

/*
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../providers/ticket_model.dart';

class TicketDownloadService {
  static final TicketDownloadService _instance =
      TicketDownloadService._internal();

  factory TicketDownloadService() {
    return _instance;
  }

  TicketDownloadService._internal();

  Future<String> generateTicketPDF(ExtendedTicket ticket) async {
    final pdf = pw.Document();

    try {
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/ticket_${ticket.id}.pdf');

      // Générer le PDF
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            children: [
              // ... Contenu du PDF ...
            ],
          ),
        ),
      );

      // Sauvegarder le fichier
      await file.writeAsBytes(await pdf.save());

      // Ouvrir le fichier avec le visualiseur par défaut
      if (Platform.isAndroid || Platform.isIOS) {
        await OpenFile.open(file.path);
      }

      return file.path;
    } catch (e) {
      throw Exception('Erreur lors de la génération du PDF: $e');
    }
  }
}

final ticketDownloadService = TicketDownloadService();
*/