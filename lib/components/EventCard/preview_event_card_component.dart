import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:our_ummah/actions/post_actions/vote_action.dart';
import 'package:our_ummah/components/comments_count_component.dart';
import 'package:our_ummah/components/profile_pic_component.dart';
import 'package:our_ummah/modals/user_info_modal.dart';
import 'package:our_ummah/models/comment_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/components/tag_component.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:our_ummah/constants/tag_options.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class PreviewEventCard extends StatelessWidget {
  const PreviewEventCard({
    Key? key,
    required this.post,
    required this.itemKey,
    required this.postCreator,
    required this.isSelected,
    required this.isCreator,
  }) : super(key: key);

  final EventPost post;
  final AppUser postCreator;
  final bool isSelected, isCreator;
  final GlobalKey itemKey;

  @override
  Widget build(BuildContext context) {
    final commentCount = FirebaseFirestore.instance
        .collection('Communities')
        .doc(Provider.of<Community>(context, listen: false).id)
        .collection('Posts')
        .doc(post.id)
        .collection('Comments')
        .withConverter(
          fromFirestore: commentFromFirestore,
          toFirestore: commentToFirestore,
        )
        .snapshots();

    final voteCount = (post.upVotes.length - post.downVotes.length);
    bool isUpVoted =
        post.upVotes.contains(FirebaseAuth.instance.currentUser!.uid);
    bool isDownVoted =
        post.downVotes.contains(FirebaseAuth.instance.currentUser!.uid);
    final String postDate = post.lastEdited == null
        ? 'Posted ${timeago.format(
            DateTime.fromMicrosecondsSinceEpoch(
              post.timestamp.microsecondsSinceEpoch,
            ),
          )}'
        : 'Edited ${timeago.format(
            DateTime.fromMicrosecondsSinceEpoch(
              post.lastEdited!.microsecondsSinceEpoch,
            ),
          )}';

    return Card(
      elevation: isSelected ? 10 : 0,
      margin: isSelected ? const EdgeInsets.fromLTRB(0, 10, 0, 10) : null,
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
                    url: postCreator.profilePicUrl,
                    onTap: () => showDialog(
                      context: context,
                      builder: (modalContext) => UserInfoModal(
                        context: modalContext,
                        contentCreator: postCreator,
                        isCreator: isCreator,
                        isUserBlocked: false,
                      ),
                    ),
                    radius: 10,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${postCreator.firstName} ${postCreator.lastName} - $postDate',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Spacer(),
                  ...post.tags.map<Widget>(
                    (tag) {
                      return Tag(
                        color: businessOptions[tag]!,
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
                        if (post.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              post.imageUrl,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
                          text: post.description,
                          linkStyle: const TextStyle(
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(
                          'Event Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Start Date',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat.yMMMMd().format(post.date),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Start Time',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat.jm().format(post.date),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              post.location,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              post.price,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Creator',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${postCreator.firstName} ${postCreator.lastName}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Audience',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              post.audience,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
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
                              post.hasSeen.contains(
                                FirebaseAuth.instance.currentUser!.uid,
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
                                  post.id,
                                  context,
                                )
                              : vote(
                                  'up',
                                  post.id,
                                  context,
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
                                  post.id,
                                  context,
                                )
                              : vote(
                                  'down',
                                  post.id,
                                  context,
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
