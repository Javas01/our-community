import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserComment extends StatefulWidget {
  const UserComment({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.creatorId,
    required this.commentText,
    required this.replies,
    required this.postId,
    required this.setParentComment,
    required this.commentId,
  }) : super(key: key);
  final String firstName, lastName, creatorId, commentText, postId, commentId;
  final List replies;
  final Function setParentComment;

  @override
  State<UserComment> createState() => _UserCommentState();
}

class _UserCommentState extends State<UserComment> {
  bool _isSelected = false;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final isCreator = userId == widget.creatorId;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            _isSelected = true;
          });
        },
        onTap: () {
          setState(() {
            _isSelected = false;
          });
        },
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_circle),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.firstName} ${widget.lastName}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(widget.commentText),
                      if (_isSelected)
                        Row(
                          children: [
                            if (isCreator)
                              const Icon(
                                Icons.delete_rounded,
                                size: 17,
                              ),
                            GestureDetector(
                              onTap: () {
                                widget.setParentComment(widget.commentId);
                              },
                              child: const Icon(
                                Icons.reply_rounded,
                                size: 18,
                              ),
                            )
                          ],
                        )
                    ],
                  ),
                ),
              ],
            ),
            ...widget.replies.map((reply) {
              List replies = reply['replies'] ?? [];
              var comments = FirebaseFirestore.instance
                  .collection('Posts')
                  .doc(widget.postId)
                  .collection('Comments')
                  .get();

              Future<List> getReplyComments() {
                return comments.then((data) {
                  List replyComments = data.docs
                      .where((doc) => replies.contains(doc.id))
                      .map((DocumentSnapshot document) {
                    Map<String, dynamic> replyData =
                        document.data()! as Map<String, dynamic>;

                    return {...replyData, 'commentId': document.id};
                  }).toList();
                  return replyComments;
                });
              }

              return FutureBuilder<List>(
                  future: getReplyComments(),
                  initialData: const [],
                  builder: (BuildContext context, AsyncSnapshot<List> data) {
                    if (data.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (data.connectionState == ConnectionState.waiting) {
                      return const Text("Loading");
                    }
                    List newReplies = data.data ?? [];

                    return Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              left: BorderSide(
                        width: 1,
                        color: Colors.blueAccent,
                      ))),
                      child: UserComment(
                        key: GlobalKey(),
                        firstName: reply['createdBy']['firstName'],
                        lastName: reply['createdBy']['lastName'],
                        creatorId: reply['createdBy']['id'],
                        commentText: reply['text'],
                        replies: newReplies,
                        postId: widget.postId,
                        setParentComment: widget.setParentComment,
                        commentId: reply['commentId'],
                      ),
                    );
                  });
            }),
          ],
        ),
      ),
    );
  }
}
