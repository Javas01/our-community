import 'package:flutter/material.dart';

class PostCommentsModel extends ChangeNotifier {
  final expandedCardKey = GlobalKey<ScaffoldState>();
  bool _isReply = false;
  String _parentCommentText = '';
  List<String> _parentCommentReplies = [];
  String _parentCommentId = '';
  // focusnode

  void reply(
    String parentCommentText,
    List<String> parentCommentReplies,
    String parentCommentId,
  ) {
    _isReply = true;
    _parentCommentText = parentCommentText;
    _parentCommentReplies = parentCommentReplies;
    _parentCommentId = parentCommentId;
    notifyListeners();
  }

  void reset() {
    _isReply = false;
    _parentCommentText = '';
    _parentCommentReplies = [];
    _parentCommentId = '';
    notifyListeners();
  }

  bool get isReply => _isReply;
  String get parentCommentText => _parentCommentText;
  List<String> get parentCommentReplies => _parentCommentReplies;
  String get parentCommentId => _parentCommentId;
}
