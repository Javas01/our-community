import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../actions/user_actions/delete_account_action.dart';
import '../components/profile_pic_component.dart';
import '../components/text_form_field_components.dart';
import '../screens/OnboardingScreen/onboarding_screen.dart';
import '../models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('Users')
      .withConverter(
        fromFirestore: userFromFirestore,
        toFirestore: userToFirestore,
      )
      .snapshots();
  final String currUserId = FirebaseAuth.instance.currentUser!.uid;
  final Reference profilePicRef = FirebaseStorage.instance
      .ref('profilePics')
      .child(FirebaseAuth.instance.currentUser!.uid);

  File? image;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: StreamBuilder(
            stream: _usersStream,
            builder:
                ((BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading');
              }

              final users = snapshot.data!.docs
                  .map((userDoc) => userDoc.data() as AppUser)
                  .toList();
              final AppUser currUser = users.firstWhere(
                  (element) => element.id == _auth.currentUser!.uid);

              final blockedUserIds = currUser.blockedUsers ?? [];
              final blockedUsers = users.where((user) {
                return blockedUserIds.contains(user.id);
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Center(
                      child: ProfilePic(
                        url: currUser.profilePicUrl,
                        image: image,
                        onTap: pickImage,
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
                          final blockedUserName =
                              '${blockedUser.firstName} ${blockedUser.lastName}';

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      blockedUserName,
                                      textAlign: TextAlign.center,
                                      textScaleFactor: 1.2,
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: -14,
                                    child: IconButton(
                                      onPressed: () => unBlock(blockedUser.id),
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
                    firstNameController.text, lastNameController.text, image,
                    () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                    ),
                  );
                });
              },
              text: 'Update Profile'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                logOut();
              },
              child: const Text('Log out'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              onPressed: () {
                deleteAccount(context);
              },
              child: const Text('Delete Account'),
            ),
          ],
        )
      ],
    );
  }

  void unBlock(String blockedUserId) async {
    final currUser = FirebaseFirestore.instance
        .collection('Users')
        .withConverter(
            fromFirestore: userFromFirestore, toFirestore: userToFirestore)
        .doc(_auth.currentUser!.uid);
    List blockedUsers = await currUser.get().then((doc) {
      final user = doc.data() as AppUser;
      return user.blockedUsers ?? [];
    });
    blockedUsers.remove(blockedUserId);

    currUser.update({
      'blockedUsers': blockedUsers,
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('user unblocked'),
        ),
      );
    });
  }

  void logOut() async {
    await _auth.signOut().then((value) => {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: ((context) => const OnboardingScreen())),
              (route) => false)
        });
  }

  void updateProfile(String firstName, String lastName, File? imageSrc,
      VoidCallback onSuccess) async {
    if (imageSrc == null && firstName.isEmpty && lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You havent changed anything'),
        ),
      );
      return;
    }

    firstNameController.clear();
    lastNameController.clear();
    try {
      String profilePicUrl = '';
      if (imageSrc != null) {
        await profilePicRef.putFile(imageSrc);
        profilePicUrl = await profilePicRef.getDownloadURL();
      }
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currUserId)
          .update({
        ...firstName.isNotEmpty ? ({'firstName': firstName}) : {},
        ...lastName.isNotEmpty ? ({'lastName': lastName}) : {},
        ...profilePicUrl.isNotEmpty ? ({'profilePicUrl': profilePicUrl}) : {},
      });

      onSuccess.call();
    } catch (e) {
      Future.error(e);
    }
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      Future.error('Failed to pick image: $e');
    }
  }
}
