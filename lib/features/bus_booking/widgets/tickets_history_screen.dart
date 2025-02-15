// lib/features/bus_booking/screens/tickets/tickets_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/ticket_model.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_viewer.dart';

class TicketsHistoryScreen extends ConsumerStatefulWidget {
  const TicketsHistoryScreen({super.key});

  @override
  ConsumerState<TicketsHistoryScreen> createState() =>
      _TicketsHistoryScreenState();
}

class _TicketsHistoryScreenState extends ConsumerState<TicketsHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId != null) {
      await ref.read(ticketsProvider.notifier).loadUserTickets(userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes tickets'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Historique'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: ticketsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ticketsState.error != null
              ? _buildErrorState(ticketsState.error!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUpcomingTickets(ticketsState),
                    _buildTicketsHistory(ticketsState),
                  ],
                ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTickets,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTickets(TicketsState state) {
    final upcomingTickets =
        ref.read(ticketsProvider.notifier).getUpcomingTickets();

    if (upcomingTickets.isEmpty) {
      return _buildEmptyState(
        'Aucun voyage à venir',
        'Réservez votre prochain voyage dès maintenant !',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingTickets.length,
      itemBuilder: (context, index) {
        final ticket = upcomingTickets[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TicketViewer(
            ticket: ticket,
            onDownload: () => _handleDownload(ticket),
            onShare: () => _handleShare(ticket),
          ),
        );
      },
    );
  }

  Widget _buildTicketsHistory(TicketsState state) {
    final ticketHistory = ref.read(ticketsProvider.notifier).getTicketHistory();

    if (ticketHistory.isEmpty) {
      return _buildEmptyState(
        'Aucun voyage passé',
        'Votre historique de voyages apparaîtra ici',
      );
    }

    // Grouper les tickets par mois
    final groupedTickets = <String, List<ExtendedTicket>>{};
    for (final ticket in ticketHistory) {
      final monthYear =
          DateFormat('MMMM yyyy', 'fr_FR').format(ticket.bus.departureTime);
      groupedTickets.putIfAbsent(monthYear, () => []).add(ticket);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedTickets.length,
      itemBuilder: (context, index) {
        final monthYear = groupedTickets.keys.elementAt(index);
        final tickets = groupedTickets[monthYear]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                monthYear.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...tickets.map((ticket) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TicketViewer(
                    ticket: ticket,
                    onDownload: () => _handleDownload(ticket),
                    onShare: () => _handleShare(ticket),
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_tabController.index == 0)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/bus-search');
              },
              icon: const Icon(Icons.search),
              label: const Text('Rechercher un voyage'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleDownload(ExtendedTicket ticket) async {
    // TODO: Implémenter la logique de téléchargement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Téléchargement du ticket...')),
    );
  }

  Future<void> _handleShare(ExtendedTicket ticket) async {
    // TODO: Implémenter la logique de partage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partage du ticket...')),
    );
  }
}
