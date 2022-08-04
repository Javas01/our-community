import 'package:flutter/material.dart';
import 'expanded_card_component.dart';
import 'preview_card_component.dart';

class ImageCardComponent extends StatefulWidget {
  const ImageCardComponent({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
    required this.postId,
    required this.upVotes,
    required this.downVotes,
    required this.firstName,
    required this.lastName,
    required this.tags,
  }) : super(key: key);

  final String image, title, description, postId, firstName, lastName;
  final List<dynamic> upVotes, downVotes, tags;

  @override
  State<ImageCardComponent> createState() => _ImageCardComponentState();
}

class _ImageCardComponentState extends State<ImageCardComponent> {
  final dataKey = GlobalKey();
  bool _isExpanded = false;

  void toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Offset? _tapPosition;

  void _showCustomMenu() {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      items: [
        PopupMenuItem(
            value: 1,
            child: Row(children: const [
              Icon(Icons.delete),
              SizedBox(
                width: 10,
              ),
              Text('Delete')
            ]))
      ],
      position: RelativeRect.fromRect(
        _tapPosition! & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & overlay.size, // Bigger rect, the entire screen
      ),
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: dataKey,
      height: _isExpanded ? MediaQuery.of(context).size.height - 200 : null,
      child: _isExpanded
          ? ExpandedCard(
              description: widget.description,
              title: widget.title,
              image: widget.image,
              toggleExpanded: toggleExpanded,
              postId: widget.postId,
            )
          : GestureDetector(
              onLongPress: _showCustomMenu,
              onTapDown: _storePosition,
              child: PreviewCard(
                description: widget.description,
                title: widget.title,
                image: widget.image,
                toggleExpanded: toggleExpanded,
                upVotes: widget.upVotes,
                downVotes: widget.downVotes,
                postId: widget.postId,
                itemKey: dataKey,
                firstName: widget.firstName,
                lastName: widget.lastName,
                tags: widget.tags,
              ),
            ),
    );
  }
}
