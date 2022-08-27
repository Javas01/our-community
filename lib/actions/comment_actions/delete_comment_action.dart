import 'package:cloud_firestore/cloud_firestore.dart';

void deleteComment(String postId, String commentId) async {
  DocumentReference comment = FirebaseFirestore.instance
      .collection('Communities')
      .doc('')
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
