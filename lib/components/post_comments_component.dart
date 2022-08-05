import 'package:flutter/material.dart';
import 'comment_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostComments extends StatelessWidget {
  const PostComments({
    Key? key,
    required this.commentsStream,
    required this.postId,
    required this.setParentComment,
  }) : super(key: key);

  final Stream<QuerySnapshot> commentsStream;
  final String postId;
  final Function setParentComment;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: commentsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          List<QueryDocumentSnapshot> filteredComments =
              snapshot.data!.docs.where(
            (DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return !data['isReply'];
            },
          ).toList();

          return ListView(
              children: filteredComments.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

            List replies = data['replies'] ?? [];
            List replyComments = snapshot.data!.docs
                .where((doc) => replies.contains(doc.id))
                .map((DocumentSnapshot document) {
              Map<String, dynamic> replyData =
                  document.data()! as Map<String, dynamic>;

              return {...replyData, 'commentId': document.id};
            }).toList();

            return UserComment(
              key: GlobalKey(),
              firstName: data['createdBy']['firstName'] ?? '',
              lastName: data['createdBy']['lastName'] ?? '',
              creatorId: data['createdBy']['id'] ?? '',
              commentText: data['text'],
              replies: replyComments,
              postId: postId,
              setParentComment: setParentComment,
              commentId: document.id,
            );
          }).toList());
        },
      ),
    );
  }
}
