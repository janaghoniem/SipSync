import 'package:flutter/material.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/form_page.dart';
import '../widgets/bottom_sheet.dart';
import '../user-data.dart';
import "../screens/userdashboard.dart";

class GettingStartedScreen extends StatefulWidget {
  final User user;

  const GettingStartedScreen({super.key, required this.user});

  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<GettingStartedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onFormComplete() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => H2OClockDashboard(user: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              OnboardingPage(
                title: "Hello ${widget.user.name}!",
                subtitle: "Welcome to SipSync!",
                text: "Track your daily water intake with just a few taps!",
                imagePath: "assets/page1_bg.png",
                size: 38,
              ),
              OnboardingPage(
                title: "Let's personalize your experience..",
                subtitle: "Details, Details..",
                text: "To help you stay hydrated & calculate your water intake goal, we need a few details about you.",
                imagePath: "assets/page2_bg.png",
                size: 31,
              ),
              FormPage(
                user: widget.user,
                onComplete: _onFormComplete,
              ),
            ],
          ),
          if (_currentPage < 2) // Only show bottom sheet for onboarding pages
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: BottomSheetWidget(
                pageController: _pageController,
                currentPage: _currentPage,
                user: widget.user,
              ),
            ),
        ],
      ),
    );
  }
}