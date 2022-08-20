import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_community/config.dart';
import 'package:our_community/models/post_model.dart';

void editPost(
  String title,
  String description,
  String type,
  String tag,
  BuildContext context,
  String postId,
  GlobalKey<FormState> formKey,
  VoidCallback onSuccess,
) async {
  if (formKey.currentState!.validate()) {
    final posts = FirebaseFirestore.instance
        .collection('Communities')
        .doc(communityCode)
        .collection('Posts')
        .withConverter(
          fromFirestore: postFromFirestore,
          toFirestore: postToFirestore,
        );

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
