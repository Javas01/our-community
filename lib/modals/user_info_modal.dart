import 'package:flutter/material.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/components/profile_pic_component.dart';
import 'package:our_ummah/actions/user_actions/block_user_action.dart';
import 'package:our_ummah/actions/user_actions/unblock_user_action.dart';

class UserInfoModal extends StatelessWidget {
  const UserInfoModal({
    Key? key,
    required this.context,
    required this.contentCreator,
    required this.isCreator,
    required this.isUserBlocked,
  }) : super(key: key);

  final BuildContext context;
  final PostCreator contentCreator;
  final bool isCreator, isUserBlocked;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          ProfilePic(
            onTap: () {},
            radius: 70,
            iconSize: 100,
            url: contentCreator.picUrl,
          ),
          Center(
            child: Text(
              contentCreator.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: !isCreator
          ? [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => isUserBlocked
                    ? unBlock(contentCreator.id, context, () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('user unblocked successfully'),
                          ),
                        );
                      })
                    : blockUser(context, contentCreator.id, () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('user blocked successfully'),
                          ),
                        );
                      }),
                style: ButtonStyle(
                  backgroundColor: isUserBlocked
                      ? null
                      : MaterialStateProperty.all(Colors.red),
                ),
                child:
                    isUserBlocked ? const Text('Unblock') : const Text('Block'),
              ),
            ]
          : [],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
