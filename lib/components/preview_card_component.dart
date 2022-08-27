import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_ummah/actions/post_actions/vote_action.dart';
import 'package:our_ummah/components/comments_count_component.dart';
import 'package:our_ummah/components/profile_pic_component.dart';
import 'package:our_ummah/modals/user_info_modal.dart';
import 'package:our_ummah/models/comment_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/components/tag_component.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:our_ummah/config.dart' show communityCode;
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class PreviewCard extends StatefulWidget {
  const PreviewCard({
    Key? key,
    required this.post,
    required this.itemKey,
    required this.postCreator,
    required this.isSelected,
    required this.isCreator,
  }) : super(key: key);

  final Post post;
  final AppUser postCreator;
  final bool isSelected, isCreator;
  final GlobalKey itemKey;

  @override
  State<PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<PreviewCard> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final commentCount = FirebaseFirestore.instance
        .collection('Communities')
        .doc(communityCode)
        .collection('Posts')
        .doc(widget.post.id)
        .collection('Comments')
        .withConverter(
          fromFirestore: commentFromFirestore,
          toFirestore: commentToFirestore,
        )
        .snapshots();

    final voteCount =
        (widget.post.upVotes.length - widget.post.downVotes.length);
    bool isUpVoted = widget.post.upVotes.contains(_auth.currentUser!.uid);
    bool isDownVoted = widget.post.downVotes.contains(_auth.currentUser!.uid);
    final String postDate = widget.post.lastEdited == null
        ? 'Created ${timeago.format(
            DateTime.fromMicrosecondsSinceEpoch(
              widget.post.timestamp.microsecondsSinceEpoch,
            ),
          )}'
        : 'Edited ${timeago.format(
            DateTime.fromMicrosecondsSinceEpoch(
              widget.post.lastEdited!.microsecondsSinceEpoch,
            ),
          )}';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ProfilePic(
                    url: widget.postCreator.profilePicUrl,
                    onTap: () => showDialog(
                      context: context,
                      builder: (modalContext) => UserInfoModal(
                        context: modalContext,
                        contentCreator: widget.postCreator,
                        isCreator: widget.isCreator,
                        isUserBlocked: false,
                      ),
                    ),
                    radius: 10,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${widget.postCreator.firstName} ${widget.postCreator.lastName} - $postDate',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Spacer(),
                  ...widget.post.tags.map<Widget>(
                    (tag) {
                      return Tag(
                        color: tagOptions[tag]!,
                        title: tag,
                      );
                    },
                  ).toList()
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        widget.post.type == PostType.text
                            ? Text(
                                widget.post.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  widget.post.imageUrl,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                        const SizedBox(
                          height: 10,
                        ),
                        Linkify(
                          options: const LinkifyOptions(looseUrl: true),
                          onOpen: (link) async {
                            if (await canLaunchUrl(Uri.parse(link.url))) {
                              await launchUrl(Uri.parse(link.url));
                            } else {
                              throw 'Could not launch $link';
                            }
                          },
                          maxLines: null,
                          textAlign: TextAlign.center,
                          text: widget.post.description,
                          linkStyle: const TextStyle(
                            color: Colors.lightBlueAccent,
                          ),
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
                      StreamBuilder<QuerySnapshot<Comment>>(
                        stream: commentCount,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const CommentCount();
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CommentCount();
                          }
                          final userHasSeen = snapshot.data!.docs.isEmpty ||
                              widget.post.hasSeen.contains(
                                _auth.currentUser!.uid,
                              );
                          return CommentCount(
                            docs: snapshot.data!.docs,
                            hasSeen: userHasSeen,
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(voteCount.toString()),
                      GestureDetector(
                        onTap: () {
                          isUpVoted
                              ? vote(
                                  'remove',
                                  widget.post.id,
                                )
                              : vote(
                                  'up',
                                  widget.post.id,
                                );
                        },
                        child: Icon(
                          Icons.keyboard_arrow_up_outlined,
                          color: isUpVoted ? Colors.lightBlueAccent : null,
                          size: isUpVoted ? 30.0 : 25.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          isDownVoted
                              ? vote(
                                  'remove',
                                  widget.post.id,
                                )
                              : vote(
                                  'down',
                                  widget.post.id,
                                );
                        },
                        child: Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: isDownVoted ? Colors.lightBlueAccent : null,
                          size: isDownVoted ? 30.0 : 25.0,
                        ),
                      ),
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
}
