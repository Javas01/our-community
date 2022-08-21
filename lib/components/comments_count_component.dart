import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_community/models/comment_model.dart';

class CommentCount extends StatelessWidget {
  const CommentCount({Key? key, this.docs = const [], this.hasSeen = true})
      : super(key: key);

  final List<QueryDocumentSnapshot<Comment>> docs;
  final bool hasSeen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          docs.length.toString(),
          style: TextStyle(
            color: hasSeen ? null : Colors.lightBlueAccent,
          ),
        ),
        const SizedBox(width: 5),
        Icon(
          Icons.chat_outlined,
          size: 20,
          color: hasSeen ? null : Colors.lightBlueAccent,
        ),
      ],
    );
  }
}
