import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_community/components/image_card_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_community/constants/tag_options.dart';
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
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Users').snapshots();
  final Stream<QuerySnapshot> _postsStream = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityCode)
      .collection('Posts')
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
          final List<QueryDocumentSnapshot> users = usersSnapshot.data!.docs;
          final currUser =
              users.firstWhere((e) => e.id == currUserId).data() as Map;

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

              List<QueryDocumentSnapshot> postDocs = snapshot.data!.docs;

              // filter posts by blockedUsers
              var notBlockedDocs = postDocs.where((doc) {
                List blockedUsers = currUser['blockedUsers'] ?? [];
                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                String postCreatorId = data['createdBy']['id'];

                return !blockedUsers.contains(postCreatorId);
              });

              // filter posts by selected tag filter
              var filteredDocs = notBlockedDocs.where((doc) {
                if (_selectedTag.isEmpty) return true;

                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                List tags = data['tags'] ?? [];

                return tags.contains(_selectedTag);
              }).toList();

              // sort posts by vote count (in ascending order)
              filteredDocs.sort((a, b) {
                Map<String, dynamic> aData = a.data()! as Map<String, dynamic>;
                Map<String, dynamic> bData = b.data()! as Map<String, dynamic>;
                if (widget.sortValue == 'Upvotes') {
                  List aUpVotes = aData['upVotes'] ?? [];
                  List bUpVotes = bData['upVotes'] ?? [];
                  List aDownVotes = aData['downVotes'] ?? [];
                  List bDownVotes = bData['downVotes'] ?? [];
                  int aVoteCount = aUpVotes.length - aDownVotes.length;
                  int bVoteCount = bUpVotes.length - bDownVotes.length;

                  return aVoteCount.compareTo(bVoteCount);
                } else {
                  Timestamp aTimestamp = aData['timestamp'];
                  Timestamp bTimestamp = bData['timestamp'];

                  return aTimestamp.compareTo(bTimestamp);
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
                ...filteredDocs.reversed.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  // get post creator user object
                  String postCreatorId = data['createdBy']['id'];

                  final Map postCreator = users
                      .firstWhere((e) => e.id == postCreatorId)
                      .data() as Map;

                  return ImageCardComponent(
                    title: data['title'],
                    description: data['description'],
                    image: 'assets/masjid.jpeg',
                    upVotes: data['upVotes'] ?? [],
                    downVotes: data['downVotes'] ?? [],
                    creatorId: data['createdBy']['id'] ?? '',
                    timestamp: data['timestamp'],
                    lastEdited: data['lastEdited'],
                    tags: data['tags'] ?? [],
                    postId: document.id,
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
