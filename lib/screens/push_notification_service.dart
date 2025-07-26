import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

Future<void> sendPushNotification(String token, String message) async {
  final serviceAccount = await rootBundle.loadString('assets/birdifyy-f4495-firebase-adminsdk-fbsvc-3dd46cb1fd.json');
  final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

  const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  final authClient = await clientViaServiceAccount(credentials, scopes);

  final projectId = json.decode(serviceAccount)['project_id'];
  final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

  final body = json.encode({
    "message": {
      "token": token,
      "notification": {
        "title": "New Message",
        "body": message,
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "message": message,
      },
    }
  });

  final response = await authClient.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  print('🔔 Notification sent: ${response.statusCode} ${response.body}');
}
