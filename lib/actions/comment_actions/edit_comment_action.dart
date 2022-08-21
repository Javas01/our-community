import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_community/config.dart' show communityCode;

Future<void> editComment(
  BuildContext context,
  String postId,
  String commentId,
  String oldText,
  TextEditingController controller,
) async {
  if (oldText == controller.text) return;

  DocumentReference comment = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
      .collection('Posts')
      .doc(postId)
      .collection('Comments')
      .doc(commentId);
  try {
    await comment.update(({
      'text': controller.text,
      'lastEdited': Timestamp.now(),
    }));
  } catch (e) {
    Future.error(e);
  }
}