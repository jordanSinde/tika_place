// lib/features/bus_booking/services/ticket_download_service.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:tika_place/features/home/models/bus_mock_data.dart';

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

    // Charger les polices
    final regular = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
    final bold = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
    final regularFont = pw.Font.ttf(regular);
    final boldFont = pw.Font.ttf(bold);

    // Générer le PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(ticket, boldFont),
              pw.SizedBox(height: 20),

              // Informations du voyage
              _buildTripInfo(ticket, regularFont, boldFont),
              pw.SizedBox(height: 20),

              // Informations du passager
              _buildPassengerInfo(ticket, regularFont, boldFont),
              pw.SizedBox(height: 20),

              // QR Code
              _buildQRCode(ticket),

              // Conditions
              _buildTerms(regularFont),
            ],
          ),
        ),
      ),
    );

    // Sauvegarder le fichier
    final output = await getTemporaryDirectory();
    final filePath = '${output.path}/ticket_${ticket.id}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  pw.Widget _buildHeader(ExtendedTicket ticket, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BILLET DE BUS',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 20,
                ),
              ),
              pw.Text(
                'Référence: ${ticket.bookingReference}',
                style: const pw.TextStyle(
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Text(
            ticket.formattedSeatNumber,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTripInfo(
    ExtendedTicket ticket,
    pw.Font regularFont,
    pw.Font boldFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Informations du voyage',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 16,
          ),
        ),
        pw.SizedBox(height: 10),
        _buildInfoRow('Compagnie', ticket.bus.company, regularFont),
        _buildInfoRow(
          'Départ',
          '${ticket.bus.departureCity} - ${DateFormat('dd/MM/yyyy HH:mm').format(ticket.bus.departureTime)}',
          regularFont,
        ),
        _buildInfoRow(
          'Arrivée',
          '${ticket.bus.arrivalCity} - ${DateFormat('dd/MM/yyyy HH:mm').format(ticket.bus.arrivalTime)}',
          regularFont,
        ),
        _buildInfoRow('Bus N°', ticket.bus.registrationNumber, regularFont),
        _buildInfoRow('Classe', ticket.bus.busClass.label, regularFont),
      ],
    );
  }

  pw.Widget _buildPassengerInfo(
    ExtendedTicket ticket,
    pw.Font regularFont,
    pw.Font boldFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Informations du passager',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 16,
          ),
        ),
        pw.SizedBox(height: 10),
        _buildInfoRow('Nom', ticket.passengerName, regularFont),
        _buildInfoRow('Téléphone', ticket.phoneNumber, regularFont),
        if (ticket.cniNumber != null)
          _buildInfoRow('CNI', ticket.cniNumber!, regularFont),
      ],
    );
  }

  pw.Widget _buildQRCode(ExtendedTicket ticket) {
    final qrData = ticket.qrCodeData;
    return pw.Center(
      child: pw.BarcodeWidget(
        color: PdfColors.black,
        barcode: pw.Barcode.qrCode(),
        data: qrData.toString(),
        width: 150,
        height: 150,
      ),
    );
  }

  pw.Widget _buildTerms(pw.Font regularFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Conditions importantes:',
            style: const pw.TextStyle(
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '• Présentez-vous 30 minutes avant le départ',
            style: pw.TextStyle(font: regularFont, fontSize: 10),
          ),
          pw.Text(
            '• Une pièce d\'identité valide est requise',
            style: pw.TextStyle(font: regularFont, fontSize: 10),
          ),
          pw.Text(
            '• Un bagage en soute gratuit (max 20kg)',
            style: pw.TextStyle(font: regularFont, fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: font,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font),
            ),
          ),
        ],
      ),
    );
  }
}

final ticketDownloadService = TicketDownloadService();
