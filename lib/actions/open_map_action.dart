import 'dart:io';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> openMap(String location) async {
  String query = Uri.encodeComponent(location);
  String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
  String appleUrl = 'https://maps.apple.com/?q=$query';

  if (Platform.isAndroid) {
    if (await canLaunchUrlString(googleUrl)) {
      await launchUrlString(googleUrl);
    } else {
      throw 'Could not launch url';
    }
  } else if (Platform.isIOS) {
    if (await canLaunchUrlString(appleUrl)) {
      await launchUrlString(appleUrl);
    } else {
      throw 'Could not launch url';
    }
  }
}
