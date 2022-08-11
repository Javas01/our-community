import 'package:flutter/material.dart';
import 'package:our_community/components/onboard_content_component.dart';
import 'package:our_community/screens/login_screen.dart';

import '../../components/dot_indicator_component.dart';
import 'onboarding_config.dart';

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
                style: ElevatedButton.styleFrom(shape: const CircleBorder()),
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
