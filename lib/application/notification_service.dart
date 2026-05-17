import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _showLocalNotification(message);
}

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

Future<void> _showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'studentlife_channel',
    'StudentLife',
    channelDescription: 'Notifications StudentLife',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const NotificationDetails details =
      NotificationDetails(android: androidDetails);

  await _localNotifications.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    message.notification?.title ?? 'StudentLife',
    message.notification?.body ?? '',
    details,
  );
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> init() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);

      await _localNotifications.initialize(initSettings);

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'studentlife_channel',
        'StudentLife',
        description: 'Notifications StudentLife',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _saveToken();

      _messaging.onTokenRefresh.listen(_updateToken);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      print('Notifications non disponibles : $e');
    }
  }

  static Future<void> _saveToken() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final token = await _messaging.getToken();
      if (token == null) return;

      await _db.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (e) {
      // Google Play Services non disponible sur cet appareil
      print('FCM non disponible : $e');
    }
  }

  static Future<void> _updateToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  static Future<void> sendNotificationToClub({
    required String clubId,
    required String title,
    required String body,
  }) async {
    final memberships = await _db
        .collection('memberships')
        .where('clubId', isEqualTo: clubId)
        .get();

    for (var m in memberships.docs) {
      final userId = m.data()['userId'];
      final notifRef = _db.collection('notifications').doc();
      await notifRef.set({
        'notifId': notifRef.id,
        'clubId': clubId,
        'userId': userId,
        'title': title,
        'body': body,
        'read': false,
        'sentAt': Timestamp.now(),
      });
    }

    final queueRef = _db.collection('notifications_queue').doc();
    await queueRef.set({
      'clubId': clubId,
      'title': title,
      'body': body,
      'sentAt': Timestamp.now(),
      'processed': false,
    });
  }
}
