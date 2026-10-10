import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Фоновый обработчик сообщений FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('Handling a background message: ${message.messageId}');
  }
}

/// Сервис для управления локальными и push-уведомлениями (FCM)
class NotificationService {
  static const int _dailyWeatherId = 1;
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    tz.initializeTimeZones();

    // 1. Инициализация локальных уведомлений
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localPlugin.initialize(initSettings);

    // 2. Инициализация Firebase Cloud Messaging (FCM)
    try {
      await _initFirebaseMessaging();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM init notice: $e');
      }
    }
  }

  Future<void> _initFirebaseMessaging() async {
    // Запрос разрешений на отправку push
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        debugPrint('Пользователь разрешил push-уведомления');
      }
    }

    // Получаем токен устройства для отправки персональных push
    try {
      _fcmToken = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('FCM Device Token: $_fcmToken');
      }
    } catch (_) {}

    // Слушаем входящие push-уведомления в foreground (когда приложение открыто)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        showImmediateNotification(
          title: notification.title ?? 'Weather & Outfit',
          body: notification.body ?? 'Проверьте погоду перед выходом',
        );
      }
    });

    // Устанавливаем фоновый обработчик
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> scheduleDailyWeatherNotification({
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _localPlugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localPlugin.zonedSchedule(
      _dailyWeatherId,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_weather',
          'Ежедневная погода',
          channelDescription: 'Ежедневное уведомление о погоде и одежде',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    await _localPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_update',
          'Обновление погоды',
          channelDescription: 'Текущая погода и рекомендации',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _localPlugin.cancelAll();
  }
}
