import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_community/config.dart';
import 'package:our_community/models/post_model.dart';

void createPost(
  String title,
  String description,
  String type,
  String tag,
  BuildContext context,
  String userId,
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
      final newPost = Post(
        createdBy: userId,
        title: title,
        description: description,
        tags: [tag],
        type: type,
        timestamp: Timestamp.now(),
      );
      posts.add(newPost);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create post: $e'),
        ),
      );
    }
  }
}
