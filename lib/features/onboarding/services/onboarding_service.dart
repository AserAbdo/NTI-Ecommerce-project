import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_config.dart';

/// Service to manage onboarding state persistence
class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_complete';

  /// Check if onboarding should be shown
  /// Returns true if:
  /// - forceShowOnboarding is true (for testing), OR
  /// - User has never completed onboarding before
  static Future<bool> shouldShowOnboarding() async {
    // If force show is enabled, always show onboarding
    if (AppConfig.forceShowOnboarding) {
      return true;
    }

    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_onboardingCompleteKey) ?? false);
  }

  /// Mark onboarding as complete
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  /// Reset onboarding state (for testing)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompleteKey);
  }
}
