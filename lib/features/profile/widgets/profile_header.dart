// lib/features/profile/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_assets.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../auth/models/user.dart';

class ProfileHeader extends ConsumerWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Stack(
        clipBehavior: Clip.none,
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset(
              AppAssets.hotelDetail1,
              fit: BoxFit.cover,
            ),
          ),
          // Arc blanc
          Positioned(
            bottom: -1, // Pour éviter la ligne entre l'arc et le contenu
            left: 0,
            right: 0,
            child: Container(
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.background, //Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
              ),
            ),
          ),
          // Image de profil
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: user.profilePicture != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user.profilePicture!),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.firstName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () => context.push('/settings'),
            ),
          ),
        ),
      ],
    );
  }
}
