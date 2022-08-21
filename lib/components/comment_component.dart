import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:our_community/modals/comment_options_modal.dart';
import 'package:our_community/modals/user_info_modal.dart';
import 'package:our_community/components/profile_pic_component.dart';
import 'package:our_community/models/comment_model.dart';
import 'package:our_community/models/user_model.dart';
import 'package:our_community/post_comments_provider.dart';
import 'package:provider/provider.dart';

class UserComment extends StatelessWidget {
  UserComment({
    Key? key,
    required this.comment,
    required this.replies,
    required this.postId,
    required this.blockedUsers,
    required this.comments,
    required this.isUserBlocked,
    required this.users,
  }) : super(key: key);
  final List<AppUser> users;
  final Comment comment;
  final String postId;
  final List<String> blockedUsers;
  final List<Comment> comments, replies;
  final bool isUserBlocked;

  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final commentCreator =
        users.firstWhere((user) => user.id == comment.createdBy);
    final isCreator = userId == comment.createdBy;
    final commentDate = DateFormat('yyyy-MM-dd (hh:mm aa)').format(
        DateTime.fromMicrosecondsSinceEpoch(
            comment.timestamp.microsecondsSinceEpoch));
    final expandedCardKey =
        Provider.of<PostCommentsModel>(context, listen: false).expandedCardKey;
    final commentFocusNode =
        Provider.of<PostCommentsModel>(context, listen: false).commentFocusNode;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onLongPress: () async {
          if (comment.isDeleted || comment.isRemoved) return;
          final value = await showModalBottomSheet<int>(
            context: context,
            backgroundColor: Colors.black.withOpacity(0),
            builder: (context) {
              return CommentOptions(
                isCreator: isCreator,
                postId: postId,
                comment: comment,
                userEmail: userEmail,
                userId: userId,
              );
            },
          );

          if (value == 1) {
            Provider.of<PostCommentsModel>(expandedCardKey.currentContext!,
                    listen: false)
                .reply(
              '${commentCreator.firstName} ${commentCreator.lastName}',
              comment.text,
              comment.replies,
              comment.id,
            );
            commentFocusNode.requestFocus();
          }
        },
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfilePic(
                  onTap: () => showDialog(
                    context: context,
                    builder: (buildContext) => UserInfoModal(
                      context: buildContext,
                      contentCreator: commentCreator,
                      isCreator: isCreator,
                      isUserBlocked: isUserBlocked,
                    ),
                  ),
                  url: commentCreator.profilePicUrl,
                  radius: 10,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      comment.isDeleted || comment.isRemoved || isUserBlocked
                          ? Text(
                              comment.isDeleted
                                  ? 'Comment deleted by user'
                                  : comment.isRemoved
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
                      if (comment.isDeleted == false &&
                          comment.isRemoved == false &&
                          isUserBlocked == false)
                        Text(
                          comment.text,
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            ...replies.map((reply) {
              final replies = reply.replies;
              final replyComments = comments
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
                  postId: postId,
                  blockedUsers: blockedUsers,
                  comments: comments,
                  isUserBlocked: isUserBlocked,
                  users: users,
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
