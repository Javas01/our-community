import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// const host = 'http://localhost:3000';
const host = 'https://push-notification-service.onrender.com';

Future<void> sendNotification(
  String title,
  String subtitle,
  String body,
  List<String> devices,
) async {
  try {
    final url = Uri.parse('$host/new-comment');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'subtitle': subtitle,
        'body': body,
        'devices': devices,
      }),
    );
  } catch (e) {
    debugPrint(e.toString());
  }
}
