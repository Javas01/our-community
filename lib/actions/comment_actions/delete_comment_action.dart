import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_community/config.dart' show communityCode;

void deleteComment(String postId, String commentId) async {
  DocumentReference comment = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
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
