// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../widgets/booking_tabs.dart';
import '../widgets/contact_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    if (user == null) return const SizedBox.shrink();

    return Theme(
      data: theme.copyWith(
        // Personnalisation du thème pour cet écran
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // En-tête avec photo de profil
              ProfileHeader(user: user),

              // Contenu principal avec animation de défilement
              // Contenu principal
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  // Utilisation de SliverList au lieu de SliverToBoxAdapter
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    ProfileInfoCard(user: user),
                    const SizedBox(height: 16),
                    const BookingTabs(),
                    const SizedBox(height: 16),
                    ContactsSection(contacts: user.contacts),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
            /*SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Carte d'information avec animation
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 300),
                        offset: const Offset(0, -0.05),
                        child: ProfileInfoCard(user: user),
                      ),
          
                      // Séparateur visuel subtil
                      _buildSectionDivider(),
          
                      // Section des réservations
                      const AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: BookingTabs(),
                      ),
          
                      // Séparateur visuel subtil
                      _buildSectionDivider(),
          
                      // Section des contacts avec animation
                      /*AnimatedSlide(
                        duration: const Duration(milliseconds: 300),
                        offset: const Offset(0, 0),
                        child: ContactsSection(contacts: user.contacts),
                      ),*/
          
                      // Espace en bas pour le défilement
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],*/
          ),
        ),

        // Bouton d'action flottant pour un accès rapide aux paramètres
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// Exemple de provider pour les statistiques de l'utilisateur
final userStatsProvider = Provider<UserStats>((ref) {
  final user = ref.watch(authProvider).user;
  // Logique pour calculer les statistiques
  return const UserStats(
    totalBookings: 12,
    rating: 0,
    reviews: 0,
  );
});

class UserStats {
  final int totalBookings;
  final double rating;
  final int reviews;

  const UserStats({
    required this.totalBookings,
    required this.rating,
    required this.reviews,
  });
}

// Extension pour formater les nombres
extension NumberFormat on num {
  String get formatted => toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
}

//11111111111111111
/*class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      //backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          ProfileHeader(user: user),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Column(
                children: [
                  ProfileInfoCard(user: user),
                  //const SizedBox(height: 8),
                  const BookingTabs(),
                  ContactsSection(contacts: user.contacts),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/
