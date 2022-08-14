import 'package:flutter/material.dart';
import 'package:our_community/components/image_card_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_community/constants/tag_options.dart';

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
  final Stream<QuerySnapshot> _postsStream = FirebaseFirestore.instance
      .collection('Communities')
      .doc('ATLMasjid')
      .collection('Posts')
      .snapshots();

  String _selectedTag = '';

  @override
  Widget build(BuildContext context) {
    if (widget.resetValueNotifier.value) {
      setState(() {
        _selectedTag = '';
      });
    }
    return StreamBuilder<QuerySnapshot>(
      stream: _postsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        List<QueryDocumentSnapshot> postDocs = snapshot.data!.docs;

        // filter posts by selected tag filter
        var filteredDocs = postDocs.where((doc) {
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
            return ImageCardComponent(
              title: data['title'],
              description: data['description'],
              image: 'assets/masjid.jpeg',
              upVotes: data['upVotes'] ?? [],
              downVotes: data['downVotes'] ?? [],
              firstName: data['createdBy']['firstName'] ?? '',
              lastName: data['createdBy']['lastName'] ?? '',
              creatorId: data['createdBy']['id'] ?? '',
              timestamp: data['timestamp'],
              lastEdited: data['lastEdited'],
              tags: data['tags'] ?? [],
              postId: document.id,
              resetValueNotifier: widget.resetValueNotifier,
            );
          }).toList()
        ]);
      },
    );
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
