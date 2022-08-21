import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_community/config.dart' show communityCode;
import 'package:our_community/models/comment_model.dart';
import 'package:our_community/models/post_model.dart';

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
  final commentsRef = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
      .collection('Posts')
      .doc(postId)
      .collection('Comments')
      .withConverter(
        fromFirestore: commentFromFirestore,
        toFirestore: commentToFirestore,
      );
  final postsRef = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
      .collection('Posts')
      .doc(postId)
      .withConverter(
        fromFirestore: postFromFirestore,
        toFirestore: postToFirestore,
      );

  try {
    final newComment = Comment(
      createdBy: userId,
      text: commentController.text,
      isReply: isReply,
      timestamp: Timestamp.now(),
    );

    if (isReply) {
      final newCommentDoc = await commentsRef.add(newComment);
      final newReplies = [...parentCommentReplies, newCommentDoc.id];
      commentsRef.doc(parentCommentId).update({'replies': newReplies});
    } else {
      commentsRef.add(newComment);
    }

    postsRef.update({'hasSeen': []});
  } catch (e) {
    Future.error('Failed to add comment: $e');
  }
}
