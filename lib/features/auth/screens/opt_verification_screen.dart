// Créez un nouveau fichier otp_verification_screen.dart

import 'package:flutter/material.dart';
import '../widgets/auth_header.dart';
import '../widgets/opt_verification_widget.dart';

class OTPVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final bool isLogin;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.isLogin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthHeader(
                  title: 'Verify Phone OTPscreen',
                  subtitle: 'Enter the verification code OTPscreen',
                  onBackPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 32),
                OTPVerificationWidget(
                  phoneNumber: phoneNumber,
                  firstName: firstName,
                  lastName: lastName,
                  isLogin: isLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
