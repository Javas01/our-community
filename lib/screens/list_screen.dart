import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_community/components/image_card_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_community/constants/tag_options.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../../config.dart' show communityCode;

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
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('Users')
      .withConverter(
        fromFirestore: userFromFirestore,
        toFirestore: userToFirestore,
      )
      .snapshots();
  final Stream<QuerySnapshot> _postsStream = FirebaseFirestore.instance
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
    return StreamBuilder(
        stream: _usersStream,
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> usersSnapshot) {
          if (usersSnapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (usersSnapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          final users = usersSnapshot.data!.docs
              .map((userDoc) => userDoc.data() as AppUser)
              .toList();
          final currUser = users.firstWhere((user) => user.id == currUserId);

          return StreamBuilder<QuerySnapshot>(
            stream: _postsStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              List<Post> posts = snapshot.data!.docs
                  .map((postDoc) => postDoc.data() as Post)
                  .toList();
              ;

              // filter posts by blockedUsers
              final notBlockedPosts = posts.where((post) {
                List blockedUsers = currUser.blockedUsers ?? [];

                return !blockedUsers.contains(post.createdBy);
              });

              // filter posts by selected tag filter
              var filteredPosts = notBlockedPosts.where((post) {
                if (_selectedTag.isEmpty) return true;

                return post.tags.contains(_selectedTag);
              }).toList();

              // sort posts by vote count (in ascending order)
              filteredPosts.sort((a, b) {
                if (widget.sortValue == 'Upvotes') {
                  List aUpVotes = a.upVotes ?? [];
                  List bUpVotes = b.upVotes ?? [];
                  List aDownVotes = a.downVotes ?? [];
                  List bDownVotes = b.downVotes ?? [];
                  int aVoteCount = aUpVotes.length - aDownVotes.length;
                  int bVoteCount = bUpVotes.length - bDownVotes.length;

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
                          .map<Widget>((tag) => TagFilter(
                                name: tag.keys.first,
                                color: tag.values.first,
                                selectedTag: _selectedTag,
                                selectTagFilter: selectTagFilter,
                              ))
                          .toList(),
                    ),
                  ),
                ),
                ...filteredPosts.reversed.map((post) {
                  // get post creator user object
                  final AppUser postCreator =
                      users.firstWhere((e) => e.id == post.createdBy);

                  return ImageCardComponent(
                    title: post.title,
                    description: post.description,
                    image: 'assets/masjid.jpeg',
                    upVotes: post.upVotes ?? [],
                    downVotes: post.downVotes ?? [],
                    createdBy: post.createdBy,
                    timestamp: post.timestamp,
                    lastEdited: post.lastEdited,
                    tags: post.tags,
                    postId: post.id,
                    resetValueNotifier: widget.resetValueNotifier,
                    postCreator: postCreator,
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

class TagFilter extends StatelessWidget {
  const TagFilter({
    Key? key,
    required this.name,
    required this.color,
    required this.selectedTag,
    required this.selectTagFilter,
  }) : super(key: key);

  final String name, selectedTag;
  final MaterialAccentColor color;
  final Function selectTagFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: OutlinedButton(
        onPressed: () {
          selectTagFilter(name);
        },
        focusNode: FocusNode(),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            selectedTag == name ? color : color.withOpacity(0.3),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          elevation: selectedTag == name ? MaterialStateProperty.all(5) : null,
        ),
        child: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
