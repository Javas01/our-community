import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:our_community/components/post_comments_component.dart';
import 'package:our_community/components/comment_field_component.dart';
import 'package:our_community/models/post_model.dart';
import 'package:our_community/models/user_model.dart';
import 'package:our_community/post_comments_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpandedCard extends StatefulWidget {
  const ExpandedCard({
    Key? key,
    required this.post,
    required this.setExpanded,
    required this.users,
  }) : super(key: key);

  final Post post;
  final List<AppUser> users;

  final void Function(bool) setExpanded;

  @override
  State<ExpandedCard> createState() => _ExpandedCardState();
}

class _ExpandedCardState extends State<ExpandedCard> {
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
                    onPressed: () => widget.setExpanded(false),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.setExpanded(false);
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(25.0, 10, 25, 10),
                              child: Text(
                                widget.post.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Linkify(
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
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 10,
                        thickness: 2,
                      ),
                      PostComments(
                        users: widget.users,
                        postId: widget.post.id,
                      ),
                      CommentField(
                        postId: widget.post.id,
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
