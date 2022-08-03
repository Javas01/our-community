import 'package:flutter/material.dart';

class RegistrationSubtext extends StatelessWidget {
  const RegistrationSubtext({
    Key? key,
    required this.text,
    required this.linkText,
    this.screen,
  }) : super(key: key);
  final String text, linkText;
  final dynamic screen;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Text(text),
      GestureDetector(
          onTap: () {
            screen != null
                ? Navigator.push(
                    context, MaterialPageRoute(builder: ((context) => screen)))
                : Navigator.of(context).pop();
          },
          child: Text(linkText,
              style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)))
    ]);
  }
}
