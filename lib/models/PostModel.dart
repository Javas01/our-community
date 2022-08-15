// import 'package:cloud_firestore/cloud_firestore.dart';

// class Post {
//   String title, description;
//   List<String> upVotes, downVotes, tags;
//   Map createdBy;
//   Timestamp timestamp;
//   Timestamp? lastEdited;

//   Post({
//     required this.title,
//     required this.description,
//     required this.upVotes,
//     required this.downVotes,
//     required this.tags,
//     required this.createdBy,
//     required this.timestamp,
//     this.lastEdited,
//   });

//   Post.fromJson(Map<String, dynamic> json) {
//     title = json['title'] ?? '';
//     description = json['description'];
//     upVotes = json['upVotes'];
//     downVotes = json['downVotes'];
//     timestamp = json['timestamp'];
//     tags = json['tags'];
//     lastEdited = json['lastEdited'];
//     createdBy = json['createdBy'];
//   }

//   // Map<String, dynamic> toJson() {
//   //   final Map<String, dynamic> data = new Map<String, dynamic>();
//   //   data['bookingId'] = this.bookingId;
//   //   data['userId'] = this.userId;
//   //   data['vendorId'] = this.vendorId;
//   //   data['mealName'] = this.mealName;
//   //   data['timestamp'] = this.timestamp;
//   //   data['paymentStatus'] = this.paymentStatus;
//   //   data['mealPrice'] = this.mealPrice;
//   //   return data;
//   // }
// }
