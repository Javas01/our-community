import 'package:flutter/material.dart';
import 'package:our_ummah/actions/review_actions/add_review_action.dart';
import 'package:our_ummah/actions/review_actions/edit_review_action.dart';
import 'package:our_ummah/models/business_model.dart';
import 'package:our_ummah/models/community_model.dart';
import 'package:our_ummah/models/review_model.dart';
import 'package:our_ummah/models/user_model.dart';

class BusinessRatingModal extends StatefulWidget {
  const BusinessRatingModal({
    super.key,
    required this.business,
    required this.community,
    required this.user,
    required this.review,
  });

  final Business business;
  final Community community;
  final AppUser user;
  final Review? review;

  @override
  State<BusinessRatingModal> createState() => _BusinessRatingModalState();
}

class _BusinessRatingModalState extends State<BusinessRatingModal> {
  int _rating = 0;
  final reviewController = TextEditingController();

  @override
  void initState() {
    if (widget.review != null) {
      _rating = widget.review!.rating.toInt();
      reviewController.text = widget.review!.reviewText;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.review != null
            ? 'Chage your review'
            : 'How was your experience?',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating
                        ? Icons.thumb_up_sharp
                        : Icons.thumb_up_alt_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ],
          ),
          TextField(
            controller: reviewController,
            decoration: const InputDecoration(
              hintText: 'Write your review here',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            minLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => {
            if (reviewController.text.isEmpty)
              {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please write a review'),
                  ),
                ),
              }
            else if (_rating == 0)
              {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a rating'),
                  ),
                ),
              }
            else
              {
                if (widget.review != null)
                  {
                    editReview(
                      context,
                      _rating.toDouble(),
                      reviewController.text,
                      widget.business.id,
                      widget.community.id,
                      widget.user.id,
                      widget.review!.id,
                    ),
                  }
                else
                  {
                    addReview(
                      context,
                      _rating.toDouble(),
                      reviewController.text,
                      widget.business.id,
                      widget.community.id,
                      widget.user.id,
                    ),
                  },
                Navigator.pop(context),
              }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
