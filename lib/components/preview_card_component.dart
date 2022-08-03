import 'package:flutter/material.dart';

class PreviewCard extends StatefulWidget {
  const PreviewCard(
      {Key? key,
      required this.image,
      required this.title,
      required this.description,
      required this.toggleExpanded})
      : super(key: key);

  final String image, title, description;
  final VoidCallback toggleExpanded;

  @override
  State<PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<PreviewCard> {
  int _voteCount = 0;
  bool _isUpvoted = false;
  bool _isDownvoted = false;

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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Scrollable.ensureVisible(
                              context,
                              alignment: 0.0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                            widget.toggleExpanded();
                          },
                          child: const Icon(
                            Icons.chat_outlined,
                            size: 18,
                          ),
                        ),
                        Row(
                          children: [
                            Text('$_voteCount'),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_isUpvoted) {
                                    _isUpvoted = false;
                                    _voteCount -= 1;
                                  } else if (_isDownvoted) {
                                    _isUpvoted = true;
                                    _isDownvoted = false;
                                    _voteCount += 2;
                                  } else {
                                    _isUpvoted = true;
                                    _voteCount += 1;
                                  }
                                });
                              },
                              child: Icon(Icons.keyboard_arrow_up_outlined,
                                  color: _isUpvoted ? Colors.redAccent : null,
                                  size: _isUpvoted ? 22.0 : 20.0),
                            ),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_isDownvoted) {
                                      _isDownvoted = false;
                                      _voteCount += 1;
                                    } else if (_isUpvoted) {
                                      _isDownvoted = true;
                                      _isUpvoted = false;
                                      _voteCount -= 2;
                                    } else {
                                      _isDownvoted = true;
                                      _voteCount -= 1;
                                    }
                                  });
                                },
                                child: Icon(Icons.keyboard_arrow_down_outlined,
                                    color:
                                        _isDownvoted ? Colors.redAccent : null,
                                    size: _isDownvoted ? 22.0 : 20.0))
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ))
            ],
          ),
        ));
  }
}
