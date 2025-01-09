import 'package:form_validator/form_validator.dart';

class FormValidator {
  static final ValidationBuilder email = ValidationBuilder()
      .email('Please enter a valid email')
      .maxLength(50, 'Email is too long')
      .required('Email is required');

  static final ValidationBuilder password = ValidationBuilder()
      .minLength(6, 'Password must be at least 6 characters')
      .maxLength(32, 'Password is too long')
      .regExp(
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$'),
        'Password must contain letters and numbers',
      )
      .required('Password is required');

  static final ValidationBuilder name = ValidationBuilder()
      .minLength(2, 'Name must be at least 2 characters')
      .maxLength(50, 'Name is too long')
      .regExp(
        RegExp(r'^[a-zA-Z\s]+$'),
        'Name can only contain letters',
      )
      .required('Name is required');

  static final ValidationBuilder phone = ValidationBuilder()
      .phone('Please enter a valid phone number')
      .maxLength(15, 'Phone number is too long');

  static final ValidationBuilder phoneNumber = ValidationBuilder()
      .minLength(9, 'Le numéro doit contenir au moins 9 chiffres')
      .maxLength(15, 'Le numéro est trop long')
      .regExp(
        RegExp(r'^\d+$'),
        'Le numéro ne doit contenir que des chiffres',
      )
      .required('Le numéro de téléphone est requis');

  static final ValidationBuilder required =
      ValidationBuilder().required('This field is required');

  static String? confirmPassword(String? value, String password) {
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
