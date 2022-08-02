import 'package:flutter/material.dart';

import 'comment_component.dart';

class ExpandedCard extends StatefulWidget {
  VoidCallback toggleExpanded;

  ExpandedCard(
      {Key? key,
      required this.image,
      required this.title,
      required this.description,
      required this.toggleExpanded})
      : super(key: key);

  final String image, title, description;

  @override
  State<ExpandedCard> createState() => _ExpandedCardState();
}

class _ExpandedCardState extends State<ExpandedCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  widget.toggleExpanded();
                },
                child: Column(children: [
                  Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        widget.image,
                        width: 200,
                      )),
                  Text(widget.description),
                ]),
              ),
              const Divider(
                height: 10,
                thickness: 2,
              ),
              SizedBox(
                height: 350,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return const UserComment();
                  },
                ),
              ),
              TextField(
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.chat_outlined),
                      hintText: 'Reply',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)))),
            ],
          )),
    );
  }
}
