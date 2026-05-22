/// Centralized environment-driven config. Values come from `--dart-define`
/// at build time. Empty defaults are safe for dev — Stripe simply won't
/// init if publishable key is missing.
abstract final class SphereConfig {
  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sprtsphr.app',
  );
}
