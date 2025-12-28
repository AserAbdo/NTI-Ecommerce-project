import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for handling local notifications
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;
    print('✅ Local notifications initialized');
  }

  /// Show a notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'nti_ecommerce_channel',
          'NTI E-Commerce',
          channelDescription: 'Notifications for NTI E-Commerce app',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(''),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // ==================== COUPON NOTIFICATIONS ====================

  /// Show notification when new user gets their welcome coupon
  static Future<void> showWelcomeCouponNotification() async {
    await showNotification(
      id: 1001,
      title: '🎁 Welcome Gift Inside!',
      body:
          'You\'ve received a special 50% OFF coupon "ELZOZ2026" on your first order! Don\'t let it expire! 🛍️',
      payload: 'welcome_coupon',
    );
  }

  /// Show notification when user successfully uses a coupon
  static Future<void> showCouponUsedNotification({
    required String couponCode,
    required double savedAmount,
  }) async {
    final messages = [
      '🎉 Cha-ching! You just saved EGP ${savedAmount.toStringAsFixed(0)} with "$couponCode"! Money well spent! 💰',
      '🔥 Ka-boom! EGP ${savedAmount.toStringAsFixed(0)} saved! Your wallet is doing a happy dance! 💃',
      '✨ Brilliant move! You\'re EGP ${savedAmount.toStringAsFixed(0)} richer! Treat yourself! 🎊',
      '🚀 Savings activated! EGP ${savedAmount.toStringAsFixed(0)} stays in your pocket! You\'re a shopping genius! 🧠',
      '💫 Magic moment! "$couponCode" just saved you EGP ${savedAmount.toStringAsFixed(0)}! Enjoy your purchase! 🛒',
    ];

    // Pick a random message for variety
    final randomMessage =
        messages[DateTime.now().millisecond % messages.length];

    await showNotification(
      id: 1002 + DateTime.now().millisecond,
      title: '🎊 Savings Unlocked!',
      body: randomMessage,
      payload: 'coupon_used',
    );
  }

  /// Show notification when coupon is about to expire
  static Future<void> showCouponExpiringNotification({
    required String couponCode,
    required int daysLeft,
  }) async {
    String urgency;
    if (daysLeft <= 1) {
      urgency = '⚡ LAST CHANCE! ';
    } else if (daysLeft <= 3) {
      urgency = '⏰ Hurry! ';
    } else {
      urgency = '📅 Reminder: ';
    }

    await showNotification(
      id: 1003,
      title: '${urgency}Your Coupon is Expiring!',
      body:
          'Don\'t miss out! Your "$couponCode" coupon expires in $daysLeft ${daysLeft == 1 ? 'day' : 'days'}! Use it now and save big! 💸',
      payload: 'coupon_expiring',
    );
  }

  /// Show notification for order placed successfully
  static Future<void> showOrderSuccessNotification({
    required String orderNumber,
  }) async {
    await showNotification(
      id: 2001,
      title: '🛍️ Order Confirmed!',
      body:
          'Your order #$orderNumber is on its way! Thank you for shopping with us! 📦',
      payload: 'order_success',
    );
  }
}
