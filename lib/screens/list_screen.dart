import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/components/EventCard/event_card_component.dart';
import 'package:our_ummah/components/ImageCard/image_card_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_ummah/components/TextCard/text_card_component.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/components/tag_filter_component.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:provider/provider.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({
    Key? key,
    required this.sortValue,
    required this.users,
    required this.businesses,
  }) : super(key: key);
  final String sortValue;
  final List<AppUser> users;
  final List<Business> businesses;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final currUserId = FirebaseAuth.instance.currentUser!.uid;
  String _selectedTag = '';

  @override
  Widget build(BuildContext context) {
    final postsStream = FirebaseFirestore.instance
        .collection('Communities')
        .doc(Provider.of<Community>(context, listen: false).id)
        .collection('Posts')
        .withConverter(
          fromFirestore: postFromFirestore,
          toFirestore: postToFirestore,
        )
        .snapshots();
    final currUser = widget.users.firstWhere((user) => user.id == currUserId);
    return StreamBuilder<QuerySnapshot<Post>>(
      stream: postsStream,
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
        final notBlockedPosts = posts
            .where((post) => !currUser.blockedUsers.contains(post.createdBy));

        // filter posts by selected tag filter
        var filteredPosts = notBlockedPosts.where((post) {
          if (_selectedTag.isEmpty) return true;

          return post.tags.contains(_selectedTag);
        }).toList();

        // filter posts by end date
        filteredPosts = filteredPosts.where((post) {
          if (post.type != PostType.event) return true;

          final eventPost = post as EventPost;
          final eventEndDate = eventPost.endDate;

          return eventEndDate.isAfter(DateTime.now());
        }).toList();

        // filter out posts older than 30 days
        filteredPosts = filteredPosts.where((post) {
          final postDate = DateTime.fromMicrosecondsSinceEpoch(
              post.timestamp.microsecondsSinceEpoch);
          final thirtyDaysAgo =
              DateTime.now().subtract(const Duration(days: 30));

          return postDate.isAfter(thirtyDaysAgo);
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
                children: (Provider.of<Community>(context, listen: false).id !=
                            'Lwdm-2023'
                        ? tagOptionsList
                        : conferenceTagOptionsList)
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
            final PostCreator postCreator = post.isAd
                ? () {
                    final business = widget.businesses
                        .firstWhere((e) => e.id == post.createdBy);
                    return PostCreator(
                      name: business.title,
                      picUrl: business.businessLogoUrl,
                      id: business.id,
                    );
                  }()
                : () {
                    final user =
                        widget.users.firstWhere((e) => e.id == post.createdBy);
                    return PostCreator(
                      name: '${user.firstName} ${user.lastName}',
                      picUrl: user.profilePicUrl,
                      id: user.id,
                    );
                  }();

            switch (post.type) {
              case PostType.text:
                return TextCardComponent(
                  users: widget.users,
                  post: post as TextPost,
                  postCreator: postCreator,
                  businesses: widget.businesses,
                );
              case PostType.image:
                return ImageCardComponent(
                  users: widget.users,
                  post: post as ImagePost,
                  postCreator: postCreator,
                  businesses: widget.businesses,
                );
              case PostType.event:
                return EventCardComponent(
                  users: widget.users,
                  post: post as EventPost,
                  postCreator: postCreator,
                  businesses: widget.businesses,
                );
            }
          }).toList()
        ]);
      },
    );
  }

  void selectTagFilter(String tagName) {
    setState(() {
      _selectedTag = _selectedTag == tagName ? '' : tagName;
    });
  }
}
