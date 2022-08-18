import 'package:flutter/material.dart';

class TagFilter extends StatelessWidget {
  const TagFilter({
    Key? key,
    required this.name,
    required this.color,
    required this.selectedTag,
    required this.selectTagFilter,
  }) : super(key: key);

  final String name, selectedTag;
  final MaterialAccentColor color;
  final Function selectTagFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: OutlinedButton(
        onPressed: () {
          selectTagFilter(name);
        },
        focusNode: FocusNode(),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            selectedTag == name ? color : color.withOpacity(0.3),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          elevation: selectedTag == name ? MaterialStateProperty.all(5) : null,
        ),
        child: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
