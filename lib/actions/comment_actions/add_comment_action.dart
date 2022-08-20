import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_community/config.dart' show communityCode;
import 'package:our_community/models/comment_model.dart';

void addComment(
  BuildContext context,
  TextEditingController commentController,
  String postId,
  String userId,
  String parentCommentId,
  List<String> parentCommentReplies,
) async {
  if (commentController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reply cant be empty')),
    );
    return;
  }

  final isReply = parentCommentId.isNotEmpty;
  final comments = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
      .collection('Posts')
      .doc(postId)
      .collection('Comments')
      .withConverter(
        fromFirestore: commentFromFirestore,
        toFirestore: commentToFirestore,
      );

  try {
    final newComment = Comment(
      createdBy: userId,
      text: commentController.text,
      isReply: isReply,
      timestamp: Timestamp.now(),
    );
    final newCommentDoc = await comments.add(newComment);

    if (isReply) {
      final newReplies = [...parentCommentReplies, newCommentDoc.id];

      comments.doc(parentCommentId).update({'replies': newReplies});
    }

    commentController.clear();
  } catch (e) {
    Future.error('Failed to add comment: $e');
    commentController.clear();
  }
}
