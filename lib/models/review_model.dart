import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  Review({
    this.id = '',
    required this.createdBy,
    required this.reviewText,
    required this.rating,
    required this.timestamp,
    this.isDeleted = false,
    this.isRemoved = false,
    this.lastEdited,
  });

  String id, createdBy, reviewText;
  bool isDeleted, isRemoved;
  double rating;
  Timestamp timestamp;
  Timestamp? lastEdited;

  @override
  String toString() {
    return 'Review(\n createdBy: $createdBy\n text: $reviewText\n rating: $rating\n timestamp: $timestamp\n)';
  }
}

Review reviewFromFirestore(DocumentSnapshot snapshot, options) {
  Map data = snapshot.data() as Map;

  return Review(
    id: snapshot.id,
    createdBy: data['createdBy'],
    reviewText: data['reviewText'],
    rating: double.parse(data['rating'].toString()),
    timestamp: data['timestamp'],
    isDeleted: data['isDeleted'] ?? false,
    isRemoved: data['isRemoved'] ?? false,
    lastEdited: data['lastEdited'],
  );
}

Map<String, Object> reviewToFirestore(Review review, SetOptions? options) {
  return {
    'createdBy': review.createdBy,
    'reviewText': review.reviewText,
    'rating': review.rating,
    'timestamp': review.timestamp,
  };
}
