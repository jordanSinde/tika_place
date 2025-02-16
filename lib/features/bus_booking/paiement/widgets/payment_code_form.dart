// lib/features/bus_booking/widgets/payment_code_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../providers/booking_provider.dart';

import '../services/payment_manager.dart';

class PaymentCodeForm extends StatefulWidget {
  final PaymentMethod paymentMethod;
  final Function(String) onCodeSubmitted;
  final VoidCallback onClose;

  const PaymentCodeForm({
    super.key,
    required this.paymentMethod,
    required this.onCodeSubmitted,
    required this.onClose,
  });

  @override
  State<PaymentCodeForm> createState() => _PaymentCodeFormState();
}

class _PaymentCodeFormState extends State<PaymentCodeForm> {
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
    if (_phoneController.text.isEmpty) {
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
      final isValid = await paymentManager.validatePaymentMethod(
        method: widget.paymentMethod,
        phoneNumber: _phoneController.text,
      );

      if (!mounted) return;

      if (isValid) {
        setState(() {
          _codeRequested = true;
          _phoneError = null;
        });

        // Afficher le message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code envoyé ! Vérifiez vos messages.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        setState(() {
          _phoneError = 'Numéro de téléphone invalide';
        });
      }
    } catch (e) {
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifyingCode = true;
      _codeError = null;
    });

    try {
      await widget.onCodeSubmitted(_codeController.text);
    } catch (e) {
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
          // En-tête
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: providerColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
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
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Champ numéro de téléphone
                TextFormField(
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
                ),

                if (!_codeRequested) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Recevoir le code'),
                  ),
                ],

                if (_codeRequested) ...[
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le code reçu';
                      }
                      if (value.length != 6) {
                        return 'Le code doit contenir 6 chiffres';
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Valider le paiement'),
                  ),
                ],

                // Section informative
                if (_codeRequested) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Instructions :',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInstructionStep(
                          1,
                          'Vous allez recevoir un SMS avec un code de confirmation',
                        ),
                        _buildInstructionStep(
                          2,
                          'Entrez le code reçu ci-dessus',
                        ),
                        _buildInstructionStep(
                          3,
                          'Validez le paiement sur votre téléphone',
                        ),
                      ],
                    ),
                  ),
                ],

                // Message d'erreur global
                if (_codeError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _codeError!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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
              color: widget.paymentMethod == PaymentMethod.orangeMoney
                  ? const Color(0xFFFF6600)
                  : const Color(0xFFFFCC00),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$step',
              style: TextStyle(
                color: widget.paymentMethod == PaymentMethod.orangeMoney
                    ? Colors.white
                    : Colors.black,
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

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un numéro de téléphone';
    }

    final cleanNumber = value.replaceAll(' ', '');
    if (cleanNumber.length != 9) {
      return 'Le numéro doit contenir 9 chiffres';
    }

    if (widget.paymentMethod == PaymentMethod.orangeMoney) {
      if (!cleanNumber.startsWith('6')) {
        return 'Le numéro doit commencer par 6';
      }
    } else {
      if (!cleanNumber.startsWith('65')) {
        return 'Le numéro doit commencer par 65';
      }
    }

    return null;
  }
}

/*
class PaymentCodeForm extends ConsumerStatefulWidget {
  final PaymentMethod paymentMethod;
  final Function(String) onCodeSubmitted;
  final VoidCallback onClose;

  const PaymentCodeForm({
    super.key,
    required this.paymentMethod,
    required this.onCodeSubmitted,
    required this.onClose,
  });

  @override
  ConsumerState<PaymentCodeForm> createState() => _PaymentCodeFormState();
}

class _PaymentCodeFormState extends ConsumerState<PaymentCodeForm> {
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
    if (_phoneController.text.isEmpty) {
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
      final isValid = await mobileMoneyService.verifyPhoneNumber(
        method: widget.paymentMethod,
        phoneNumber: _phoneController.text,
      );

      if (!mounted) return;

      if (isValid) {
        final price = ref.read(priceCalculatorProvider).total;
        final response = await mobileMoneyService.initiatePayment(
          method: widget.paymentMethod,
          phoneNumber: _phoneController.text,
          amount: price,
          description: 'Paiement billet de bus',
        );

        if (response.isSuccess) {
          setState(() {
            _codeRequested = true;
            _phoneError = null;
          });

          // Afficher le message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code envoyé ! Vérifiez vos messages.'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          setState(() {
            _phoneError = response.message ?? 'Erreur lors de l\'envoi du code';
          });
        }
      } else {
        setState(() {
          _phoneError = 'Numéro de téléphone invalide';
        });
      }
    } catch (e) {
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifyingCode = true;
      _codeError = null;
    });

    try {
      await widget.onCodeSubmitted(_codeController.text);
    } catch (e) {
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
          // En-tête
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: providerColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
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
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Champ numéro de téléphone
                TextFormField(
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
                ),
                if (!_codeRequested) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Recevoir le code'),
                  ),
                ],
                if (_codeRequested) ...[
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Valider le paiement'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
