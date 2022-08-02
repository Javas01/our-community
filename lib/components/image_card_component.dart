import 'package:flutter/material.dart';
import 'expanded_card_component.dart';
import 'preview_card_component.dart';

class ImageCardComponent extends StatefulWidget {
  const ImageCardComponent(
      {Key? key,
      required this.image,
      required this.title,
      required this.description})
      : super(key: key);

  final String image, title, description;

  @override
  State<ImageCardComponent> createState() => _ImageCardComponentState();
}

class _ImageCardComponentState extends State<ImageCardComponent> {
  bool _isExpanded = false;

  void toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: _isExpanded ? MediaQuery.of(context).size.height - 200 : null,
        child: _isExpanded
            ? ExpandedCard(
                description: widget.description,
                title: widget.title,
                image: widget.image,
                toggleExpanded: toggleExpanded)
            : PreviewCard(
                description: widget.description,
                title: widget.title,
                image: widget.image,
                toggleExpanded: toggleExpanded,
              ));
  }
}
