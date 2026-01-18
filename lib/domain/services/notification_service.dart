import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  void Function(String?)? _onNotificationTap;

  Future<void> initialize({void Function(String?)? onNotificationTap}) async {
    if (_isInitialized) return;

    _onNotificationTap = onNotificationTap;

    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (_onNotificationTap != null) {
          _onNotificationTap!(response.payload);
        }
      },
    );
    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }

  Future<void> showSalaryReminder(double amount, String monthName) async {
    if (kIsWeb) return;

    final formattedAmount = _formatAmount(amount);

    const androidDetails = AndroidNotificationDetails(
      'daypay_channel',
      'DayPay',
      channelDescription: 'Уведомления о зарплате',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
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

    await _notifications.show(
      1,
      'Скоро зарплата!',
      'Ожидаемая сумма за $monthName: $formattedAmount ₽',
      details,
    );
  }

  Future<void> showMonthlySummary(double amount, String monthName) async {
    if (kIsWeb) return;

    final formattedAmount = _formatAmount(amount);

    const androidDetails = AndroidNotificationDetails(
      'daypay_channel',
      'DayPay',
      channelDescription: 'Уведомления о зарплате',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
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

    await _notifications.show(
      2,
      'Итоги за $monthName',
      'Ваша зарплата: $formattedAmount ₽. Нажмите для подробностей.',
      details,
      payload: 'statistics',
    );
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _notifications.cancelAll();
  }

  Future<void> showUpdateNotification(String version, String? releaseNotes) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'daypay_update_channel',
      'Обновления',
      channelDescription: 'Уведомления о новых версиях приложения',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
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

    String body = 'Нажмите, чтобы обновить приложение';
    if (releaseNotes != null && releaseNotes.isNotEmpty) {
      final firstLine = releaseNotes.split('\n').first.trim();
      if (firstLine.isNotEmpty && firstLine.length <= 100) {
        body = firstLine;
      }
    }

    await _notifications.show(
      100,
      'Доступно обновление v$version',
      body,
      details,
      payload: 'update',
    );
  }

  Future<void> showDownloadProgressNotification(int progress, String version) async {
    if (kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      'daypay_download_channel',
      'Загрузка',
      channelDescription: 'Уведомления о загрузке обновлений',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      onlyAlertOnce: true,
      ongoing: true,
      autoCancel: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      101,
      'Загрузка обновления v$version',
      'Загружено $progress%',
      details,
    );
  }

  Future<void> showDownloadCompleteNotification(String version) async {
    if (kIsWeb) return;

    await _notifications.cancel(101);

    const androidDetails = AndroidNotificationDetails(
      'daypay_update_channel',
      'Обновления',
      channelDescription: 'Уведомления о новых версиях приложения',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
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

    await _notifications.show(
      102,
      'Обновление v$version загружено',
      'Нажмите, чтобы установить',
      details,
      payload: 'install_update',
    );
  }

  Future<void> cancelDownloadNotification() async {
    if (kIsWeb) return;
    await _notifications.cancel(101);
  }

  Future<void> showUpdateAvailableOnStartup(String version) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'daypay_update_channel',
      'Обновления',
      channelDescription: 'Уведомления о новых версиях приложения',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
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

    await _notifications.show(
      103,
      'Доступна новая версия v$version',
      'Откройте настройки, чтобы обновить',
      details,
      payload: 'update',
    );
  }
}
