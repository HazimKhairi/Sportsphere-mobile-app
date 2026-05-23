import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:go_router/go_router.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../programs/domain/registration_status.dart';
import '../../programs/presentation/registration_providers.dart';
import '../domain/payment_intent.dart';
import 'payment_intent_providers.dart';

/// Runs the full Stripe PaymentSheet flow for a program.
///
/// 1. Create PaymentIntent via backend
/// 2. Init + present PaymentSheet (card, FPX, Apple Pay, Google Pay)
/// 3. On confirm → POST /api/programs/register
/// 4. Navigate to /payment/success/:id OR /payment/failure
///
/// Returns true on success so the caller can clean up UI state.
Future<bool> runStripeCheckout({
  required BuildContext context,
  required WidgetRef ref,
  required String programId,
  required int amountCents,
  required String currency,
}) async {
  // 1. Create intent
  PaymentIntent intent;
  try {
    intent = await ref.read(paymentIntentRepositoryProvider).createPaymentIntent(
          programId: programId,
          amountCents: amountCents,
          currency: currency,
        );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start payment: $e')),
      );
    }
    return false;
  }

  // 2. Init + present sheet
  try {
    await stripe.Stripe.instance.initPaymentSheet(
      paymentSheetParameters: stripe.SetupPaymentSheetParameters(
        paymentIntentClientSecret: intent.clientSecret,
        merchantDisplayName: 'SportSphere',
        style: ThemeMode.dark,
        appearance: stripe.PaymentSheetAppearance(
          colors: stripe.PaymentSheetAppearanceColors(
            primary: context.sc.primary,
            background: context.sc.surface,
            componentBackground: context.sc.surfaceElev1,
            componentBorder: context.sc.borderSubtle,
            componentDivider: context.sc.borderSubtle,
            primaryText: context.sc.onSurface,
            secondaryText: context.sc.onSurfaceMuted,
            componentText: context.sc.onSurface,
            placeholderText: context.sc.onSurfaceMuted,
            icon: context.sc.primary,
            error: context.sc.danger,
          ),
          shapes: stripe.PaymentSheetShape(
            borderRadius: 12,
            borderWidth: 1,
          ),
          primaryButton: stripe.PaymentSheetPrimaryButtonAppearance(
            colors: stripe.PaymentSheetPrimaryButtonTheme(
              light: stripe.PaymentSheetPrimaryButtonThemeColors(
                background: context.sc.primary,
                text: context.sc.onPrimary,
                border: context.sc.primary,
              ),
              dark: stripe.PaymentSheetPrimaryButtonThemeColors(
                background: context.sc.primary,
                text: context.sc.onPrimary,
                border: context.sc.primary,
              ),
            ),
          ),
        ),
      ),
    );

    await stripe.Stripe.instance.presentPaymentSheet();
  } on stripe.StripeException catch (e) {
    final reason = e.error.localizedMessage ?? e.error.code.toString();
    if (e.error.code == stripe.FailureCode.Canceled) {
      // User dismissed — no toast, no failure screen.
      return false;
    }
    if (context.mounted) {
      unawaited(context.push('/payment/failure?reason=${Uri.encodeComponent(reason)}'));
    }
    return false;
  } catch (e) {
    if (context.mounted) {
      unawaited(context.push('/payment/failure?reason=${Uri.encodeComponent(e.toString())}'));
    }
    return false;
  }

  // 3. Confirm registration
  RegistrationResult registration;
  try {
    registration = await ref.read(registrationRepositoryProvider).confirmRegistration(
          programId: programId,
          paymentIntentId: intent.paymentIntentId,
        );
  } catch (e) {
    if (context.mounted) {
      unawaited(context.push('/payment/failure?reason=${Uri.encodeComponent(e.toString())}'));
    }
    return false;
  }

  // 4. Success
  if (context.mounted) {
    // Invalidate the isRegistered family so program detail re-checks.
    ref.invalidate(isRegisteredForProvider);
    context.go('/payment/success/${registration.registrationId}');
  }
  return true;
}
