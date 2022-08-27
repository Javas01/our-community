import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/components/ImageCard/image_card_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_ummah/components/TextCard/text_card_component.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/components/tag_filter_component.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/config.dart' show communityCode;

class ListScreen extends StatefulWidget {
  const ListScreen({
    Key? key,
    required this.resetValueNotifier,
    required this.sortValue,
  }) : super(key: key);
  final ValueNotifier<bool> resetValueNotifier;
  final String sortValue;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _usersStream = FirebaseFirestore.instance
      .collection('Users')
      .withConverter(
        fromFirestore: userFromFirestore,
        toFirestore: userToFirestore,
      )
      .snapshots();
  final _postsStream = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
      .collection('Posts')
      .withConverter(
        fromFirestore: postFromFirestore,
        toFirestore: postToFirestore,
      )
      .snapshots();
  final currUserId = FirebaseAuth.instance.currentUser!.uid;
  String _selectedTag = '';

  @override
  Widget build(BuildContext context) {
    if (widget.resetValueNotifier.value) {
      setState(() {
        _selectedTag = '';
      });
    }
    return StreamBuilder<QuerySnapshot<AppUser>>(
        stream: _usersStream,
        builder: (context, usersSnapshot) {
          if (usersSnapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (usersSnapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }
          final users = usersSnapshot.data!.docs
              .map((userDoc) => userDoc.data())
              .toList();
          final currUser = users.firstWhere((user) => user.id == currUserId);

          return StreamBuilder<QuerySnapshot<Post>>(
            stream: _postsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Failed to load posts');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              List<Post> posts =
                  snapshot.data!.docs.map((postDoc) => postDoc.data()).toList();

              // filter posts by blockedUsers
              final notBlockedPosts = posts.where(
                  (post) => !currUser.blockedUsers.contains(post.createdBy));

              // filter posts by selected tag filter
              var filteredPosts = notBlockedPosts.where((post) {
                if (_selectedTag.isEmpty) return true;

                return post.tags.contains(_selectedTag);
              }).toList();

              // sort posts by vote count (in ascending order)
              filteredPosts.sort((a, b) {
                if (widget.sortValue == 'Upvotes') {
                  int aVoteCount = a.upVotes.length - a.downVotes.length;
                  int bVoteCount = b.upVotes.length - b.downVotes.length;

                  return aVoteCount.compareTo(bVoteCount);
                } else {
                  return a.timestamp.compareTo(b.timestamp);
                }
              });

              return ListView(children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SizedBox(
                    height: 35,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: tagOptionsList
                          .map<Widget>(
                            (tag) => TagFilter(
                              name: tag.keys.first,
                              color: tag.values.first,
                              selectedTag: _selectedTag,
                              selectTagFilter: selectTagFilter,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                ...filteredPosts.reversed.map((post) {
                  // get post creator user object
                  final AppUser postCreator =
                      users.firstWhere((e) => e.id == post.createdBy);

                  return post.type == PostType.text
                      ? TextCardComponent(
                          users: users,
                          post: post as TextPost,
                          postCreator: postCreator,
                          resetValueNotifier: widget.resetValueNotifier,
                        )
                      : ImageCardComponent(
                          users: users,
                          post: post as ImagePost,
                          postCreator: postCreator,
                          resetValueNotifier: widget.resetValueNotifier,
                        );
                }).toList()
              ]);
            },
          );
        });
  }

  void selectTagFilter(String tagName) {
    setState(() {
      _selectedTag = _selectedTag == tagName ? '' : tagName;
    });
    widget.resetValueNotifier.value = false;
  }
}
