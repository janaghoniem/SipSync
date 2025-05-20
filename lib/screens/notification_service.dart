import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Track if initialized
  bool _isInitialized = false;

  // Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Android setup
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS setup
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined settings for both platforms
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification response received: ${response.payload}');
      },
    );

    // Request permissions specifically for iOS
    await _requestPermissions();

    _isInitialized = true;
    debugPrint('NotificationService initialized successfully');
  }

  // Request permission (important for iOS)
  Future<void> _requestPermissions() async {
    // For iOS
    final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (plugin != null) {
      await plugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('iOS permissions requested');
    }

    // For macOS (if your app supports it)
    final macOSPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();

    if (macOSPlugin != null) {
      await macOSPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('macOS permissions requested');
    }
  }

  // Test notification with more debugging info
  Future<void> testNotification() async {
    debugPrint('⚠️ Test notification requested');

    // Ensure initialized
    if (!_isInitialized) {
      debugPrint(
          '⚠️ Notification service not initialized. Initializing now...');
      await initialize();
    }

    // Verify permissions on iOS
    if (_notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>() !=
        null) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      debugPrint('⚠️ iOS permissions granted: $granted');
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'water_reminder_channel',
        'Water Reminder',
        channelDescription: 'Channel for water intake reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: 'water-reminder-thread',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      // Show test notification immediately
      await _notificationsPlugin.show(
        999, // Unique ID
        'Test Notification',
        'This is a test notification from H2OClock!',
        platformChannelSpecifics,
        payload: 'test_notification',
      );

      debugPrint('⚠️ Test notification sent successfully');
    } catch (e) {
      debugPrint('⚠️ Error sending notification: $e');
    }
  }

  // Schedule periodic notifications
  Future<void> schedulePeriodicNotifications({
    required String reminderFrequency,
    required double goal,
    required double currentIntake,
  }) async {
    // Ensure initialized
    if (!_isInitialized) {
      await initialize();
    }

    // Cancel any existing notifications
    await _notificationsPlugin.cancelAll();
    debugPrint('Previous notifications canceled');

    // Parse reminder frequency to minutes
    int minutes = _parseReminderFrequency(reminderFrequency);
    debugPrint('Reminder frequency: $minutes minutes');

    // Setup notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'water_reminder_channel',
      'Water Reminder',
      channelDescription: 'Channel for water intake reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      threadIdentifier: 'water-reminder-thread',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    // Get creative notification message
    final message = _getCreativeMessage(currentIntake, goal);

    // Show first notification immediately
    await _notificationsPlugin.show(
      0,
      message['title']!,
      message['body']!,
      platformChannelSpecifics,
      payload: 'immediate_reminder',
    );
    debugPrint('Immediate notification sent');

    // Schedule periodic notifications if minutes > 0
    if (minutes > 0) {
      try {
        // Calculate the notification time
        final scheduledTime =
            tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));

        // Schedule the notification
        await _notificationsPlugin.zonedSchedule(
          1, // Notification ID
          'Water Reminder',
          'Time to hydrate! Your body needs water.',
          scheduledTime,
          const NotificationDetails(
            // Android settings
            // android: AndroidNotificationDetails(
            //   'water_reminder_channel', // Channel ID
            //   'Water Reminders', // Channel Name
            //   importance: Importance.high,
            //   priority: Priority.high,
            //   allowWhileIdle: true, // Works in Doze mode (Android only)
            // ),
            // iOS settings
            iOS: DarwinNotificationDetails(
              presentAlert: true, // Show alert
              presentBadge: true, // Show badge
              presentSound: true, // Play sound
            ),
          ),
          androidScheduleMode:
              AndroidScheduleMode.exactAllowWhileIdle, // Android only
          payload: 'scheduled_reminder',
        );

        debugPrint(
            'Scheduled notification for $minutes minutes from now at ${scheduledTime.toString()}');
      } catch (e) {
        debugPrint('Error scheduling notification: $e');
      }
    }
  }

  Map<String, String> _getCreativeMessage(double currentIntake, double goal) {
    final random = Random();
    final percentage = currentIntake / goal;

    if (currentIntake == 0) {
      final titles = [
        "Let's get started!",
        "Time to hydrate!",
        "Your body is waiting for water!"
      ];
      final bodies = [
        "You haven't had any water today. Your first sip is the most important!",
        "Even a small glass can kickstart your metabolism!",
        "Your plants need water, and so do you!"
      ];
      return {
        'title': titles[random.nextInt(titles.length)],
        'body': bodies[random.nextInt(bodies.length)],
      };
    } else if (percentage < 0.25) {
      final titles = [
        "Small sips lead to big results!",
        "Hydration in progress!",
        "You're on your way!"
      ];
      final bodies = [
        "Great start! Keep those sips coming!",
        "Your body is starting to thank you!",
        "Rome wasn't built in a day, and neither is perfect hydration!"
      ];
      return {
        'title': titles[random.nextInt(titles.length)],
        'body': bodies[random.nextInt(bodies.length)],
      };
    } else if (percentage < 0.5) {
      final titles = [
        "You're making progress!",
        "Hydration half-time!",
        "Keep the flow going!"
      ];
      final bodies = [
        "You're about halfway to your daily goal. Stay hydrated!",
        "You've drunk ${currentIntake.toInt()}ml so far. Keep it up!",
        "Your cells are cheering for more water!"
      ];
      return {
        'title': titles[random.nextInt(titles.length)],
        'body': bodies[random.nextInt(bodies.length)],
      };
    } else if (percentage < 0.75) {
      final titles = [
        "Keep it up!",
        "Hydration superstar!",
        "You're in the zone!"
      ];
      final bodies = [
        "You're doing great! Just a little more to reach your goal.",
        "Your body is loving this! ${(goal - currentIntake).toInt()}ml to go!",
        "Did you know water helps your brain work better? Keep drinking!"
      ];
      return {
        'title': titles[random.nextInt(titles.length)],
        'body': bodies[random.nextInt(bodies.length)],
      };
    } else if (percentage < 1) {
      final titles = [
        "Almost there!",
        "Final stretch!",
        "Hydration victory is near!"
      ];
      final bodies = [
        "You're so close to reaching your daily water intake goal!",
        "Just ${(goal - currentIntake).toInt()}ml left - you've got this!",
        "Your future hydrated self thanks you!"
      ];
      return {
        'title': titles[random.nextInt(titles.length)],
        'body': bodies[random.nextInt(bodies.length)],
      };
    } else {
      final titles = [
        "Hydration Champion!",
        "Goal achieved!",
        "Water Warrior!"
      ];
      final bodies = [
        "You've reached your goal! But don't stop now, keep hydrating!",
        "Amazing! You've drunk ${currentIntake.toInt()}ml today!",
        "You're crushing it! Consider drinking a bit more for extra benefits!"
      ];
      return {
        'title': titles[random.nextInt(titles.length)],
        'body': bodies[random.nextInt(bodies.length)],
      };
    }
  }

  int _parseReminderFrequency(String frequency) {
    if (frequency.contains('min')) {
      return int.parse(frequency.replaceAll(' min', ''));
    } else if (frequency.contains('hour')) {
      return int.parse(frequency.replaceAll(' hour', '')) * 60;
    }
    return 30; // Default to 30 minutes
  }
}
