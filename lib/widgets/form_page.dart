import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user-data.dart';

class FormPage extends StatefulWidget {
  final User user;
  final Function() onComplete;

  const FormPage({Key? key, required this.user, required this.onComplete}) : super(key: key);

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  late String selectedAge;
  late String selectedActivity;
  late String selectedWeight;
  late String selectedHeight;
  late String selectedGoal;
  late String selectedReminder;
  late String recommendedGoal;
  int currentPage = 0;
  final PageController _pageController = PageController();

  final List<String> ageOptions = List.generate(61, (index) => '${index + 10}');
  final List<String> weightOptions = List.generate(40, (index) => '${40 + index} kg');
  final List<String> heightOptions = List.generate(51, (index) => '${150 + index} cm');
  final List<String> activityOptions = [
    'Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'
  ];
  final List<String> goalOptions = List.generate(16, (index) => '${1500 + (index * 250)} ml');
  final List<String> reminderOptions = [
        '1 min' ,'30 min', '1 hour', '2 hours', '3 hours', '4 hours'
  ];

  @override
  void initState() {
    super.initState();
    selectedAge = widget.user.age;
    selectedActivity = widget.user.activityLevel;
    selectedWeight = widget.user.weight;
    selectedHeight = widget.user.height;
    selectedGoal = widget.user.goal;
    selectedReminder = widget.user.reminder;
    updateRecommendedGoal();
  }

  void updateRecommendedGoal() {
    setState(() {
      int weight = int.parse(selectedWeight.split(' ')[0]);
      int height = int.parse(selectedHeight.split(' ')[0]);
      int age = int.parse(selectedAge);
      int activityFactor = activityOptions.indexOf(selectedActivity) + 1;

      int calculatedGoal = ((weight * 30) + (height * 3) - (age * 2) + (activityFactor * 100)).toInt();
      calculatedGoal = (calculatedGoal / 250).round() * 250; // Round to nearest 250ml
      recommendedGoal = "$calculatedGoal ml";
    });
  }

  void saveUserData() {
    widget.user.age = selectedAge;
    widget.user.activityLevel = selectedActivity;
    widget.user.weight = selectedWeight;
    widget.user.height = selectedHeight;
    widget.user.goal = selectedGoal;
    widget.user.reminder = selectedReminder;
    widget.onComplete();
  }

  Widget _buildPickerPage({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> options,
    required String selectedValue,
    required Function(String) onValueChanged,
    String? additionalText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 70,
            color: const Color(0xFF0F5E8C),
          ),
          const SizedBox(height: 30),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F5E8C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CupertinoPicker(
              itemExtent: 40,
              backgroundColor: Colors.white,
              scrollController: FixedExtentScrollController(
                initialItem: options.indexOf(selectedValue),
              ),
              onSelectedItemChanged: (index) {
                onValueChanged(options[index]);
              },
              children: options.map((option) {
                return Center(
                  child: Text(
                    option,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (additionalText != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                additionalText,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF0F5E8C),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  currentPage > 0
                      ? GestureDetector(
                          onTap: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Color(0xFF0F5E8C),
                              size: 22,
                            ),
                          ),
                        )
                      : const SizedBox(width: 38),
                  Text(
                    "Step ${currentPage + 1}/6",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  currentPage < 5
                      ? GestureDetector(
                          onTap: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFF0F5E8C),
                              size: 22,
                            ),
                          ),
                        )
                      : const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    currentPage = page;
                  });
                },
                children: [
                  _buildPickerPage(
                    title: "How old are you?",
                    subtitle: "We'll use this to calculate your ideal water intake",
                    icon: Icons.cake_outlined,
                    options: ageOptions,
                    selectedValue: selectedAge,
                    onValueChanged: (value) {
                      setState(() {
                        selectedAge = value;
                        updateRecommendedGoal();
                      });
                    },
                  ),
                  _buildPickerPage(
                    title: "Activity Level",
                    subtitle: "How would you describe your daily activity?",
                    icon: Icons.directions_run_outlined,
                    options: activityOptions,
                    selectedValue: selectedActivity,
                    onValueChanged: (value) {
                      setState(() {
                        selectedActivity = value;
                        updateRecommendedGoal();
                      });
                    },
                  ),
                  _buildPickerPage(
                    title: "Your Weight",
                    subtitle: "This helps determine your hydration needs",
                    icon: Icons.monitor_weight_outlined,
                    options: weightOptions,
                    selectedValue: selectedWeight,
                    onValueChanged: (value) {
                      setState(() {
                        selectedWeight = value;
                        updateRecommendedGoal();
                      });
                    },
                  ),
                  _buildPickerPage(
                    title: "Your Height",
                    subtitle: "Another factor for your personalized plan",
                    icon: Icons.height_outlined,
                    options: heightOptions,
                    selectedValue: selectedHeight,
                    onValueChanged: (value) {
                      setState(() {
                        selectedHeight = value;
                        updateRecommendedGoal();
                      });
                    },
                  ),
                  _buildPickerPage(
                    title: "Daily Water Goal",
                    subtitle: "How much water do you want to drink daily?",
                    icon: Icons.local_drink_outlined,
                    options: goalOptions,
                    selectedValue: selectedGoal,
                    onValueChanged: (value) {
                      setState(() {
                        selectedGoal = value;
                      });
                    },
                    additionalText: "Recommended: $recommendedGoal",
                  ),
                  _buildPickerPage(
                    title: "Reminder Frequency",
                    subtitle: "How often should we remind you to drink water?",
                    icon: Icons.notifications_active_outlined,
                    options: reminderOptions,
                    selectedValue: selectedReminder,
                    onValueChanged: (value) {
                      setState(() {
                        selectedReminder = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  if (currentPage < 5) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    saveUserData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F5E8C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  currentPage < 5 ? "Continue" : "Complete Setup",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}