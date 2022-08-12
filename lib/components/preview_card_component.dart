import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_community/components/tag_component.dart';
import '../constants/tag_options.dart';
import 'package:intl/intl.dart';

class PreviewCard extends StatefulWidget {
  late DocumentReference post;
  late Future<QuerySnapshot> commentCount;
  PreviewCard({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
    required this.itemKey,
    required this.upVotes,
    required this.downVotes,
    required this.postId,
    required this.firstName,
    required this.lastName,
    required this.tags,
    required this.timestamp,
    required this.isSelected,
  }) : super(key: key) {
    post = FirebaseFirestore.instance
        .collection('Communities')
        .doc('ATLMasjid')
        .collection('Posts')
        .doc(postId);
    commentCount = FirebaseFirestore.instance
        .collection('Communities')
        .doc('ATLMasjid')
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .get();
  }

  final String image, title, description, postId, firstName, lastName;
  final bool isSelected;
  final List<dynamic> upVotes, downVotes, tags;
  final GlobalKey itemKey;
  final Timestamp timestamp;

  @override
  State<PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<PreviewCard> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String voteCount =
        (widget.upVotes.length - widget.downVotes.length).toString();
    bool isUpVoted = widget.upVotes.contains(_auth.currentUser!.uid);
    bool isDownVoted = widget.downVotes.contains(_auth.currentUser!.uid);
    final postDate = DateFormat('yyyy-MM-dd (hh:mm aa)').format(
        DateTime.fromMicrosecondsSinceEpoch(
            widget.timestamp.microsecondsSinceEpoch));

    return Card(
      elevation: widget.isSelected ? 10 : 0,
      margin:
          widget.isSelected ? const EdgeInsets.fromLTRB(0, 10, 0, 10) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('${widget.firstName} ${widget.lastName} - $postDate',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                    )),
                const Spacer(),
                ...widget.tags.map<Widget>((tag) {
                  return Tag(
                    color: tagOptions[tag]!,
                    title: tag,
                  );
                }).toList()
              ]),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.description,
                          maxLines: null,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      FutureBuilder(
                        future: widget.commentCount,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('0');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('0');
                          }
                          return Text(snapshot.data!.docs.length.toString());
                        },
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.chat_outlined,
                        size: 20,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(voteCount),
                      GestureDetector(
                        onTap: () {
                          isUpVoted ? vote('remove') : vote('up');
                        },
                        child: Icon(
                          Icons.keyboard_arrow_up_outlined,
                          color: isUpVoted ? Colors.lightBlueAccent : null,
                          size: isUpVoted ? 30.0 : 25.0,
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            isDownVoted ? vote('remove') : vote('down');
                          },
                          child: Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: isDownVoted ? Colors.lightBlueAccent : null,
                            size: isDownVoted ? 30.0 : 25.0,
                          ))
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> vote(String voteType) {
    switch (voteType) {
      case 'up':
        {
          widget.upVotes.add(_auth.currentUser!.uid);
          widget.downVotes.remove(_auth.currentUser!.uid);
        }
        break;
      case 'down':
        {
          widget.downVotes.add(_auth.currentUser!.uid);
          widget.upVotes.remove(_auth.currentUser!.uid);
        }
        break;
      // default is remove vote
      default:
        {
          widget.upVotes.remove(_auth.currentUser!.uid);
          widget.downVotes.remove(_auth.currentUser!.uid);
        }
        break;
    }

    return widget.post.update({
      'upVotes': widget.upVotes,
      'downVotes': widget.downVotes,
    }).catchError((error) => Future.error(error));
  }
}
