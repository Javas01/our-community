import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendNotification(String message, List<String> devices) async {
  try {
    final url = Uri.parse('http://localhost:3000/new-comment');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'alert': message,
        'devices': devices,
      }),
    );
  } catch (e) {
    print('Error: $e');
  }
}
