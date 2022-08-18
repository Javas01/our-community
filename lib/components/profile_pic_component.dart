import 'dart:io';
import 'package:flutter/material.dart';

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    Key? key,
    this.url,
    this.image,
    required this.onTap,
    required this.radius,
    this.iconSize,
  }) : super(key: key);

  final String? url;
  final File? image;
  final void Function() onTap;
  final double radius;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: false
            ? CircleAvatar(
                backgroundImage: (image != null
                    ? FileImage(image!)
                    : NetworkImage(url!)) as ImageProvider,
                radius: radius,
              )
            : Icon(
                Icons.account_circle_rounded,
                size: iconSize,
              ));
  }
}
