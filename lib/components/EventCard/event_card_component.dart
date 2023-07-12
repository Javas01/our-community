import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:our_ummah/actions/show_popup_menu_action.dart';
import 'package:our_ummah/components/EventCard/expanded_event_card.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/post_model.dart';
import 'package:our_ummah/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:our_ummah/components/EventCard/preview_event_card_component.dart';

class EventCardComponent extends StatefulWidget {
  const EventCardComponent({
    Key? key,
    required this.postCreator,
    required this.post,
    required this.users,
  }) : super(key: key);

  final EventPost post;
  final AppUser postCreator;
  final List<AppUser> users;

  @override
  State<EventCardComponent> createState() => _EventCardComponentState();
}

class _EventCardComponentState extends State<EventCardComponent> {
  final dataKey = GlobalKey();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  bool _isExpanded = false;
  Offset? _tapPosition;
  GlobalKey? _selectedPostKey;

  void setExpanded(bool isExpanded) {
    setState(() {
      _isExpanded = isExpanded;
    });

    if (!widget.post.hasSeen.contains(userId)) {
      final hasSeen = widget.post.hasSeen;
      hasSeen.add(userId);
      FirebaseFirestore.instance
          .collection('Communities')
          .doc(Provider.of<Community>(context, listen: false).id)
          .collection('Posts')
          .doc(widget.post.id)
          .withConverter(
            fromFirestore: postFromFirestore,
            toFirestore: postToFirestore,
          )
          .update({'hasSeen': hasSeen});
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: dataKey,
      height: _isExpanded
          ? MediaQuery.of(context).size.height -
              (Scaffold.of(context).appBarMaxHeight! * 2)
          : null,
      child: _isExpanded
          ? ExpandedEventCard(
              users: widget.users,
              post: widget.post,
              setExpanded: setExpanded,
            )
          : GestureDetector(
              onLongPress: () async {
                setState(() {
                  _selectedPostKey = dataKey;
                });
                await showPopupMenu(context, widget.post, _tapPosition!);
                setState(() {
                  _selectedPostKey = null;
                });
              },
              onTapDown: _storePosition,
              onTap: () {
                setExpanded(true);
                Future.delayed(const Duration(milliseconds: 50), () {
                  Scrollable.ensureVisible(
                    dataKey.currentContext!,
                    alignment: 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                });
              },
              child: PreviewEventCard(
                itemKey: dataKey,
                post: widget.post,
                postCreator: widget.postCreator,
                isSelected: dataKey == _selectedPostKey ? true : false,
                isCreator: userId == widget.post.createdBy,
              ),
            ),
    );
  }
}
