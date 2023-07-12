import 'package:cloud_firestore/cloud_firestore.dart';

class Business {
  Business({
    this.id = '',
    this.rating = 0.0,
    required this.title,
    required this.tagline,
    required this.address,
    required this.tags,
    this.businessLogoUrl = '',
  });

  String id, title, tagline, address, businessLogoUrl;
  double rating;
  List<String> tags;

  @override
  String toString() {
    return 'Business(\n title: $title\n tagline: $tagline\n address: $address\n)';
  }
}

Business businessFromFirestore(DocumentSnapshot snapshot, options) {
  Map data = snapshot.data() as Map;

  return Business(
    id: snapshot.id,
    title: data['title'],
    tagline: data['tagline'],
    address: data['address'],
    rating: double.parse(data['rating'].toString()),
    tags: data['tags'].cast<String>(),
    businessLogoUrl: data['businessLogoUrl'] ?? '',
  );
}

Map<String, Object> businessToFirestore(
    Business business, SetOptions? options) {
  return {
    'title': business.title,
    'tagline': business.tagline,
    'address': business.address,
    'rating': business.rating,
    'tags': business.tags,
  };
}
