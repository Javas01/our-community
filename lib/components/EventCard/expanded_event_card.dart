import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:our_ummah/actions/open_map_action.dart';
import 'package:our_ummah/components/post_comments_component.dart';
import 'package:our_ummah/components/comment_field_component.dart';
import 'package:our_ummah/extensions/string_extensions.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:our_ummah/providers/post_comments_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpandedEventCard extends StatelessWidget {
  const ExpandedEventCard({
    Key? key,
    required this.post,
    required this.setExpanded,
    required this.users,
    required this.distanceFromUser,
  }) : super(key: key);

  final EventPost post;
  final List<AppUser> users;
  final double? distanceFromUser;

  final void Function(bool) setExpanded;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PostCommentsModel(),
      builder: ((context, child) {
        final unFocus =
            Provider.of<PostCommentsModel>(context, listen: false).unFocus;
        return GestureDetector(
          onTap: unFocus,
          child: Card(
            key: Provider.of<PostCommentsModel>(context, listen: false)
                .expandedCardKey,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Stack(
              children: [
                Positioned(
                  top: -5,
                  right: -5,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setExpanded(false),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setExpanded(false);
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(25.0, 10, 25, 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
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
                                          options: const LinkifyOptions(
                                              looseUrl: true),
                                          onOpen: (link) async {
                                            if (await canLaunchUrl(
                                                Uri.parse(link.url))) {
                                              await launchUrl(
                                                  Uri.parse(link.url));
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
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              '${DateFormat.MMMMd().format(post.startDate)} at ${DateFormat.jm().format(post.startDate)}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Icon(
                                                Icons.arrow_right_alt_rounded),
                                            Text(
                                              '${DateFormat.MMMMd().format(post.endDate)} at ${DateFormat.jm().format(post.endDate)}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        GestureDetector(
                                          onTap: () async {
                                            openMap(post.location);
                                          },
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            children: [
                                              Text(
                                                post.location,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.attach_money_rounded),
                                                const SizedBox(width: 5),
                                                Text(
                                                  post.price.name.toTitleCase(),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.people_rounded),
                                                const SizedBox(width: 5),
                                                Text(
                                                  post.audience.name
                                                      .toTitleCase(),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.location_on_rounded),
                                                const SizedBox(width: 5),
                                                Text(
                                                  distanceFromUser != null
                                                      ? '$distanceFromUser miles away'
                                                      : 'unavailable',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 10,
                        thickness: 2,
                      ),
                      PostComments(
                        users: users,
                        postId: post.id,
                      ),
                      CommentField(
                        postId: post.id,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
