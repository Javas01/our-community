import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_community/config.dart' show communityCode;
import 'package:our_community/models/post_model.dart';

void vote(
  String voteType,
  String postId,
) async {
  final auth = FirebaseAuth.instance;
  final postRef = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
      .collection('Posts')
      .doc(postId)
      .withConverter(
        fromFirestore: postFromFirestore,
        toFirestore: postToFirestore,
      );

  final postDoc = await postRef.get();
  final post = postDoc.data()!;

  switch (voteType) {
    case 'up':
      {
        post.upVotes.add(auth.currentUser!.uid);
        post.downVotes.remove(auth.currentUser!.uid);
      }
      break;
    case 'down':
      {
        post.downVotes.add(auth.currentUser!.uid);
        post.upVotes.remove(auth.currentUser!.uid);
      }
      break;
    // default is remove vote
    default:
      {
        post.upVotes.remove(auth.currentUser!.uid);
        post.downVotes.remove(auth.currentUser!.uid);
      }
      break;
  }
  try {
    postRef.update({
      'upVotes': post.upVotes,
      'downVotes': post.downVotes,
    });
  } catch (e) {
    Future.error(e);
  }
}
