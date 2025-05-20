import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user-data.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  final Function(User) onSave;

  const ProfilePage({Key? key, required this.user, required this.onSave})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User editedUser;
  bool isEditing = false;

  final List<String> ageOptions = List.generate(61, (index) => '${index + 10}');
  final List<String> weightOptions =
      List.generate(40, (index) => '${40 + index} kg');
  final List<String> heightOptions =
      List.generate(51, (index) => '${150 + index} cm');
  final List<String> activityOptions = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active'
  ];
  final List<String> goalOptions =
      List.generate(16, (index) => '${1500 + (index * 250)} ml');
  final List<String> reminderOptions = [
    '1 min',
    '30 min',
    '1 hour',
    '2 hours',
    '3 hours',
    '4 hours'
  ];

  @override
  void initState() {
    super.initState();
    // Create a copy of the user to edit
    editedUser = User(
      name: widget.user.name,
      email: widget.user.email,
      password: widget.user.password,
      age: widget.user.age,
      activityLevel: widget.user.activityLevel,
      weight: widget.user.weight,
      height: widget.user.height,
      goal: widget.user.goal,
      reminder: widget.user.reminder,
    );
  }

  void updateRecommendedGoal() {
    int weight = int.parse(editedUser.weight.split(' ')[0]);
    int height = int.parse(editedUser.height.split(' ')[0]);
    int age = int.parse(editedUser.age);
    int activityFactor = activityOptions.indexOf(editedUser.activityLevel) + 1;

    int calculatedGoal =
        ((weight * 30) + (height * 3) - (age * 2) + (activityFactor * 100))
            .toInt();
    calculatedGoal =
        (calculatedGoal / 250).round() * 250; // Round to nearest 250ml

    setState(() {
      editedUser.recommendedGoal = "$calculatedGoal ml";
    });
  }

  void saveChanges() {
    widget.onSave(editedUser);
    setState(() {
      isEditing = false;
    });
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: isEditing ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F5E8C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0F5E8C),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (isEditing)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF0F5E8C),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _showPicker({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String currentValue,
    required Function(String) onValueChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    updateRecommendedGoal();
                  },
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F5E8C),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: options.indexOf(currentValue),
                ),
                onSelectedItemChanged: (index) {
                  onValueChanged(options[index]);
                },
                children: options.map((option) {
                  return Center(
                    child: Text(
                      option,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color(0xFF0F5E8C), // Makes the back arrow blue
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F5E8C),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (isEditing) {
                  saveChanges();
                } else {
                  isEditing = true;
                }
              });
            },
            child: Text(
              isEditing ? "Save" : "Edit",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F5E8C),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Avatar and Name
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F5E8C).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/water_drop_avatar.png', // Make sure to add this image asset
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.water_drop,
                              size: 50,
                              color: const Color(0xFF0F5E8C),
                            ),
                          ),
                        ),
                      ),
                      if (isEditing)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F5E8C),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    editedUser.name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_drink_outlined,
                        color: Color(0xFF0F5E8C),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Daily goal: ${editedUser.goal}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Personal Information",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F5E8C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoTile(
                    title: "Age",
                    value: "${editedUser.age} years",
                    icon: Icons.cake_outlined,
                    onTap: () {
                      _showPicker(
                        context: context,
                        title: "Select Age",
                        options: ageOptions,
                        currentValue: editedUser.age,
                        onValueChanged: (value) {
                          setState(() {
                            editedUser.age = value;
                          });
                        },
                      );
                    },
                  ),
                  _buildInfoTile(
                    title: "Weight",
                    value: editedUser.weight,
                    icon: Icons.monitor_weight_outlined,
                    onTap: () {
                      _showPicker(
                        context: context,
                        title: "Select Weight",
                        options: weightOptions,
                        currentValue: editedUser.weight,
                        onValueChanged: (value) {
                          setState(() {
                            editedUser.weight = value;
                          });
                        },
                      );
                    },
                  ),
                  _buildInfoTile(
                    title: "Height",
                    value: editedUser.height,
                    icon: Icons.height_outlined,
                    onTap: () {
                      _showPicker(
                        context: context,
                        title: "Select Height",
                        options: heightOptions,
                        currentValue: editedUser.height,
                        onValueChanged: (value) {
                          setState(() {
                            editedUser.height = value;
                          });
                        },
                      );
                    },
                  ),
                  _buildInfoTile(
                    title: "Activity Level",
                    value: editedUser.activityLevel,
                    icon: Icons.directions_run_outlined,
                    onTap: () {
                      _showPicker(
                        context: context,
                        title: "Select Activity Level",
                        options: activityOptions,
                        currentValue: editedUser.activityLevel,
                        onValueChanged: (value) {
                          setState(() {
                            editedUser.activityLevel = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "App Settings",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F5E8C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoTile(
                    title: "Daily Water Goal",
                    value: editedUser.goal,
                    icon: Icons.local_drink_outlined,
                    onTap: () {
                      _showPicker(
                        context: context,
                        title: "Select Daily Goal",
                        options: goalOptions,
                        currentValue: editedUser.goal,
                        onValueChanged: (value) {
                          setState(() {
                            editedUser.goal = value;
                          });
                        },
                      );
                    },
                  ),
                  if (editedUser.recommendedGoal != null &&
                      editedUser.recommendedGoal!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 16),
                      child: Text(
                        "Recommended: ${editedUser.recommendedGoal}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  _buildInfoTile(
                    title: "Reminder Frequency",
                    value: editedUser.reminder,
                    icon: Icons.notifications_active_outlined,
                    onTap: () {
                      _showPicker(
                        context: context,
                        title: "Select Reminder Frequency",
                        options: reminderOptions,
                        currentValue: editedUser.reminder,
                        onValueChanged: (value) {
                          setState(() {
                            editedUser.reminder = value;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
