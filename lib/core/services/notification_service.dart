import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for local push notifications.
///
/// Handles initialization, permission requests, and displaying
/// notifications for certificate expiry alerts and other events.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Initialization ────────────────────────────────────────

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse:
          _onNotificationResponse,
    );
  }

  // ── Permissions ───────────────────────────────────────────

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      await android.requestNotificationsPermission();
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return true;
  }

  // ── Show Notification ─────────────────────────────────────

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'ndt_certificates',
      'Certificate Expiry',
      channelDescription:
          'Alerts for NDT certificates that are expiring soon',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Show a certificate expiry warning.
  Future<void> showCertificateExpiryWarning({
    required String certificateNo,
    required DateTime expireDate,
  }) async {
    final daysLeft = expireDate.difference(DateTime.now()).inDays;

    // Use a combination of certificate hash and timestamp to reduce
    // collision risk while still allowing updates to the same certificate.
    final id = (certificateNo.hashCode ^ daysLeft.hashCode).abs();

    await showNotification(
      id: id,
      title: 'Certificate Expiring Soon',
      body: 'Certificate $certificateNo expires in $daysLeft days '
          '(${expireDate.toIso8601String().split('T')[0]})',
      payload: certificateNo,
    );
  }

  // ── Notification Tap Handler ──────────────────────────────

  void _onNotificationResponse(
      NotificationResponse response) {
    // Navigate to certificate detail page based on payload
    final payload = response.payload;
    if (payload != null) {
      // Handle navigation via router
    }
  }
}
