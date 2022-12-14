import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:our_ummah/components/post_comments_component.dart';
import 'package:our_ummah/components/comment_field_component.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:our_ummah/providers/post_comments_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpandedTextCard extends StatelessWidget {
  const ExpandedTextCard({
    Key? key,
    required this.post,
    required this.setExpanded,
    required this.users,
  }) : super(key: key);

  final TextPost post;
  final List<AppUser> users;

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
                                child: Text(
                                  post.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
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
                                text: post.description,
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
