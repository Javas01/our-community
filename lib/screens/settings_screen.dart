import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_ummah/actions/pick_image_action.dart';
import 'package:our_ummah/actions/user_actions/log_out_action.dart';
import 'package:our_ummah/actions/user_actions/unblock_user_action.dart';
import 'package:our_ummah/actions/user_actions/update_profile_action.dart';
import 'package:our_ummah/actions/user_actions/delete_account_action.dart';
import 'package:our_ummah/components/profile_pic_component.dart';
import 'package:our_ummah/components/text_form_field_components.dart';
import 'package:our_ummah/models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;
  final _usersStream = FirebaseFirestore.instance
      .collection('Users')
      .withConverter(
        fromFirestore: userFromFirestore,
        toFirestore: userToFirestore,
      )
      .snapshots();

  File? image;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: StreamBuilder<QuerySnapshot<AppUser>>(
            stream: _usersStream,
            builder: ((context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Failed to load profile');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final users =
                  snapshot.data!.docs.map((userDoc) => userDoc.data()).toList();
              final AppUser currUser = users.firstWhere(
                  (element) => element.id == _auth.currentUser!.uid);
              final blockedUsers = users
                  .where((user) => currUser.blockedUsers.contains(user.id))
                  .toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Center(
                      child: ProfilePic(
                        url: currUser.profilePicUrl,
                        image: image,
                        onTap: () async {
                          final imageTemp = await pickImage(
                            (() => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Failed to get image',
                                    ),
                                  ),
                                )),
                          );
                          setState(() {
                            image = imageTemp;
                          });
                        },
                        radius: 100,
                        iconSize: 190,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: FormInputField(
                          controller: firstNameController,
                          hintText: currUser.firstName,
                          icon: const Icon(Icons.person),
                          isLast: false,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: FormInputField(
                          controller: lastNameController,
                          hintText: currUser.lastName,
                          icon: const Icon(Icons.person),
                          isLast: true,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Blocked Users',
                    textScaleFactor: 1.5,
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ListView(
                        shrinkWrap: true,
                        children: blockedUsers.map((blockedUser) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      '${blockedUser.firstName} ${blockedUser.lastName}',
                                      textAlign: TextAlign.center,
                                      textScaleFactor: 1.2,
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: -14,
                                    child: IconButton(
                                      onPressed: () => unBlock(
                                        blockedUser.id,
                                        context,
                                        () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('User unblocked'),
                                            ),
                                          );
                                        },
                                      ),
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 20,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FormSubmitButton(
            onPressed: () {
              updateProfile(
                context,
                firstNameController,
                lastNameController,
                image,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                    ),
                  );
                },
              );
            },
            text: 'Update Profile',
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => logOut(context),
              child: const Text('Log out'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              onPressed: () => deleteAccount(context),
              child: const Text('Delete Account'),
            ),
          ],
        )
      ],
    );
  }
}
