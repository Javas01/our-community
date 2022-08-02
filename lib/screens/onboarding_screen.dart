import 'package:flutter/material.dart';
import 'package:our_community/components/onboard_content_component.dart';
import 'package:our_community/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  int _pageIndex = 0;
  bool isLastPage = false;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Expanded(
              child: PageView.builder(
                  itemCount: onboardPages.length,
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _pageIndex = index;
                      isLastPage = index == onboardPages.length - 1;
                    });
                  },
                  itemBuilder: (context, index) => OnboardContent(
                      image: onboardPages[index].image,
                      title: onboardPages[index].title,
                      description: onboardPages[index].description)),
            ),
            Row(
              children: [
                ...List.generate(
                    onboardPages.length,
                    (index) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: DotIndicator(isActive: index == _pageIndex))),
                const Spacer(),
                SizedBox(
                  height: 60,
                  width: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      !isLastPage
                          ? _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease)
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                    },
                    style:
                        ElevatedButton.styleFrom(shape: const CircleBorder()),
                    child: isLastPage
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            )
          ]),
        )));
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    Key? key,
    this.isActive = false,
  }) : super(key: key);

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isActive ? 12 : 4,
      width: 4,
      decoration: BoxDecoration(
          color:
              isActive ? Colors.redAccent : Colors.redAccent.withOpacity(0.4),
          borderRadius: const BorderRadius.all(Radius.circular(12))),
    );
  }
}

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
    image: "assets/news.jpg",
    title: "Share",
    description:
        "Share news, events, gripes, accomplishments, etc. going on in our community that you feel everyone should know.",
  ),
  Onboard(
    image: "assets/discuss.jpg",
    title: "Discuss",
    description:
        "Discuss important community topics and make sure that your voice is heard!",
  ),
  Onboard(
    image: "assets/vote.jpg",
    title: "Vote",
    description:
        "Upvote or downvote to make sure that the important conversations gain visibility.",
  )
];
