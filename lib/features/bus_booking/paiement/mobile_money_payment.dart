// lib/features/bus_booking/screens/booking/steps/payment/mobile_money_payment.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/config/theme/app_colors.dart';
import '../../common/widgets/inputs/custom_textfield.dart';
import '../providers/booking_provider.dart';

class MobileMoneyPayment extends StatefulWidget {
  final PaymentMethod method;
  final double amount;
  final Function(String) onPhoneSubmitted;

  const MobileMoneyPayment({
    super.key,
    required this.method,
    required this.amount,
    required this.onPhoneSubmitted,
  });

  @override
  State<MobileMoneyPayment> createState() => _MobileMoneyPaymentState();
}

class _MobileMoneyPaymentState extends State<MobileMoneyPayment> {
  final _phoneController = TextEditingController();
  bool _isValidPhone = false;
  bool _processingPayment = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final isOrangeMoney = widget.method == PaymentMethod.orangeMoney;
    final providerColor =
        isOrangeMoney ? const Color(0xFFFF6600) : const Color(0xFFFFCC00);
    final providerTextColor = isOrangeMoney ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête du paiement
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: providerColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  isOrangeMoney
                      ? 'assets/icons/orange_money.png'
                      : 'assets/icons/mtn_momo.png',
                  width: 32,
                  height: 32,
                  // Utiliser un placeholder en attendant les assets
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.payment,
                    color: providerColor,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                isOrangeMoney ? 'Orange Money' : 'MTN Mobile Money',
                style: TextStyle(
                  color: providerTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Corps du formulaire de paiement
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Montant à payer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Montant à payer',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${widget.amount.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Instructions
              Text(
                'Instructions pour le paiement ${isOrangeMoney ? 'Orange Money' : 'MTN Mobile Money'}:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildInstructionStep(
                  1, 'Entrez votre numéro de téléphone ci-dessous'),
              _buildInstructionStep(
                  2, 'Validez et attendez le message de confirmation'),
              _buildInstructionStep(3, 'Composez #150# sur votre téléphone'),
              _buildInstructionStep(4, 'Entrez votre code secret pour valider'),
              const SizedBox(height: 24),

              // Champ de saisie du numéro
              CustomTextField(
                controller: _phoneController,
                label: 'Numéro de téléphone',
                hint: isOrangeMoney ? '6XX XXX XXX' : '65X XXX XXX',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
                /*inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                  _PhoneNumberFormatter(),
                ],*/
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  final cleanNumber = value.replaceAll(' ', '');
                  if (cleanNumber.length != 9) {
                    return 'Le numéro doit contenir 9 chiffres';
                  }
                  if (isOrangeMoney && !cleanNumber.startsWith('6')) {
                    return 'Le numéro doit commencer par 6';
                  }
                  if (!isOrangeMoney && !cleanNumber.startsWith('65')) {
                    return 'Le numéro doit commencer par 65';
                  }
                  return null;
                },
                onChanged: (value) {
                  final cleanNumber = value.replaceAll(' ', '');
                  setState(() {
                    _isValidPhone = cleanNumber.length == 9 &&
                        (isOrangeMoney
                            ? cleanNumber.startsWith('6')
                            : cleanNumber.startsWith('65'));
                  });
                },
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Bouton de validation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValidPhone && !_processingPayment
                      ? _handlePayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: providerColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _processingPayment
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Valider le paiement',
                          style: TextStyle(
                            color: providerTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() {
      _processingPayment = true;
      _errorMessage = null;
    });

    try {
      await widget.onPhoneSubmitted(_phoneController.text);
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      });
    } finally {
      setState(() {
        _processingPayment = false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');

    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) buffer.write(' ');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
