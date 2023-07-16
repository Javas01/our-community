import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_ummah/models/business_model.dart';
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

  final businessRef = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityId)
      .collection('Businesses')
      .doc(businessId)
      .withConverter(
        fromFirestore: businessFromFirestore,
        toFirestore: businessToFirestore,
      );

  try {
    final newReview = Review(
      createdBy: userId,
      rating: rating,
      reviewText: reviewText,
      timestamp: Timestamp.now(),
    );

    reviewsRef.add(newReview);

    final business = await businessRef.get();
    final businessData = business.data();

    final newRating =
        (businessData!.rating * businessData.reviewCount + rating) /
            (businessData.reviewCount + 1);

    businessRef.update({
      'rating': newRating,
      'reviewCount': FieldValue.increment(1),
    });
  } catch (e) {
    Future.error('Failed to add comment: $e');
  }
}
