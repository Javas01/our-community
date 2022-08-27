import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:provider/provider.dart';

void deleteComment(
    String postId, String commentId, BuildContext context) async {
  DocumentReference comment = FirebaseFirestore.instance
      .collection('Communities')
      .doc(Provider.of<Community>(context, listen: false).id)
      .collection('Posts')
      .doc(postId)
      .collection('Comments')
      .doc(commentId);
  try {
    comment.update(({
      'isDeleted': true,
    }));
  } catch (e) {
    Future.error(e);
  }
}
