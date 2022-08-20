import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_community/components/comment_component.dart';
import 'package:our_community/models/user_model.dart';
import 'package:our_community/models/comment_model.dart';
import 'package:our_community/config.dart' show communityCode;

class PostComments extends StatefulWidget {
  const PostComments({
    Key? key,
    required this.postId,
  }) : super(key: key);

  final String postId;

  @override
  State<PostComments> createState() => _PostCommentsState();
}

class _PostCommentsState extends State<PostComments> {
  final _usersStream = FirebaseFirestore.instance
      .collection('Users')
      .withConverter(
        fromFirestore: userFromFirestore,
        toFirestore: userToFirestore,
      )
      .snapshots();

  late final Stream<QuerySnapshot<Comment>> _commentsStream;

  @override
  void initState() {
    _commentsStream = FirebaseFirestore.instance
        .collection('Communities')
        .doc(communityCode)
        .collection('Posts')
        .doc(widget.postId)
        .collection('Comments')
        .withConverter(
          fromFirestore: commentFromFirestore,
          toFirestore: commentToFirestore,
        )
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: StreamBuilder<QuerySnapshot<AppUser>>(
          stream: _usersStream,
          builder: (context, usersSnapshot) {
            if (usersSnapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (usersSnapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading');
            }
            final users = usersSnapshot.data!.docs
                .map((userDoc) => userDoc.data())
                .toList();

            final currUser = users.firstWhere(
                (user) => user.id == FirebaseAuth.instance.currentUser!.uid);

            return StreamBuilder<QuerySnapshot<Comment>>(
              stream: _commentsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading');
                }
                final comments = snapshot.data!.docs
                    .map((commentDoc) => commentDoc.data())
                    .toList();

                // filter comments by no parent comments
                final filteredComments =
                    comments.where((comment) => !comment.isReply);

                return ListView(
                    children: filteredComments.map((comment) {
                  final isUserBlocked =
                      currUser.blockedUsers.contains(comment.createdBy);
                  final replies = comment.replies;
                  final replyComments = comments
                      .where((comment) => replies.contains(comment.id))
                      .toList();

                  return UserComment(
                    key: GlobalKey(),
                    comment: comment,
                    comments: comments,
                    replies: replyComments,
                    postId: widget.postId,
                    blockedUsers: currUser.blockedUsers,
                    isUserBlocked: isUserBlocked,
                    users: users,
                  );
                }).toList());
              },
            );
          }),
    );
  }
}
