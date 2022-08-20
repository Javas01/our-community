import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_community/actions/flag_content_action.dart';
import 'package:our_community/modals/create_post_modal.dart';
import 'package:our_community/models/post_model.dart';
import 'package:our_community/actions/post_actions/delete_post_action.dart';

Future showPopupMenu(
    BuildContext context, Post post, Offset tapPosition) async {
  final user = FirebaseAuth.instance.currentUser!;
  final isCreator = user.uid == post.createdBy;
  final RenderBox overlay =
      Overlay.of(context)!.context.findRenderObject() as RenderBox;

  final value = await showMenu<int>(
    context: context,
    items: [
      PopupMenuItem(
        value: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: isCreator
              ? const [Icon(Icons.edit), SizedBox(width: 10), Text('Edit')]
              : const [Icon(Icons.flag), SizedBox(width: 10), Text('Flag')],
        ),
      ),
      if (isCreator)
        PopupMenuItem(
          value: 2,
          onTap: () => deletePost(
            post.id,
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Post deleted'),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.delete,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              )
            ],
          ),
        )
    ],
    position: RelativeRect.fromRect(
      tapPosition & context.size!, // smaller rect, the touch area
      Offset.zero & overlay.size, // Bigger rect, the entire screen
    ),
  );
  if (value == 1 && isCreator) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: ((context) {
        return CreatePostModal(
          tags: post.tags,
          title: post.title,
          description: post.description,
          postId: post.id,
          isEdit: true,
        );
      }),
    );
  } else if (value == 1) {
    flagContent(
      user.email,
      user.uid,
      post.id,
      null,
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Thank you, we received your report and will make a decision after reviewing',
            ),
          ),
        );
      },
    );
  }
}
