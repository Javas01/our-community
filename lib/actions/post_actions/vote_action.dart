import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:provider/provider.dart';

void vote(
  String voteType,
  String postId,
  BuildContext context,
) async {
  final auth = FirebaseAuth.instance;
  final postRef = FirebaseFirestore.instance
      .collection('Communities')
      .doc(Provider.of<Community>(context, listen: false).id)
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
