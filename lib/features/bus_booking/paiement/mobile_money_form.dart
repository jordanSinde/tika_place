// lib/features/bus_booking/widgets/mobile_money_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/theme/app_colors.dart';
import '../providers/booking_provider.dart';
import 'services/mobile_money_service.dart';

class MobileMoneyForm extends ConsumerStatefulWidget {
  final PaymentMethod paymentMethod;
  final double amount;
  final Function(String) onCodeSubmitted;
  final VoidCallback onCancel;

  const MobileMoneyForm({
    super.key,
    required this.paymentMethod,
    required this.amount,
    required this.onCodeSubmitted,
    required this.onCancel,
  });

  @override
  ConsumerState<MobileMoneyForm> createState() => _MobileMoneyFormState();
}

class _MobileMoneyFormState extends ConsumerState<MobileMoneyForm> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRequestingCode = false;
  bool _isVerifyingCode = false;
  String? _phoneError;
  String? _codeError;
  bool _codeRequested = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    print('📱 PAYMENT FORM: Requesting payment code');
    if (_phoneController.text.isEmpty) {
      print('❌ PAYMENT FORM: Empty phone number');
      setState(() {
        _phoneError = 'Veuillez entrer votre numéro de téléphone';
      });
      return;
    }

    setState(() {
      _isRequestingCode = true;
      _phoneError = null;
    });

    try {
      print('🔍 PAYMENT FORM: Validating phone number');
      final isValid = await mobileMoneyService.verifyPhoneNumber(
        method: widget.paymentMethod,
        phoneNumber: _phoneController.text,
      );

      if (!mounted) return;

      if (isValid) {
        print('✅ PAYMENT FORM: Phone number valid');
        final response = await mobileMoneyService.initiatePayment(
          method: widget.paymentMethod,
          phoneNumber: _phoneController.text,
          amount: widget.amount,
          description: 'Paiement billet de bus',
        );

        if (response.isSuccess) {
          print('✅ PAYMENT FORM: Payment code sent successfully');
          setState(() {
            _codeRequested = true;
            _phoneError = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code envoyé ! Vérifiez vos messages.'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          print('❌ PAYMENT FORM: Failed to send payment code');
          setState(() {
            _phoneError = response.message ?? 'Erreur lors de l\'envoi du code';
          });
        }
      } else {
        print('❌ PAYMENT FORM: Invalid phone number');
        setState(() {
          _phoneError = 'Numéro de téléphone invalide';
        });
      }
    } catch (e) {
      print('❌ PAYMENT FORM: Error during code request: $e');
      setState(() {
        _phoneError = 'Une erreur est survenue. Veuillez réessayer.';
      });
    } finally {
      setState(() {
        _isRequestingCode = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    print('🔐 PAYMENT FORM: Verifying payment code');
    if (!_formKey.currentState!.validate()) {
      print('❌ PAYMENT FORM: Form validation failed');
      return;
    }

    setState(() {
      _isVerifyingCode = true;
      _codeError = null;
    });

    try {
      print('✅ PAYMENT FORM: Submitting code for verification');
      await widget.onCodeSubmitted(_codeController.text);
    } catch (e) {
      print('❌ PAYMENT FORM: Code verification failed: $e');
      setState(() {
        _codeError = 'Code invalide. Veuillez réessayer.';
      });
    } finally {
      setState(() {
        _isVerifyingCode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOrangeMoney = widget.paymentMethod == PaymentMethod.orangeMoney;
    final providerColor =
        isOrangeMoney ? const Color(0xFFFF6600) : const Color(0xFFFFCC00);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(providerColor, isOrangeMoney),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPhoneInput(isOrangeMoney),
                if (!_codeRequested)
                  _buildRequestCodeButton(providerColor)
                else
                  _buildCodeVerificationSection(providerColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color providerColor, bool isOrangeMoney) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: providerColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: providerColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOrangeMoney ? 'Orange Money' : 'MTN Mobile Money',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Un code de paiement sera envoyé par SMS',
                  style: TextStyle(
                    color: AppColors.textLight.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onCancel,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(bool isOrangeMoney) {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Numéro de téléphone',
        hintText: isOrangeMoney ? '6XX XXX XXX' : '65X XXX XXX',
        prefixIcon: const Icon(Icons.phone),
        errorText: _phoneError,
        enabled: !_codeRequested,
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
    );
  }

  Widget _buildRequestCodeButton(Color providerColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        onPressed: _isRequestingCode ? null : _requestCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: providerColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: _isRequestingCode
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Recevoir le code'),
      ),
    );
  }

  Widget _buildCodeVerificationSection(Color providerColor) {
    return Column(
      children: [
        const SizedBox(height: 24),
        TextFormField(
          controller: _codeController,
          decoration: InputDecoration(
            labelText: 'Code de paiement',
            prefixIcon: const Icon(Icons.lock),
            errorText: _codeError,
          ),
          keyboardType: TextInputType.number,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer le code reçu';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isVerifyingCode ? null : _verifyCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: providerColor,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: _isVerifyingCode
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Valider le paiement'),
        ),
      ],
    );
  }
}
