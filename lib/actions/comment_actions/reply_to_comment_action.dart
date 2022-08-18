import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config.dart' show communityCode;

void replyToComment(
  BuildContext context,
  TextEditingController commentController,
  String postId,
  String userId,
  String commentId,
  List<String>? replies,
) async {
  if (commentController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reply cant be empty')),
    );
    return Future.value();
  }

  CollectionReference comments = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
      .collection('Posts')
      .doc(postId)
      .collection('Comments');

  try {
    final newCommentDoc = await comments.add({
      'text': commentController.text,
      'isReply': true,
      'createdBy': userId,
      'timestamp': Timestamp.now(),
    });

    DocumentReference parentCommentRef = comments.doc(commentId);

    List parentCommentReplies = replies ?? [];
    List newReplies = [...parentCommentReplies, newCommentDoc.id];

    parentCommentRef.update({'replies': newReplies});
    commentController.clear();
  } catch (e) {
    Future.error("Failed to add comment: $e");
    commentController.clear();
  }
}
