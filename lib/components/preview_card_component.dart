import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_community/components/tag_component.dart';
import '../constants/tag_options.dart';

class PreviewCard extends StatefulWidget {
  late DocumentReference post;
  PreviewCard({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
    required this.toggleExpanded,
    required this.itemKey,
    required this.upVotes,
    required this.downVotes,
    required this.postId,
    required this.firstName,
    required this.lastName,
    required this.tags,
    required this.isSelected,
  }) : super(key: key) {
    post = FirebaseFirestore.instance.collection('Posts').doc(postId);
  }

  final String image, title, description, postId, firstName, lastName;
  final bool isSelected;
  final List<dynamic> upVotes, downVotes, tags;
  final VoidCallback toggleExpanded;
  final GlobalKey itemKey;

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
        child: Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('${widget.firstName} ${widget.lastName}',
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
                            height: 15,
                          ),
                          Text(
                            widget.description,
                            maxLines: null,
                            textAlign: TextAlign.center,
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
                    GestureDetector(
                      onTap: () {
                        widget.toggleExpanded();
                        Future.delayed(const Duration(milliseconds: 50), () {
                          Scrollable.ensureVisible(
                            widget.itemKey.currentContext!,
                            alignment: 0.0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        });
                      },
                      child: const Icon(
                        Icons.chat_outlined,
                        size: 18,
                      ),
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
                            size: isUpVoted ? 22.0 : 20.0,
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              isDownVoted ? vote('remove') : vote('down');
                            },
                            child: Icon(
                              Icons.keyboard_arrow_down_outlined,
                              color:
                                  isDownVoted ? Colors.lightBlueAccent : null,
                              size: isDownVoted ? 22.0 : 20.0,
                            ))
                      ],
                    )
                  ],
                )
              ],
            ),
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
