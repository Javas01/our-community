import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'comment_component.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';
import '../../config.dart' show communityCode;

class PostComments extends StatelessWidget {
  late Stream<QuerySnapshot> _commentsStream;

  PostComments({
    Key? key,
    required this.postId,
    required this.unFocus,
  }) : super(key: key) {
    _commentsStream = FirebaseFirestore.instance
        .collection('Communities')
        .doc(communityCode)
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .withConverter(
          fromFirestore: commentFromFirestore,
          toFirestore: commentToFirestore,
        )
        .snapshots();
  }

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('Users')
      .withConverter(
        fromFirestore: userFromFirestore,
        toFirestore: userToFirestore,
      )
      .snapshots();
  final String postId;
  final VoidCallback unFocus;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
          stream: _usersStream,
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> usersSnapshot) {
            if (usersSnapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (usersSnapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }
            final users = usersSnapshot.data!.docs
                .map((userDoc) => userDoc.data() as AppUser)
                .toList();

            final currUser = users.firstWhere(
                (user) => user.id == FirebaseAuth.instance.currentUser!.uid);

            return StreamBuilder<QuerySnapshot>(
              stream: _commentsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                }
                final comments = snapshot.data!.docs
                    .map((commentDoc) => commentDoc.data() as Comment)
                    .toList();

                // filter comments by no parent comments
                final filteredComments =
                    comments.where((comment) => !comment.isReply);

                return ListView(
                    children: filteredComments.map((comment) {
                  final replies = comment.replies ?? [];
                  final replyComments = comments
                      .where((comment) => replies.contains(comment.id))
                      .toList();

                  return UserComment(
                    key: GlobalKey(),
                    comment: comment,
                    comments: comments,
                    replies: replyComments,
                    postId: postId,
                    unFocus: unFocus,
                    blockedUsers: currUser.blockedUsers ?? [],
                  );
                }).toList());
              },
            );
          }),
    );
  }
}
