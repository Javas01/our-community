import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  Post({
    this.id = '',
    required this.createdBy,
    required this.title,
    required this.description,
    required this.tags,
    required this.type,
    required this.timestamp,
    this.upVotes = const [],
    this.downVotes = const [],
    this.lastEdited,
  });

  String id, createdBy, description, title, type;
  List<String> tags, upVotes, downVotes;
  Timestamp timestamp;
  Timestamp? lastEdited;

  @override
  String toString() {
    return 'Post(\n createdBy: $createdBy\n title: $title\n description: $description\n tags: $tags\n type: $type\n timestamp: $timestamp\n)';
  }
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
    upVotes: data['upVotes']?.cast<String>() ?? [],
    downVotes: data['downVotes']?.cast<String>() ?? [],
    lastEdited: data['lastEdited'],
  );
}

Map<String, Object> postToFirestore(Post post, SetOptions? options) {
  return {
    'createdBy': post.createdBy,
    'title': post.title,
    'description': post.description,
    'tags': post.tags,
    'type': post.type,
    'timestamp': post.timestamp,
  };
}
