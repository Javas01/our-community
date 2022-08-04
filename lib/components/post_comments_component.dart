import 'package:flutter/material.dart';
import 'comment_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostComments extends StatelessWidget {
  const PostComments({
    Key? key,
    required this.commentsStream,
  }) : super(key: key);

  final Stream<QuerySnapshot> commentsStream;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 400,
        child: StreamBuilder<QuerySnapshot>(
          stream: commentsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }

            return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return UserComment(
                  firstName: data['createdBy']['firstName'] ?? '',
                  lastName: data['createdBy']['lastName'] ?? '',
                  commentText: data['text']);
            }).toList());
          },
        ));
  }
}
