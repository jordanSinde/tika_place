// lib/features/bus_booking/widgets/promo_code_input.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/promo_code.dart';
import '../providers/price_calculator_provider.dart';
import '../providers/reservation_provider.dart';

class PromoCodeInput extends ConsumerStatefulWidget {
  final VoidCallback? onPromoCodeRemoved;
  final bool disabled;

  const PromoCodeInput({
    super.key,
    this.onPromoCodeRemoved,
    this.disabled = false,
  });

  @override
  ConsumerState<PromoCodeInput> createState() => _PromoCodeInputState();
}

class _PromoCodeInputState extends ConsumerState<PromoCodeInput> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _applyPromoCode() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Vérifier si une réservation est en cours
      final currentReservation =
          ref.read(reservationProvider).currentReservation;
      if (currentReservation == null) {
        throw Exception('Aucune réservation en cours');
      }

      // Vérifier si le code n'a pas déjà été utilisé
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Appliquer le code promo
      await ref
          .read(priceCalculatorProvider.notifier)
          .applyPromoCode(code, userId);

      // Si succès, effacer le champ
      _controller.clear();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
  Widget build(BuildContext context) {
    final priceState = ref.watch(priceCalculatorProvider);

    // Si un code promo est déjà appliqué
    if (priceState.appliedPromoCode != null) {
      return _buildAppliedPromoCode(priceState.appliedPromoCode!);
    }

    // Si désactivé ou réservation expirée
    if (widget.disabled) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Code promo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Entrez votre code',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _applyPromoCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Appliquer'),
                ),
              ),
            ],
          ),
          if (priceState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                priceState.error!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppliedPromoCode(PromoCode promoCode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Code promo appliqué: ${promoCode.code}',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (promoCode.description != null)
                  Text(
                    promoCode.description!,
                    style: TextStyle(
                      color: AppColors.success.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.onPromoCodeRemoved != null && !widget.disabled)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: widget.onPromoCodeRemoved,
              color: AppColors.error,
            ),
        ],
      ),
    );
  }
}


//V1


/*
class PromoCodeInput extends ConsumerStatefulWidget {
  const PromoCodeInput({super.key});

  @override
  ConsumerState<PromoCodeInput> createState() => _PromoCodeInputState();
}

class _PromoCodeInputState extends ConsumerState<PromoCodeInput> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _applyPromoCode() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);

    // Simuler un userId pour le moment
    const userId = "test_user";

    try {
      await ref
          .read(priceCalculatorProvider.notifier)
          .applyPromoCode(code, userId);

      final error = ref.read(priceCalculatorProvider).error;
      if (error == null) {
        _controller.clear();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceState = ref.watch(priceCalculatorProvider);

    // Si un code promo est déjà appliqué, ne pas montrer le champ
    if (priceState.appliedPromoCode != null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Code promo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Entrez votre code',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _applyPromoCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Appliquer'),
                ),
              ),
            ],
          ),
          if (priceState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                priceState.error!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
*/