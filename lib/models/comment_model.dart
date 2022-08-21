import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  Comment({
    this.id = '',
    required this.createdBy,
    required this.text,
    required this.isReply,
    required this.timestamp,
    this.replies = const [],
    this.isDeleted = false,
    this.isRemoved = false,
    this.lastEdited,
  });

  String id, createdBy, text;
  bool isReply;
  bool isDeleted, isRemoved;
  List<String> replies;
  Timestamp timestamp;
  Timestamp? lastEdited;

  @override
  String toString() {
    return 'Comment(\n createdBy: $createdBy\n text: $text\n isReply: $isReply\n timestamp: $timestamp\n)';
  }
}

Comment commentFromFirestore(DocumentSnapshot snapshot, options) {
  Map data = snapshot.data() as Map;

  return Comment(
    id: snapshot.id,
    createdBy: data['createdBy'],
    isReply: data['isReply'],
    text: data['text'],
    replies: data['replies']?.cast<String>() ?? [],
    timestamp: data['timestamp'],
    isDeleted: data['isDeleted'] ?? false,
    isRemoved: data['isRemoved'] ?? false,
    lastEdited: data['lastEdited'],
  );
}

Map<String, Object> commentToFirestore(Comment comment, SetOptions? options) {
  return {
    'createdBy': comment.createdBy,
    'text': comment.text,
    'isReply': comment.isReply,
    'timestamp': comment.timestamp,
  };
}
