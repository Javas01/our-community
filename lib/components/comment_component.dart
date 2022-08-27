import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:our_ummah/modals/comment_options_modal.dart';
import 'package:our_ummah/modals/user_info_modal.dart';
import 'package:our_ummah/components/profile_pic_component.dart';
import 'package:our_ummah/models/comment_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:our_ummah/providers/post_comments_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    print(Provider.of<Community>(context).id);
    final commentCreator =
        users.firstWhere((user) => user.id == comment.createdBy);
    final isCreator = userId == comment.createdBy;
    final commentDate = comment.lastEdited == null
        ? 'Created ${timeago.format(
            DateTime.fromMicrosecondsSinceEpoch(
              comment.timestamp.microsecondsSinceEpoch,
            ),
          )}'
        : 'Edited ${timeago.format(DateTime.fromMicrosecondsSinceEpoch(
            comment.lastEdited!.microsecondsSinceEpoch,
          ))}';
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
            builder: (_) {
              return Provider.value(
                value: Provider.of<Community>(context).id,
                child: CommentOptions(
                  isCreator: isCreator,
                  postId: postId,
                  comment: comment,
                  userEmail: userEmail,
                  userId: userId,
                  parentContext: context,
                ),
              );
            },
          );

          if (value == 1 || value == 2) {
            value == 1
                ? Provider.of<PostCommentsModel>(
                    expandedCardKey.currentContext!,
                    listen: false,
                  ).reply(
                    '${commentCreator.firstName} ${commentCreator.lastName}',
                    comment.text,
                    comment.replies,
                    comment.id,
                  )
                : Provider.of<PostCommentsModel>(
                    expandedCardKey.currentContext!,
                    listen: false,
                  ).edit(comment.text, comment.id);
            commentFocusNode.requestFocus();
          }
          if (value == 3) {
            ScaffoldMessenger.of(expandedCardKey.currentContext!).showSnackBar(
              const SnackBar(
                content: Text(
                  'Thank you, we received your report and will make a decision after reviewing',
                ),
              ),
            );
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
                    builder: (modalContext) => UserInfoModal(
                      context: modalContext,
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
                        Linkify(
                          options: const LinkifyOptions(looseUrl: true),
                          onOpen: (link) async {
                            if (await canLaunchUrl(Uri.parse(link.url))) {
                              await launchUrl(Uri.parse(link.url));
                            } else {
                              throw 'Could not launch $link';
                            }
                          },
                          text: comment.text,
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
