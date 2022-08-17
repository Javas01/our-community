import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  Post({
    required this.id,
    required this.createdBy,
    required this.description,
    required this.title,
    required this.tags,
    required this.timestamp,
    required this.type,
    this.downVotes,
    this.lastEdited,
    this.upVotes,
  });

  String id, createdBy, description, title, type;
  List<String> tags;
  List<String>? upVotes, downVotes;
  Timestamp timestamp;
  Timestamp? lastEdited;
}

Post postFromFirestore(DocumentSnapshot snapshot, options) {
  Map data = snapshot.data() as Map;

  return Post(
    id: snapshot.id,
    createdBy: data['createdBy'],
    description: data['description'],
    title: data['title'],
    tags: data['tags'].cast<String>(),
    timestamp: data['timestamp'],
    type: data['type'],
  );
}

Map<String, Object> postToFirestore(Post post, SetOptions? options) {
  return {
    'createdBy': {post.createdBy},
    'description': {post.description},
    'title': {post.title},
    'tags': {post.tags},
    'timestamp': {post.timestamp},
    'type': {post.type}
  };
}
