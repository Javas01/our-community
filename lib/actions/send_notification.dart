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
        'token':
            '9F7D4DD2260BB6B772C808084C2B78FC61D169A825710D8C591CDFADC2083B6C',
        // 'token': devices.first,
      }),
    );
  } catch (e) {
    print('Error: $e');
  }
}
