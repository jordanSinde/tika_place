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
}
