import 'package:flutter/material.dart';

class PreviewCard extends StatefulWidget {
  VoidCallback toggleExpanded;

  PreviewCard(
      {Key? key,
      required this.image,
      required this.title,
      required this.description,
      required this.toggleExpanded})
      : super(key: key);

  final String image, title, description;

  @override
  State<PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<PreviewCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () {
                Scrollable.ensureVisible(
                  context,
                  alignment: 0.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
                widget.toggleExpanded();
              },
              child: Row(
                children: [
                  Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        widget.image,
                        width: 100,
                      )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          widget.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.chat_outlined,
                              size: 18,
                            ),
                            Row(
                              children: const [
                                Text('+21'),
                                Icon(Icons.keyboard_arrow_up_outlined),
                                Icon(Icons.keyboard_arrow_down_outlined),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ))
                ],
              ),
            )));
  }
}
