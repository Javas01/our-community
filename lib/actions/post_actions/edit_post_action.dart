import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void editPost(
  String title,
  String description,
  String type,
  String tag,
  BuildContext context,
  String postId,
  CollectionReference posts,
  GlobalKey<FormState> formKey,
  VoidCallback onSuccess,
) async {
  if (formKey.currentState!.validate()) {
    try {
      await posts.doc(postId).update({
        'title': title,
        'description': description,
        'type': type,
        'tags': [tag],
        'lastEdited': Timestamp.now(),
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
