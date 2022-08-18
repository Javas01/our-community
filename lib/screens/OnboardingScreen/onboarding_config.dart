class Onboard {
  final String image, title, description;

  Onboard({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<Onboard> onboardPages = [
  Onboard(
    image: 'assets/news.jpg',
    title: 'Share',
    description:
        'Ask questions or share open ended discussion topics about things going on in our community that you feel everyone should know.',
  ),
  Onboard(
    image: 'assets/discuss.jpg',
    title: 'Discuss',
    description:
        'Discuss important community topics and make sure that your voice is heard!',
  ),
  Onboard(
    image: 'assets/vote.jpg',
    title: 'Vote',
    description:
        'Upvote or downvote to make sure that the important conversations gain visibility.',
  )
];
