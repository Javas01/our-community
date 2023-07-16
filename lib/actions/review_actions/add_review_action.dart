import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_ummah/models/review_model.dart';

void addReview(
  BuildContext context,
  double rating,
  String reviewText,
  String businessId,
  String communityId,
  String userId,
) async {
  final reviewsRef = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityId)
      .collection('Businesses')
      .doc(businessId)
      .collection('Reviews')
      .withConverter(
        fromFirestore: reviewFromFirestore,
        toFirestore: reviewToFirestore,
      );

  try {
    final newReview = Review(
      createdBy: userId,
      rating: rating,
      reviewText: reviewText,
      timestamp: Timestamp.now(),
    );

    reviewsRef.add(newReview);
  } catch (e) {
    Future.error('Failed to add comment: $e');
  }
}
