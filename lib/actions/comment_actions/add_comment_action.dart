import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_ummah/actions/send_notification.dart';
import 'package:our_ummah/models/comment_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:provider/provider.dart';

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
      .doc(Provider.of<Community>(context, listen: false).id)
      .collection('Posts')
      .doc(postId)
      .collection('Comments')
      .withConverter(
        fromFirestore: commentFromFirestore,
        toFirestore: commentToFirestore,
      );
  final postsRef = FirebaseFirestore.instance
      .collection('Communities')
      .doc(Provider.of<Community>(context, listen: false).id)
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

      // Send notification to the user who created the parent comment
      final parentComment = await commentsRef.doc(parentCommentId).get();
      final parentCommentData = parentComment.data();

      final parentCommentCreator = await FirebaseFirestore.instance
          .collection('Users')
          .doc(parentCommentData!.createdBy)
          .withConverter(
              fromFirestore: userFromFirestore, toFirestore: userToFirestore)
          .get();
      final parentCommentCreatorData = parentCommentCreator.data();

      if (parentCommentData.createdBy != userId) {
        await sendNotification(
          'Your comment has a new reply',
          // ignore: use_build_context_synchronously
          Provider.of<Community>(context, listen: false).name,
          newComment.text,
          parentCommentCreatorData!.tokens,
        );
      }
    } else {
      commentsRef.add(newComment);

      // Send notification to the user who created the post
      final post = await postsRef.get();
      final postData = post.data();

      final postCreator = await FirebaseFirestore.instance
          .collection('Users')
          .doc(postData!.createdBy)
          .withConverter(
              fromFirestore: userFromFirestore, toFirestore: userToFirestore)
          .get();
      final postCreatorData = postCreator.data();

      if (postData.createdBy != userId) {
        await sendNotification(
          'Your post has a new comment',
          // ignore: use_build_context_synchronously
          Provider.of<Community>(context, listen: false).name,
          newComment.text,
          postCreatorData!.tokens,
        );
      }
    }

    postsRef.update({'hasSeen': []});
  } catch (e) {
    Future.error('Failed to add comment: $e');
  }
}
