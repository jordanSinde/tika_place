//lib/features/home/widgets/contact_section.dart
import 'package:flutter/material.dart';
import '../../../core/config/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  // Fonction pour lancer WhatsApp
  Future<void> _launchWhatsApp() async {
    const whatsappUrl = "https://wa.me/237653783826";
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  // Fonction pour lancer un appel téléphonique
  Future<void> _launchPhoneCall() async {
    const phoneUrl = "tel:+237653783826";
    if (await canLaunchUrl(Uri.parse(phoneUrl))) {
      await launchUrl(Uri.parse(phoneUrl));
    } else {
      throw 'Could not launch phone call';
    }
  }

  // Fonction pour lancer l'email
  Future<void> _launchEmail() async {
    const emailUrl =
        "mailto:eveiltechnologique100@gmail.com?subject=Contact%20from%20App&body=Hello,";
    if (await canLaunchUrl(Uri.parse(emailUrl))) {
      await launchUrl(Uri.parse(emailUrl));
    } else {
      throw 'Could not launch email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contactez-nous',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildContactCard(
            icon: FontAwesomeIcons
                .whatsapp, // Utilisation de FontAwesome pour WhatsApp
            title: 'WhatsApp',
            subtitle: '+237 653 783 826',
            onTap: _launchWhatsApp,
            iconColor:
                const Color(0xFF25D366), // Couleur officielle de WhatsApp
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            icon: Icons.phone,
            title: 'Appel direct',
            subtitle: '+237 653 783 826',
            onTap: _launchPhoneCall,
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            icon: Icons.email,
            title: 'Email',
            subtitle: 'eveiltechnologique100@gmail.com',
            onTap: _launchEmail,
            iconColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: iconColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
