import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/modals/create_post_modal.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:our_ummah/screens/settings_screen.dart';
import 'package:our_ummah/screens/list_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _usersStream = FirebaseFirestore.instance
      .collection('Users')
      .withConverter(
        fromFirestore: userFromFirestore,
        toFirestore: userToFirestore,
      )
      .snapshots();

  int currentIndex = 0;
  String _sortValue = 'Upvotes';
  late List screens;
  ValueNotifier<bool> resetValueNotifier = ValueNotifier(false);
  Community? selectedCommunity;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Community>>(
        future: FirebaseFirestore.instance
            .collection('Communities')
            .withConverter(
                fromFirestore: communityFromFirestore,
                toFirestore: communityToFirestore)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final communities =
                snapshot.data!.docs.map((doc) => doc.data()).toList();

            return StreamBuilder<QuerySnapshot<AppUser>>(
                stream: _usersStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final users = snapshot.data!.docs
                      .map((userDoc) => userDoc.data())
                      .toList();
                  final currUser = users.firstWhere((user) =>
                      user.id == FirebaseAuth.instance.currentUser!.uid);
                  final userCommunities = communities
                      .where((item) => currUser.communityCodes
                          .contains(item.id.toLowerCase()))
                      .toList();
                  selectedCommunity = selectedCommunity ?? userCommunities[0];

                  screens = [
                    ListScreen(
                      resetValueNotifier: resetValueNotifier,
                      sortValue: _sortValue,
                      users: users,
                    ),
                    const Scaffold(),
                    const SettingsScreen()
                  ];

                  return Provider.value(
                    value: selectedCommunity,
                    child: Scaffold(
                      appBar: AppBar(
                        elevation: 1,
                        title: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            alignment: Alignment.center,
                            underline: null,
                            borderRadius: BorderRadius.circular(15),
                            hint: Text(selectedCommunity!.name),
                            value: selectedCommunity!.id,
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            onChanged: (newValue) {
                              setState(() {
                                selectedCommunity = userCommunities.firstWhere(
                                    (element) => element.id == newValue);
                              });
                            },
                            items: userCommunities.map((community) {
                              return DropdownMenuItem<String>(
                                value: community.id,
                                child: Text(community.name),
                              );
                            }).toList(),
                          ),
                        ),
                        leading: null,
                        actions: [
                          PopupMenuButton(
                            icon: _sortValue == 'Upvotes'
                                ? const Icon(Icons.arrow_circle_up_rounded)
                                : const Icon(Icons.access_time_rounded),
                            initialValue: _sortValue,
                            onSelected: (value) => setState(() {
                              setState(() {
                                _sortValue = value.toString();
                              });
                            }),
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry>[
                              const PopupMenuItem(
                                value: 'Upvotes',
                                child: Text('Upvotes'),
                              ),
                              const PopupMenuItem(
                                value: 'Recent',
                                child: Text('Recent'),
                              ),
                            ],
                          )
                        ],
                      ),
                      body: screens[currentIndex],
                      bottomNavigationBar: BottomNavigationBar(
                        items: const <BottomNavigationBarItem>[
                          BottomNavigationBarItem(
                            icon: Icon(Icons.list),
                            label: 'List',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.add),
                            label: 'Create',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.settings),
                            label: 'Settings',
                          ),
                        ],
                        currentIndex: currentIndex,
                        onTap: (value) {
                          if (value == 0 &&
                              currentIndex == 0 &&
                              resetValueNotifier.value == false) {
                            resetValueNotifier.value = true;
                          }
                          if (value == 1) {
                            if (currentIndex == 2) {
                              setState(() {
                                currentIndex = 0;
                              });
                            }

                            showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext c) {
                                  return Provider.value(
                                    value: selectedCommunity,
                                    child: const CreatePostModal(),
                                  );
                                });
                          } else {
                            setState(() {
                              currentIndex = value;
                            });
                          }
                        },
                      ),
                    ),
                  );
                });
          } else {
            return const Text('');
          }
        });
  }
}
