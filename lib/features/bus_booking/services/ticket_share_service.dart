//lib/features/bus_booking/services/ticket_share_service.dart

import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../providers/ticket_model.dart';
import 'ticket_download_service.dart';

class TicketShareService {
  static final TicketShareService _instance = TicketShareService._internal();

  factory TicketShareService() {
    return _instance;
  }

  TicketShareService._internal();

  Future<void> shareTicket(ExtendedTicket ticket) async {
    try {
      // Générer le PDF du ticket
      final pdfPath = await ticketDownloadService.generateTicketPDF(ticket);

      // Créer le message de partage
      final message = _createShareMessage(ticket);

      // Partager le PDF avec le message
      await Share.shareXFiles(
        [XFile(pdfPath)],
        text: message,
        subject: 'Billet de bus - ${ticket.bus.company}',
      );

      // Nettoyer le fichier temporaire
      await _cleanupTempFile(pdfPath);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> shareMultipleTickets(List<ExtendedTicket> tickets) async {
    try {
      final pdfFiles = <XFile>[];

      // Générer les PDFs pour tous les tickets
      for (final ticket in tickets) {
        final pdfPath = await ticketDownloadService.generateTicketPDF(ticket);
        pdfFiles.add(XFile(pdfPath));
      }

      // Créer le message de partage pour plusieurs tickets
      final message = _createMultiShareMessage(tickets);

      // Partager tous les PDFs avec le message
      await Share.shareXFiles(
        pdfFiles,
        text: message,
        subject: 'Billets de bus - ${tickets.first.bus.company}',
      );

      // Nettoyer les fichiers temporaires
      for (final file in pdfFiles) {
        await _cleanupTempFile(file.path);
      }
    } catch (e) {
      rethrow;
    }
  }

  String _createShareMessage(ExtendedTicket ticket) {
    return '''
Voici votre billet de bus pour le trajet ${ticket.bus.departureCity} → ${ticket.bus.arrivalCity}

🚌 Compagnie: ${ticket.bus.company}
📅 Date: ${ticket.bus.departureTime.toString().split('.')[0]}
🎫 Référence: ${ticket.bookingReference}
💺 Siège: ${ticket.formattedSeatNumber}

ℹ️ N'oubliez pas de vous présenter 30 minutes avant le départ avec une pièce d'identité valide.
''';
  }

  String _createMultiShareMessage(List<ExtendedTicket> tickets) {
    final firstTicket = tickets.first;
    return '''
Voici vos ${tickets.length} billets de bus pour le trajet ${firstTicket.bus.departureCity} → ${firstTicket.bus.arrivalCity}

🚌 Compagnie: ${firstTicket.bus.company}
📅 Date: ${firstTicket.bus.departureTime.toString().split('.')[0]}
🎫 Référence réservation: ${firstTicket.bookingReference}

Passagers:
${tickets.map((t) => '- ${t.passengerName} (${t.formattedSeatNumber})').join('\n')}

ℹ️ N'oubliez pas de vous présenter 30 minutes avant le départ avec une pièce d'identité valide.
''';
  }

  Future<void> _cleanupTempFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Erreur lors du nettoyage du fichier temporaire: $e');
    }
  }
}

final ticketShareService = TicketShareService();
