/// Application configuration constants
///
/// Use this file to configure app-wide settings without code changes
class AppConfig {
  AppConfig._();

  /// Set to `true` to always show onboarding (for testing/design purposes)
  /// Set to `false` for production (onboarding shows only once)
  static const bool forceShowOnboarding = true;

  /// Onboarding settings
  static const int onboardingAnimationDuration = 800; // milliseconds
  static const int onboardingPageTransitionDuration = 400; // milliseconds
}
