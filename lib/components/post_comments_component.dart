import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'comment_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostComments extends StatelessWidget {
  late Stream<QuerySnapshot> _commentsStream;

  PostComments({
    Key? key,
    required this.postId,
    required this.unFocus,
  }) : super(key: key) {
    _commentsStream = FirebaseFirestore.instance
        .collection('Communities')
        .doc('ATLMasjid')
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .snapshots();
  }

  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Users').snapshots();
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
            final List<QueryDocumentSnapshot> users = usersSnapshot.data!.docs;

            final currUser = users
                .firstWhere(
                    (e) => e.id == FirebaseAuth.instance.currentUser!.uid)
                .data() as Map;

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
                final commentDocs = snapshot.data!.docs;

                List<QueryDocumentSnapshot> filteredComments =
                    commentDocs.where(
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
                    creatorId: data['createdBy']['id'],
                    isDeleted: data['isDeleted'] ?? false,
                    isRemoved: data['isRemoved'] ?? false,
                    timestamp: data['timestamp'] ??
                        Timestamp.fromMicrosecondsSinceEpoch(1660312350),
                    commentText: data['text'],
                    replies: replyComments,
                    postId: postId,
                    commentId: document.id,
                    unFocus: unFocus,
                    blockedUsers: currUser['blockedUsers'] ?? [],
                  );
                }).toList());
              },
            );
          }),
    );
  }
}
