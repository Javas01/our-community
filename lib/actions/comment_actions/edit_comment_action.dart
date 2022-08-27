import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:provider/provider.dart';

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
      .doc(Provider.of<Community>(context, listen: false).id)
      .collection('Posts')
      .doc(postId)
      .collection('Comments')
      .doc(commentId);
  try {
    comment.update(({
      'text': controller.text,
      'lastEdited': Timestamp.now(),
    }));
  } catch (e) {
    Future.error(e);
  }
}
