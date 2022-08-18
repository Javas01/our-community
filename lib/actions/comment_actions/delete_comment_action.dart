import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config.dart' show communityCode;

void deleteComment(String postId, String commentId) async {
  DocumentReference comment = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
      .collection('Posts')
      .doc(postId)
      .collection('Comments')
      .doc(commentId);
  try {
    await comment.update(({
      'isDeleted': true,
    }));
  } catch (e) {
    Future.error(e);
  }
}
