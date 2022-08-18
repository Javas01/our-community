import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:our_community/modals/user_info_modal.dart';
import '../components/profile_pic_component.dart';
import '../components/text_field_components.dart';
import '../actions/comment_actions/delete_comment_action.dart';
import '../actions/comment_actions/reply_to_comment_action.dart';
import '../actions/flag_content_action.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';

class UserComment extends StatefulWidget {
  const UserComment({
    Key? key,
    required this.comment,
    required this.replies,
    required this.postId,
    required this.unFocus,
    required this.blockedUsers,
    required this.comments,
  }) : super(key: key);
  final Comment comment;
  final String postId;
  final List<String> blockedUsers;
  final List<Comment> comments, replies;
  final VoidCallback unFocus;

  @override
  State<UserComment> createState() => _UserCommentState();
}

class _UserCommentState extends State<UserComment> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  final TextEditingController commentController = TextEditingController();

  bool _isSelected = false;
  late bool _isUserBlocked;

  @override
  void initState() {
    _isUserBlocked = widget.blockedUsers.contains(widget.comment.createdBy);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isCreator = userId == widget.comment.createdBy;
    final commentDate = DateFormat('yyyy-MM-dd (hh:mm aa)').format(
        DateTime.fromMicrosecondsSinceEpoch(
            widget.comment.timestamp.microsecondsSinceEpoch));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onLongPress: () {
          if (widget.comment.isDeleted || widget.comment.isRemoved) return;

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
                    .doc(widget.comment.createdBy)
                    .withConverter(
                      fromFirestore: userFromFirestore,
                      toFirestore: userToFirestore,
                    )
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading');
                  }
                  final commentCreator = snapshot.data!.data() as AppUser;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfilePic(
                        onTap: () => showDialog(
                          context: context,
                          builder: (buildContext) => UserInfoModal(
                            context: buildContext,
                            contentCreator: commentCreator,
                            isCreator: isCreator,
                            isUserBlocked: _isUserBlocked,
                          ),
                        ),
                        url: commentCreator.profilePicUrl,
                        iconSize: 10,
                        radius: 10,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.comment.isDeleted ||
                                    widget.comment.isRemoved ||
                                    _isUserBlocked
                                ? Text(
                                    widget.comment.isDeleted
                                        ? 'Comment deleted by user'
                                        : widget.comment.isRemoved
                                            ? 'Comment removed by moderator'
                                            : 'You have this user blocked',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                : Text(
                                    '${commentCreator.firstName} ${commentCreator.lastName} - $commentDate',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                            const SizedBox(height: 4),
                            if (widget.comment.isDeleted == false &&
                                widget.comment.isRemoved == false &&
                                _isUserBlocked == false)
                              Text(
                                widget.comment.text,
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
                                              onPressed: () => deleteComment(
                                                widget.postId,
                                                widget.comment.id,
                                              ),
                                            )
                                          : IconButton(
                                              icon: const Icon(
                                                Icons.flag,
                                                size: 30,
                                              ),
                                              onPressed: () => flagContent(
                                                  userEmail,
                                                  userId,
                                                  widget.postId,
                                                  widget.comment.id, () {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Thank you, we received your report and will make a decision after reviewing',
                                                    ),
                                                  ),
                                                );
                                                setState(() {
                                                  _isSelected = false;
                                                });
                                              }),
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
                                                    context,
                                                    commentController,
                                                    widget.postId,
                                                    userId,
                                                    widget.comment.id,
                                                    widget.comment.replies,
                                                  );
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
              final replies = reply.replies;
              final replyComments = widget.comments
                  .where((comment) => replies.contains(comment.id))
                  .toList();

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      width: 1,
                      color: Theme.of(context).appBarTheme.backgroundColor!,
                    ),
                  ),
                ),
                child: UserComment(
                  key: GlobalKey(),
                  comment: reply,
                  replies: replyComments,
                  postId: widget.postId,
                  unFocus: widget.unFocus,
                  blockedUsers: widget.blockedUsers,
                  comments: widget.comments,
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
