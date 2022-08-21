import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void flagContent(
  String? userEmail,
  String userId,
  String? postId,
  String? commentId,
  VoidCallback onSuccess,
) async {
  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  try {
    await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': 'RSpCM_xJwri5l9DjMIGAy',
          'service_id': 'service_ydieaun',
          'template_id': 'template_ejdq7ar',
          'user_id': 'zycID_4Z1ijq9fgbW',
          'template_params': {
            'user_email': userEmail,
            'content_type': commentId != null ? 'comment' : 'post',
            'user_id': userId,
            'post_id': postId,
            'comment_id': commentId,
          }
        }));

    onSuccess.call();
  } catch (e) {
    Future.error(e);
  }
}
