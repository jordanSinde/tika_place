// lib/features/bus_booking/models/payment_error.dart

enum PaymentErrorType {
  invalidPhone,
  invalidCode,
  insufficientFunds,
  networkError,
  timeout,
  cancelled,
  unknown
}

class PaymentError {
  final PaymentErrorType type;
  final String message;
  final String? technicalDetails;
  final bool canRetry;

  const PaymentError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.canRetry = true,
  });
}

/*class PaymentError implements Exception {
  final PaymentErrorType type;
  final String message;
  final String? technicalDetails;
  final bool canRetry;

  const PaymentError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.canRetry = true,
  });

  factory PaymentError.invalidPhone() {
    return const PaymentError(
      type: PaymentErrorType.invalidPhone,
      message: 'Le numéro de téléphone est invalide.',
      canRetry: true,
    );
  }

  factory PaymentError.invalidCode() {
    return const PaymentError(
      type: PaymentErrorType.invalidCode,
      message: 'Le code de paiement est invalide.',
      canRetry: true,
    );
  }

  factory PaymentError.insufficientFunds() {
    return const PaymentError(
      type: PaymentErrorType.insufficientFunds,
      message: 'Solde insuffisant pour effectuer cette transaction.',
      canRetry: true,
    );
  }

  factory PaymentError.networkError() {
    return const PaymentError(
      type: PaymentErrorType.networkError,
      message: 'Erreur de connexion. Vérifiez votre connexion internet.',
      canRetry: true,
    );
  }

  factory PaymentError.timeout() {
    return const PaymentError(
      type: PaymentErrorType.timeout,
      message: 'La session de paiement a expiré. Veuillez réessayer.',
      canRetry: true,
    );
  }

  factory PaymentError.cancelled() {
    return const PaymentError(
      type: PaymentErrorType.cancelled,
      message: 'Le paiement a été annulé.',
      canRetry: false,
    );
  }

  factory PaymentError.unknown(String details) {
    return PaymentError(
      type: PaymentErrorType.unknown,
      message: 'Une erreur inattendue est survenue.',
      technicalDetails: details,
      canRetry: true,
    );
  }

  String get userMessage {
    String baseMessage = message;
    if (canRetry) {
      baseMessage += '\nVous pouvez réessayer le paiement.';
    }
    return baseMessage;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'message': message,
      'technicalDetails': technicalDetails,
      'canRetry': canRetry,
    };
  }
}*/
