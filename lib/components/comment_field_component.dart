import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/actions/comment_actions/add_comment_action.dart';
import 'package:our_ummah/actions/comment_actions/edit_comment_action.dart';
import 'package:our_ummah/providers/post_comments_provider.dart';
import 'package:provider/provider.dart';

class CommentField extends StatefulWidget {
  const CommentField({
    Key? key,
    required this.postId,
  }) : super(key: key);

  final String postId;

  @override
  State<CommentField> createState() => _CommentFieldState();
}

class _CommentFieldState extends State<CommentField> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  bool _showClear = false;
  @override
  Widget build(BuildContext context) {
    final focusNode =
        Provider.of<PostCommentsModel>(context, listen: false).commentFocusNode;
    final unFocus =
        Provider.of<PostCommentsModel>(context, listen: false).unFocus;
    final parentCommentId = Provider.of<PostCommentsModel>(
      context,
      listen: false,
    ).parentCommentId;
    final parentCommentReplies = Provider.of<PostCommentsModel>(
      context,
      listen: false,
    ).parentCommentReplies;
    final commentController = Provider.of<PostCommentsModel>(
      context,
      listen: false,
    ).commentController;
    return Consumer<PostCommentsModel>(builder: (context, value, child) {
      focusNode.addListener(() {
        if (!focusNode.hasFocus) value.reset();
      });
      return Column(
        children: [
          if (value.isReply)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value.parentCommentCreator,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        value.parentCommentText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      focusNode: focusNode,
                      controller: commentController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: const TextStyle(fontSize: 12, height: 1),
                      onChanged: (content) {
                        content != ''
                            ? setState(() {
                                _showClear = true;
                              })
                            : setState(() {
                                _showClear = false;
                              });
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.chat_outlined,
                          size: 20,
                        ),
                        hintText: value.isReply
                            ? 'Reply to comment'
                            : value.isEdit
                                ? 'Edit comment'
                                : 'Reply to post',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: _showClear
                            ? IconButton(
                                onPressed: () {
                                  commentController.clear();
                                  unFocus();
                                  setState(() {
                                    _showClear = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.clear_rounded,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(50, 50),
                  shape: const CircleBorder(),
                ),
                onPressed: () {
                  unFocus();
                  value.isEdit
                      ? editComment(
                          context,
                          widget.postId,
                          parentCommentId,
                          value.parentCommentText,
                          commentController,
                        )
                      : addComment(
                          context,
                          commentController,
                          widget.postId,
                          userId,
                          parentCommentId,
                          parentCommentReplies,
                        );
                },
                child: Icon(
                  value.isReply
                      ? Icons.reply_rounded
                      : value.isEdit
                          ? Icons.edit_rounded
                          : Icons.send_rounded,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
