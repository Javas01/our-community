import 'package:flutter/material.dart';

class Tag extends StatefulWidget {
  final MaterialAccentColor color;
  final String title;
  final bool? dontExpand;

  const Tag({
    Key? key,
    required this.color,
    required this.title,
    this.dontExpand,
  }) : super(key: key);

  @override
  State<Tag> createState() => _TagState();
}

class _TagState extends State<Tag> {
  bool _showTag = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.dontExpand == true) return;
        setState(() {
          _showTag = !_showTag;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _showTag ? 20 : 7,
        width: _showTag ? 50 : 7,
        decoration: BoxDecoration(
            color: widget.color,
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        child: _showTag
            ? Padding(
                padding: const EdgeInsets.all(3.0),
                child: Center(
                    child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                )),
              )
            : null,
      ),
    );
  }
}
