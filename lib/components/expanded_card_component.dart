import 'package:flutter/material.dart';
import 'package:our_community/components/post_comments_component.dart';
import 'package:our_community/components/text_field_components.dart';
import 'package:our_community/models/post_model.dart';
import 'package:our_community/post_comments_provider.dart';
import 'package:provider/provider.dart';

class ExpandedCard extends StatefulWidget {
  const ExpandedCard({
    Key? key,
    required this.post,
    required this.setExpanded,
  }) : super(key: key);

  final Post post;
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
                            Text(
                              widget.post.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                widget.post.description,
                                maxLines: null,
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
