import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

void updateProfile(
  BuildContext context,
  TextEditingController firstName,
  TextEditingController lastName,
  File? imageSrc,
  VoidCallback onSuccess,
) async {
  if (imageSrc == null && firstName.text.isEmpty && lastName.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You havent changed anything'),
      ),
    );
    return;
  }
  final currUserId = FirebaseAuth.instance.currentUser!.uid;
  final profilePicRef =
      FirebaseStorage.instance.ref('profilePics').child(currUserId);

  try {
    String profilePicUrl = '';
    if (imageSrc != null) {
      await profilePicRef.putFile(imageSrc);
      profilePicUrl = await profilePicRef.getDownloadURL();
    }
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currUserId)
        .update({
      ...firstName.text.isNotEmpty ? ({'firstName': firstName.text}) : {},
      ...lastName.text.isNotEmpty ? ({'lastName': lastName.text}) : {},
      ...profilePicUrl.isNotEmpty ? ({'profilePicUrl': profilePicUrl}) : {},
    });

    firstName.clear();
    lastName.clear();
    onSuccess.call();
  } catch (e) {
    Future.error(e);
  }
}
