import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> registerPushNotificationHandler() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@drawable/ic_stat_notification',
    );
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(
          "\nForground message notification: ${message.notification?.title} "
          "${message.notification?.body}");
      debugPrint("Forground message data: ${message.data.toString()}");

      RemoteNotification? notification = message.notification;
      String? type = message.data['type'];

      // if (type == NotificationType.videoConverted) {
      //   return;
      // }

      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              color: Colors.amber,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        debugPrint("Message Clicked: ${message.data.toString()}");
        int? profileId = message.data['profile_id'] != null
            ? int.parse('${message.data['profile_id']}')
            : null;
        if (profileId != null) {
          // navigationService.navigateTo(
          //   Routes.userProfileView,
          //   arguments: UserProfileViewArguments(
          //     profile: MatchedProfile(
          //       id: profileId,
          //       medias: [],
          //       visitedIds: [],
          //     ),
          //   ),
          // );
        }
      },
    );
    debugPrint("Notification Service Registered");
  }

  void onDidReceiveNotificationResponse(NotificationResponse data) {
    // debugPrint("Local Message Clicked: $data");
    if (data.payload?.isNotEmpty ?? false) {
      Map<String, dynamic> payload = jsonDecode(data.payload!);
      debugPrint("Local Message Clicked: $payload");
      int? profileId = payload['profile_id'] != null
          ? int.parse('${payload['profile_id']}')
          : null;
      if (profileId != null) {
        // navigationService.navigateTo(
        //   Routes.userProfileView,
        //   arguments: UserProfileViewArguments(
        //     profile: MatchedProfile(
        //       id: profileId,
        //       medias: [],
        //       visitedIds: [],
        //     ),
        //   ),
        // );
      }
    }
  }

  Future<String> getDeviceToken() async {
    String token = await messaging.getToken() ?? "";
    debugPrint('FirebaseToken: $token');
    return token;
  }
}
