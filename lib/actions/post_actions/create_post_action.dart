import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void createPost(
  String title,
  String description,
  String type,
  String tag,
  BuildContext context,
  String userId,
  CollectionReference posts,
  GlobalKey<FormState> formKey,
  VoidCallback onSuccess,
) async {
  if (formKey.currentState!.validate()) {
    try {
      await posts.add({
        'title': title,
        'description': description,
        'createdBy': userId,
        'type': type,
        'tags': [tag],
        'timestamp': Timestamp.now(),
      });
      onSuccess.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create post'),
        ),
      );
      Future.error(e);
    }
  }
}
