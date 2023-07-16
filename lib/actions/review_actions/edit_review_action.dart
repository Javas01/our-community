import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void editReview(
  BuildContext context,
  double rating,
  String reviewText,
  String businessId,
  String communityId,
  String userId,
  String reviewId,
) async {
  DocumentReference review = FirebaseFirestore.instance
      .collection('Communities')
      .doc(communityId)
      .collection('Businesses')
      .doc(businessId)
      .collection('Reviews')
      .doc(reviewId);

  try {
    review.update(({
      'rating': rating,
      'reviewText': reviewText,
      'lastEdited': Timestamp.now(),
    }));
  } catch (e) {
    Future.error('Failed to edit review: $e');
  }
}
