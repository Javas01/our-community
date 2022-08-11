import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_community/components/text_field_components.dart';

class UserComment extends StatefulWidget {
  const UserComment({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.creatorId,
    required this.commentText,
    required this.replies,
    required this.postId,
    required this.commentId,
    required this.unFocus,
  }) : super(key: key);
  final String firstName, lastName, creatorId, commentText, postId, commentId;
  final List replies;
  final VoidCallback unFocus;

  @override
  State<UserComment> createState() => _UserCommentState();
}

class _UserCommentState extends State<UserComment> {
  final firstName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[0];
  final lastName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[1];
  final userId = FirebaseAuth.instance.currentUser!.uid;

  TextEditingController commentController = TextEditingController();

  bool _isSelected = false;

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
          if (_isSelected) {
            widget.unFocus();
            setState(() {
              _isSelected = false;
            });
          }
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
                      Text(
                        widget.commentText,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_isSelected) ...{
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (isCreator)
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_rounded,
                                      color: Colors.red[700],
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Delete comment coming soon'),
                                        ),
                                      );
                                    },
                                  ),
                                Expanded(
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 300),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: CommentField(
                                            commentController:
                                                commentController,
                                            hintText: 'Reply to comment',
                                            unFocus: widget.unFocus,
                                            hasBorder: false,
                                            hintStyle:
                                                const TextStyle(height: 1.5),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: const Size(30, 30),
                                            shape: const CircleBorder(),
                                          ),
                                          onPressed: () {
                                            widget.unFocus();
                                            replyToComment(
                                                commentController.text);
                                          },
                                          child:
                                              const Icon(Icons.reply_rounded),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      }
                    ],
                  ),
                ),
              ],
            ),
            ...widget.replies.map((reply) {
              List replies = reply['replies'] ?? [];
              var comments = FirebaseFirestore.instance
                  .collection('Communities')
                  .doc('ATLMasjid')
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

                    if (data.connectionState == ConnectionState.waiting) {}
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
                        commentId: reply['commentId'],
                        unFocus: widget.unFocus,
                      ),
                    );
                  });
            }),
          ],
        ),
      ),
    );
  }

  Future<void> replyToComment(String text) {
    if (text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply cant be empty')),
      );
      return Future.value();
    }
    commentController.text = '';

    CollectionReference comments = FirebaseFirestore.instance
        .collection('Communities')
        .doc('ATLMasjid')
        .collection('Posts')
        .doc(widget.postId)
        .collection('Comments');

    return comments.add({
      'text': text,
      'isReply': true,
      'createdBy': {
        'firstName': firstName,
        'lastName': lastName,
        'id': userId,
      },
      'timestamp': FieldValue.serverTimestamp(),
    }).then((doc) {
      DocumentReference parentComment = comments.doc(widget.commentId);
      parentComment.get().then((document) {
        var parentCommentData = document.data()! as Map<String, dynamic>;
        List parentCommentReplies = parentCommentData['replies'] ?? [];
        List newReplies = [...parentCommentReplies, doc.id];

        parentComment.update({'replies': newReplies});
      });
    }).catchError((error) => print("Failed to add comment: $error"));
  }
}
