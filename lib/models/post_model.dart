import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { text, image, event }

class PostCreator {
  PostCreator({
    required this.id,
    required this.name,
    required this.picUrl,
  });

  String id, name, picUrl;
}

abstract class Post {
  Post({
    this.id = '',
    required this.createdBy,
    required this.description,
    required this.tags,
    required this.type,
    required this.timestamp,
    required this.isAd,
    this.hasSeen = const [],
    this.upVotes = const [],
    this.downVotes = const [],
    this.lastEdited,
  });

  bool isAd;
  String id, createdBy, description;
  PostType type;
  List<String> tags, upVotes, downVotes, hasSeen;
  Timestamp timestamp;
  Timestamp? lastEdited;
}

class ImagePost extends Post {
  ImagePost({
    super.id,
    required super.isAd,
    required super.createdBy,
    required super.description,
    required super.tags,
    super.type = PostType.image,
    required super.timestamp,
    required this.imageUrl,
    super.hasSeen,
    super.downVotes,
    super.lastEdited,
    super.upVotes,
  });

  String imageUrl;

  @override
  String toString() =>
      'ImagePost(\n createdBy: $createdBy\n description: $description\n imageUrl: $imageUrl\n tags: $tags\n type: $type\n hasSeen: $hasSeen\n $timestamp\n)';
}

class TextPost extends Post {
  TextPost({
    super.id,
    required super.isAd,
    required super.createdBy,
    required super.description,
    required super.tags,
    super.type = PostType.text,
    required super.timestamp,
    required this.title,
    super.hasSeen,
    super.downVotes,
    super.lastEdited,
    super.upVotes,
  });

  String title;

  @override
  String toString() =>
      'TextPost(\n createdBy: $createdBy\n title: $title\n description: $description\n tags: $tags\n type: $type\n hasSeen: $hasSeen\n $timestamp\n)';
}

class EventPost extends Post {
  EventPost({
    super.id,
    required super.isAd,
    required super.createdBy,
    required super.description,
    required super.tags,
    super.type = PostType.event,
    required super.timestamp,
    required this.title,
    required this.location,
    required this.audience,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    super.hasSeen,
    super.downVotes,
    super.lastEdited,
    super.upVotes,
  });

  String title,
      location,
      audience,
      price,
      imageUrl; // TODO: Make audience and price enum
  DateTime startDate, endDate;

  @override
  String toString() =>
      'EventPost(\n createdBy: $createdBy\n title: $title\n description: $description\n tags: $tags\n type: $type\n hasSeen: $hasSeen\n $startDate\n $timestamp\n)';
}

Post postFromFirestore(DocumentSnapshot snapshot, options) {
  Map data = snapshot.data() as Map;
  final PostType postType = () {
    switch (data['type'] as String) {
      case 'text':
        return PostType.text;
      case 'image':
        return PostType.image;
      case 'event':
        return PostType.event;
      default:
        return PostType.text;
    }
  }();

  switch (postType) {
    case PostType.text:
      return TextPost(
        id: snapshot.id,
        isAd: data['isAd'] ?? false,
        createdBy: data['createdBy'],
        description: data['description'],
        tags: data['tags'].cast<String>(),
        type: postType,
        timestamp: data['timestamp'],
        title: data['title'],
        upVotes: data['upVotes']?.cast<String>() ?? [],
        downVotes: data['downVotes']?.cast<String>() ?? [],
        lastEdited: data['lastEdited'],
        hasSeen: data['hasSeen']?.cast<String>() ?? [],
      );
    case PostType.image:
      return ImagePost(
        id: snapshot.id,
        isAd: data['isAd'] ?? false,
        createdBy: data['createdBy'],
        description: data['description'],
        tags: data['tags'].cast<String>(),
        type: postType,
        timestamp: data['timestamp'],
        imageUrl: data['imageUrl'],
        upVotes: data['upVotes']?.cast<String>() ?? [],
        downVotes: data['downVotes']?.cast<String>() ?? [],
        lastEdited: data['lastEdited'],
        hasSeen: data['hasSeen']?.cast<String>() ?? [],
      );
    case PostType.event:
      return EventPost(
        id: snapshot.id,
        isAd: data['isAd'] ?? false,
        createdBy: data['createdBy'],
        description: data['description'],
        tags: data['tags']?.cast<String>() ?? [],
        type: postType,
        timestamp: data['timestamp'],
        title: data['title'],
        location: data['location'],
        audience: data['audience'],
        imageUrl: data['imageUrl'] ?? '',
        price: data['price'],
        startDate: data['startDate'].toDate(),
        endDate: data['endDate'].toDate(),
        upVotes: data['upVotes']?.cast<String>() ?? [],
        downVotes: data['downVotes']?.cast<String>() ?? [],
        lastEdited: data['lastEdited'],
        hasSeen: data['hasSeen']?.cast<String>() ?? [],
      );
  }
}

Map<String, Object> postToFirestore(Post post, SetOptions? options) {
  switch (post.type) {
    case PostType.text:
      return {
        'isAd': post.isAd,
        'createdBy': post.createdBy,
        'title': (post as TextPost).title,
        'description': post.description,
        'tags': post.tags,
        'type': post.type.name,
        'timestamp': post.timestamp,
      };
    case PostType.image:
      return {
        'isAd': post.isAd,
        'createdBy': post.createdBy,
        'imageUrl': (post as ImagePost).imageUrl,
        'description': post.description,
        'tags': post.tags,
        'type': post.type.name,
        'timestamp': post.timestamp,
      };
    case PostType.event:
      return {
        'isAd': post.isAd,
        'createdBy': post.createdBy,
        'title': (post as EventPost).title,
        'imageUrl': post.imageUrl,
        'description': post.description,
        'location': post.location,
        'audience': post.audience,
        'price': post.price,
        'startDate': post.startDate,
        'endDate': post.endDate,
        'tags': post.tags,
        'type': post.type.name,
        'timestamp': post.timestamp,
      };
  }
}
