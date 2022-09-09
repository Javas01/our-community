import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_ummah/components/comment_component.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:our_ummah/models/comment_model.dart';
import 'package:provider/provider.dart';

class PostComments extends StatefulWidget {
  const PostComments({
    Key? key,
    required this.users,
    required this.postId,
  }) : super(key: key);

  final List<AppUser> users;
  final String postId;

  @override
  State<PostComments> createState() => _PostCommentsState();
}

class _PostCommentsState extends State<PostComments> {
  late final Stream<QuerySnapshot<Comment>> _commentsStream;

  @override
  void initState() {
    _commentsStream = FirebaseFirestore.instance
        .collection('Communities')
        .doc(Provider.of<Community>(context, listen: false).id)
        .collection('Posts')
        .doc(widget.postId)
        .collection('Comments')
        .orderBy('timestamp', descending: true)
        .withConverter(
          fromFirestore: commentFromFirestore,
          toFirestore: commentToFirestore,
        )
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currUser = widget.users.firstWhere(
        (user) => user.id == FirebaseAuth.instance.currentUser!.uid);
    return Flexible(
        child: StreamBuilder<QuerySnapshot<Comment>>(
      stream: _commentsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final comments =
            snapshot.data!.docs.map((commentDoc) => commentDoc.data()).toList();

        // filter comments by no parent comments
        final filteredComments = comments.where((comment) => !comment.isReply);

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
            users: widget.users,
          );
        }).toList());
      },
    ));
  }
}
