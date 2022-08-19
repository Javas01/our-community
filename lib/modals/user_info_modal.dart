import 'package:flutter/material.dart';
import 'package:our_community/models/user_model.dart';
import 'package:our_community/components/profile_pic_component.dart';
import 'package:our_community/actions/user_actions/block_user_action.dart';
import 'package:our_community/actions/user_actions/unblock_user_action.dart';

class UserInfoModal extends StatelessWidget {
  const UserInfoModal({
    Key? key,
    required this.context,
    required this.contentCreator,
    required this.isCreator,
    required this.isUserBlocked,
  }) : super(key: key);

  final BuildContext context;
  final AppUser contentCreator;
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
            url: contentCreator.profilePicUrl,
          ),
          Center(
            child: Text(
              '${contentCreator.firstName} ${contentCreator.lastName}',
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
