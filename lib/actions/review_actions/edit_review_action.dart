import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_ummah/models/business_model.dart';

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
    review.update(({
      'rating': rating,
      'reviewText': reviewText,
      'lastEdited': Timestamp.now(),
    }));

    final business = await businessRef.get();
    final businessData = business.data();

    final updatedRating = (businessData!.rating * businessData.reviewCount -
            businessData.rating +
            rating) /
        businessData.reviewCount;

    businessRef.update({
      'rating': updatedRating,
    });
  } catch (e) {
    Future.error('Failed to edit review: $e');
  }
}
