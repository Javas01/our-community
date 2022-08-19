import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImage(VoidCallback onError) async {
  try {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) {
      onError.call();
      return null;
    }

    return File(image.path);
  } catch (e) {
    onError.call();
    return null;
  }
}
