import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_community/config.dart' show communityCode;

void addComment(
  BuildContext context,
  TextEditingController commentController,
  String userId,
  String postId,
) async {
  if (commentController.text == '') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment cant be empty')),
    );
    return;
  }

  final comments = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
      .collection('Posts')
      .doc(postId)
      .collection('Comments');

  try {
    await comments.add({
      'text': commentController.text,
      'isReply': false,
      'createdBy': userId,
      'timestamp': Timestamp.now(),
    });
    commentController.clear();
  } catch (e) {
    commentController.clear();
    Future.error('Failed to add comment: $e');
  }
}
