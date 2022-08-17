import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_community/components/text_field_components.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../config.dart' show communityCode;
import '../actions/block_user.dart';
import '../actions/unblock_user.dart';

class UserComment extends StatefulWidget {
  const UserComment({
    Key? key,
    required this.createdBy,
    required this.isDeleted,
    required this.isRemoved,
    required this.timestamp,
    required this.commentText,
    required this.replies,
    required this.postId,
    required this.commentId,
    required this.unFocus,
    required this.blockedUsers,
  }) : super(key: key);
  final String createdBy, commentText, postId, commentId;
  final List replies, blockedUsers;
  final VoidCallback unFocus;
  final bool isDeleted, isRemoved;
  final Timestamp timestamp;

  @override
  State<UserComment> createState() => _UserCommentState();
}

class _UserCommentState extends State<UserComment> {
  final firstName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[0];
  final lastName =
      FirebaseAuth.instance.currentUser!.displayName?.split(' ')[1];
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userEmail = FirebaseAuth.instance.currentUser!.email;

  TextEditingController commentController = TextEditingController();

  bool _isSelected = false;
  late bool _isUserBlocked;

  @override
  void initState() {
    _isUserBlocked = widget.blockedUsers.contains(widget.createdBy);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isCreator = userId == widget.createdBy;
    final commentDate = DateFormat('yyyy-MM-dd (hh:mm aa)').format(
        DateTime.fromMicrosecondsSinceEpoch(
            widget.timestamp.microsecondsSinceEpoch));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onLongPress: () {
          if (widget.isDeleted || widget.isRemoved) return;

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
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(widget.createdBy)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading");
                  }
                  final Map commentCreator = snapshot.data!.data() as Map;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: (() {
                          showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                title: Column(
                                  children: [
                                    commentCreator['profilePicUrl'] != null
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              commentCreator['profilePicUrl'],
                                            ),
                                            radius: 70,
                                          )
                                        : const Icon(
                                            Icons.account_circle,
                                            size: 100,
                                          ),
                                    Center(
                                      child: Text(
                                        '${commentCreator['firstName']} ${commentCreator['lastName']}',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: !isCreator
                                    ? [
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _isUserBlocked
                                              ? unBlock(
                                                  widget.createdBy, context,
                                                  () {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'user unblocked successfully'),
                                                    ),
                                                  );
                                                })
                                              : blockUser(
                                                  context, widget.createdBy,
                                                  () {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'user blocked successfully'),
                                                    ),
                                                  );
                                                }),
                                          style: ButtonStyle(
                                            backgroundColor: _isUserBlocked
                                                ? null
                                                : MaterialStateProperty.all(
                                                    Colors.red),
                                          ),
                                          child: _isUserBlocked
                                              ? const Text('Unblock')
                                              : const Text('Block'),
                                        ),
                                      ]
                                    : [],
                                actionsAlignment: MainAxisAlignment.center,
                              );
                            }),
                          );
                        }),
                        child: commentCreator['profilePicUrl'] != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  commentCreator['profilePicUrl'],
                                ),
                                radius: 10,
                              )
                            : const Icon(
                                Icons.account_circle,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.isDeleted ||
                                    widget.isRemoved ||
                                    _isUserBlocked
                                ? Text(
                                    widget.isDeleted
                                        ? 'Comment deleted by user'
                                        : widget.isRemoved
                                            ? 'Comment removed by moderator'
                                            : 'You have this user blocked',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                : Text(
                                    '${commentCreator['firstName']} ${commentCreator['lastName']} - $commentDate',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                            const SizedBox(height: 4),
                            if (widget.isDeleted == false &&
                                widget.isRemoved == false &&
                                _isUserBlocked == false)
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
                                      isCreator
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.delete_rounded,
                                                color: Colors.red[700],
                                                size: 30,
                                              ),
                                              onPressed: deleteComment,
                                            )
                                          : IconButton(
                                              icon: const Icon(
                                                Icons.flag,
                                                size: 30,
                                              ),
                                              onPressed: flagComment,
                                            ),
                                      Expanded(
                                        child: Container(
                                          constraints: const BoxConstraints(
                                              maxHeight: 300),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: CommentField(
                                                  commentController:
                                                      commentController,
                                                  hintText: 'Reply to comment',
                                                  unFocus: widget.unFocus,
                                                  hasBorder: false,
                                                  hintStyle: const TextStyle(
                                                      height: 1.5),
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
                                                child: const Icon(
                                                    Icons.reply_rounded),
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
                  );
                }),
            ...widget.replies.map((reply) {
              List replies = reply['replies'] ?? [];
              var comments = FirebaseFirestore.instance
                  .collection('Communities')
                  .doc(communityCode)
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
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                        width: 1,
                        color: Theme.of(context).appBarTheme.backgroundColor!,
                      ))),
                      child: UserComment(
                        key: GlobalKey(),
                        createdBy: reply['createdBy'],
                        isDeleted: reply['isDeleted'] ?? false,
                        isRemoved: reply['isRemoved'] ?? false,
                        timestamp: reply['timestamp'] ??
                            Timestamp.fromMicrosecondsSinceEpoch(1660312350),
                        commentText: reply['text'],
                        replies: newReplies,
                        postId: widget.postId,
                        commentId: reply['commentId'],
                        unFocus: widget.unFocus,
                        blockedUsers: widget.blockedUsers,
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
        .doc(communityCode)
        .collection('Posts')
        .doc(widget.postId)
        .collection('Comments');

    return comments.add({
      'text': text,
      'isReply': true,
      'createdBy': userId,
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

  Future<void> deleteComment() async {
    DocumentReference comment = FirebaseFirestore.instance
        .collection('Communities')
        .doc(communityCode)
        .collection('Posts')
        .doc(widget.postId)
        .collection('Comments')
        .doc(widget.commentId);
    comment
        .update(({
          'isDeleted': true,
        }))
        .catchError((error) => Future.error(error));
  }

  void flagComment() async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': 'RSpCM_xJwri5l9DjMIGAy',
          'service_id': 'service_ydieaun',
          'template_id': 'template_ejdq7ar',
          'user_id': 'zycID_4Z1ijq9fgbW',
          'template_params': {
            'user_email': userEmail,
            'content_type': 'comment',
            'user_id': userId,
            'post_id': widget.postId,
            'comment_id': widget.commentId,
          }
        }));
    print(response.body);
    // Message
    const snackBar = SnackBar(
      content: Text(
          'Thank you, we received your report and will make a decision after reviewing'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {
      _isSelected = false;
    });
  }
}
