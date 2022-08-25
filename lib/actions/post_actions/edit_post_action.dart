import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/config.dart';
import 'package:our_ummah/models/post_model.dart';

void editPost(
  String title,
  String description,
  String type,
  String tag,
  BuildContext context,
  String postId,
  GlobalKey<FormState> formKey,
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
      posts.doc(postId).update({
        'title': title,
        'description': description,
        'type': type,
        'tags': [tag],
        'lastEdited': Timestamp.now(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to edit post: $e'),
        ),
      );
    }
  }
}
