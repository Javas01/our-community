import 'package:flutter/material.dart';
import 'package:our_ummah/actions/comment_actions/delete_comment_action.dart';
import 'package:our_ummah/actions/flag_content_action.dart';
import 'package:our_ummah/models/comment_model.dart';

class CommentOptions extends StatelessWidget {
  const CommentOptions({
    Key? key,
    required this.isCreator,
    required this.postId,
    required this.comment,
    required this.userEmail,
    required this.userId,
    required this.parentContext,
  }) : super(key: key);

  final bool isCreator;
  final String postId;
  final Comment comment;
  final String? userEmail;
  final String userId;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
          color: Theme.of(context).canvasColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Reply',
                textScaleFactor: 1.5,
              ),
              onPressed: () => Navigator.pop(context, 1),
            ),
            const Divider(thickness: 1),
            if (isCreator) ...[
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Edit',
                  textScaleFactor: 1.5,
                ),
                onPressed: () => Navigator.pop(context, 2),
              ),
              const Divider(thickness: 1),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Delete',
                  textScaleFactor: 1.5,
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  deleteComment(postId, comment.id, parentContext);
                  Navigator.pop(context);
                },
              )
            ] else
              TextButton(
                style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                child: const Text(
                  'Report',
                  textScaleFactor: 1.5,
                ),
                onPressed: () {
                  flagContent(
                    userEmail,
                    userId,
                    postId,
                    comment.id,
                    () {},
                  );
                  Navigator.pop(context, 3);
                },
              ),
          ],
        ),
      ),
    );
  }
}
