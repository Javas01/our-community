import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/actions/flag_content_action.dart';
import 'package:our_ummah/modals/create_business_modal.dart';
import 'package:our_ummah/modals/create_event_modal.dart';
import 'package:our_ummah/modals/create_post_modal.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/actions/post_actions/delete_post_action.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:provider/provider.dart';

Future showPopupMenu(
  BuildContext context,
  dynamic post,
  Offset tapPosition,
  PostCreator? postCreator,
  List<Business>? businesses, [
  AppUser? appUser,
]) async {
  final user = FirebaseAuth.instance.currentUser!;
  final isCreator = post is Business
      ? user.uid == post.createdBy
      : post?.isAd
          ? appUser!.businessIds.contains(postCreator!.id)
          : user.uid == post.createdBy;
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

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
            context,
            post.id,
            post is Post ? 'post' : 'business',
            () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  post is Post ? 'Post deleted' : 'Business deleted',
                ),
              ),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: ((_) {
        return Provider.value(
          value: Provider.of<Community>(context, listen: false),
          child: post is Post
              ? post.type == PostType.event
                  ? CreateEventModal(
                      post: post as EventPost,
                      businesses: businesses,
                      users: [appUser!],
                    )
                  : CreatePostModal(
                      post: post,
                      businesses: businesses,
                      users: [appUser!],
                    )
              : CreateBusinessModal(business: post as Business),
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
