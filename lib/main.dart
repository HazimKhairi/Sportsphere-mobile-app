import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app/app.dart';
import 'core/config/sphere_config.dart';
import 'core/firebase/firebase_options.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    providerAndroid: const AndroidDebugProvider(),
    providerApple: const AppleDebugProvider(),
  );
  if (SphereConfig.stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = SphereConfig.stripePublishableKey;
    try {
      await Stripe.instance.applySettings();
    } catch (_) {
      // Don't crash on init failure — Stripe surfaces actionable errors at
      // call sites (initPaymentSheet, presentPaymentSheet).
    }
  }
  runApp(const ProviderScope(child: SphereApp()));
}
