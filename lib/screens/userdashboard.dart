import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'history.dart';
import 'profile.dart';
import '../user-data.dart';
import 'notification_service.dart';

class H2OClockDashboard extends StatefulWidget {
  final User user;
  const H2OClockDashboard({super.key, required this.user});
  
  @override
  _H2OClockDashboardState createState() => _H2OClockDashboardState();
}

class _H2OClockDashboardState extends State<H2OClockDashboard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _waveController1;
  late AnimationController _waveController2;
  late Animation<double> _progressAnimation;
  late Animation<double> _waveAnimation1;
  late Animation<double> _waveAnimation2;
  late NotificationService _notificationService;

  double _currentProgress = 0;
  double get dailyGoal => double.parse(widget.user.goal.replaceAll(' ml', ''));

  final Map<String, bool> _pressedStates = {
    'Water': false,
    'Sparkling Water': false,
    'Coffee': false,
    'Milk Tea': false,
    'Tea': false,
    'Milk': false,
  };

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    
    // Initialize current progress based on user data
    _currentProgress = (widget.user.currentIntake ?? 0) / dailyGoal * 100;

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _waveController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _waveController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _waveAnimation1 = Tween<double>(begin: 0, end: 2 * pi).animate(_waveController1);
    _waveAnimation2 = Tween<double>(begin: 0, end: 2 * pi).animate(_waveController2);

    _updateProgressAnimation();
    _progressController.forward();
    
    // Start reminders
    _startReminders();
  }

  Future<void> _startReminders() async {
    await _notificationService.schedulePeriodicNotifications(
      reminderFrequency: widget.user.reminder,
      goal: dailyGoal,
      currentIntake: widget.user.currentIntake ?? 0,
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _waveController1.dispose();
    _waveController2.dispose();
    super.dispose();
  }

  void _updateProgressAnimation() {
    _progressAnimation = Tween<double>(
      begin: _currentProgress,
      end: _currentProgress,
    ).animate(_progressController);
  }

  void _increaseProgress(String drinkType) {
    // Add different intake amounts based on drink type
    double intakeAmount = 250; // Default for water
    
    switch(drinkType) {
      case 'Water':
        intakeAmount = 250;
        break;
      case 'Sparkling Water':
        intakeAmount = 250;
        break;
      case 'Coffee':
        intakeAmount = 200;
        break;
      case 'Milk Tea':
        intakeAmount = 350;
        break;
      case 'Tea':
        intakeAmount = 200;
        break;
      case 'Milk':
        intakeAmount = 300;
        break;
    }
    
    final double targetProgress = (_currentProgress + (intakeAmount/dailyGoal*100)).clamp(0, 100);

    _progressAnimation =
        Tween<double>(begin: _currentProgress, end: targetProgress).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    _progressController.forward(from: 0).then((_) {
      setState(() {
        _currentProgress = targetProgress;
        widget.user.currentIntake = (targetProgress/100) * dailyGoal;
        
        // Update reminders with new intake
        _notificationService.schedulePeriodicNotifications(
          reminderFrequency: widget.user.reminder,
          goal: dailyGoal,
          currentIntake: widget.user.currentIntake ?? 0,
        );
        
        // Add to history
        widget.user.addHydrationRecord(DateTime.now(), intakeAmount);
      });
    });

    // Show feedback snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F5E8C),
        content: Text(
          '$drinkType added! +${intakeAmount.toInt()}ml',
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  HistoryPage(user: widget.user)),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            user: widget.user,
            onSave: (updatedUser) {
              setState(() {
                // Update the user data when returning from profile
                widget.user.age = updatedUser.age;
                widget.user.activityLevel = updatedUser.activityLevel;
                widget.user.weight = updatedUser.weight;
                widget.user.height = updatedUser.height;
                widget.user.goal = updatedUser.goal;
                widget.user.reminder = updatedUser.reminder;
                
                // Recalculate progress based on new goal
                final currentIntake = widget.user.currentIntake ?? 0;
                _currentProgress = (currentIntake / double.parse(widget.user.goal.replaceAll(' ml', ''))) * 100;
                _updateProgressAnimation();
                _progressController.forward(from: 0);
                
                // Update reminders with new settings
                _notificationService.schedulePeriodicNotifications(
                  reminderFrequency: widget.user.reminder,
                  goal: double.parse(widget.user.goal.replaceAll(' ml', '')),
                  currentIntake: currentIntake,
                );
              });
            },
          ),
        ),
      );
    }
  }

  void _saveProgress() {
    // Here you would implement saving progress to storage
    // For now, just showing a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F5E8C),
        content: Text(
          'Progress saved successfully!',
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message with user name
              Text(
                'Welcome, ${widget.user.name}!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F5E8C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stay hydrated today',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Daily Goal Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Daily Goal',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F5E8C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${dailyGoal.toInt()}ml',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F5E8C),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: CustomPaint(
                          painter: CircularWaveProgressPainter(
                            progress: _progressAnimation,
                            waveAnimation1: _waveAnimation1,
                            waveAnimation2: _waveAnimation2,
                            circleRadius: 90,
                            circleBgColor: const Color(0xFF0F5E8C).withOpacity(0.1),
                            circleProgressColor: const Color(0xFF0F5E8C),
                            progressTextColor: Colors.white,
                            progressTextSize: 26,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    Text(
                      '${((_currentProgress/100) * dailyGoal).toInt()}ml / ${dailyGoal.toInt()}ml',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F5E8C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Drink Options
              Text(
                'Choose a drink',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F5E8C),
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
                children: [
                  _buildDrinkOption(Icons.water_drop_outlined, 'Water'),
                  _buildDrinkOption(Icons.bubble_chart, 'Sparkling Water'),
                  _buildDrinkOption(Icons.coffee, 'Coffee'),
                  _buildDrinkOption(Icons.local_cafe_outlined, 'Milk Tea'),
                  _buildDrinkOption(Icons.emoji_food_beverage, 'Tea'),
                  _buildDrinkOption(Icons.local_drink_outlined, 'Milk'),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveProgress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5E8C),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'Save Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF0F5E8C),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkOption(IconData icon, String label) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedStates[label] = true),
      onTapUp: (_) => setState(() => _pressedStates[label] = false),
      onTapCancel: () => setState(() => _pressedStates[label] = false),
      onTap: () => _increaseProgress(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _pressedStates[label]! 
              ? const Color(0xFF0F5E8C)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0F5E8C).withOpacity(_pressedStates[label]! ? 1.0 : 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        transform: Matrix4.identity()
          ..scale(_pressedStates[label]! ? 0.96 : 1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 36,
              color: _pressedStates[label]!
                  ? Colors.white
                  : const Color(0xFF0F5E8C),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _pressedStates[label]!
                      ? Colors.white
                      : const Color(0xFF0F5E8C),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularWaveProgressPainter extends CustomPainter {
  final Animation<double> progress;
  final Animation<double> waveAnimation1;
  final Animation<double> waveAnimation2;
  final double circleRadius;
  final Color circleBgColor;
  final Color circleProgressColor;
  final Color progressTextColor;
  final double progressTextSize;

  CircularWaveProgressPainter({
    required this.progress,
    required this.waveAnimation1,
    required this.waveAnimation2,
    required this.circleRadius,
    required this.circleBgColor,
    required this.circleProgressColor,
    required this.progressTextColor,
    required this.progressTextSize,
  }) : super(
            repaint:
                Listenable.merge([progress, waveAnimation1, waveAnimation2]));

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);

    canvas.clipPath(Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: circleRadius)));

    _drawCircleProgress(canvas);
    _drawWave(canvas, waveAnimation1, 10.0, 0.5);
    _drawWave(canvas, waveAnimation2, 8.0, 0.3);
    _drawProgressText(canvas);
  }

  void _drawCircleProgress(Canvas canvas) {
    final circlePaint = Paint()
      ..color = circleBgColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawCircle(Offset.zero, circleRadius, circlePaint);

    final progressPaint = Paint()
      ..color = circleProgressColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    double clampedProgress = progress.value.clamp(0, 100);

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: circleRadius),
      -0.5 * pi,
      2 * pi * (clampedProgress / 100),
      false,
      progressPaint,
    );
  }

  void _drawWave(Canvas canvas, Animation<double> waveAnimation,
      double waveHeight, double opacity) {
    final path = Path();

    double clampedProgress = progress.value.clamp(0, 100);
    final baseHeight = circleRadius * 2 * (1 - (clampedProgress / 100));

    final waveBottom = circleRadius;
    final waveTop = waveBottom - (circleRadius * 2 * (clampedProgress / 100));
    final adjustedWaveTop = waveTop.clamp(-circleRadius, circleRadius);

    path.moveTo(-circleRadius, adjustedWaveTop);
    for (double i = -circleRadius; i <= circleRadius; i += 5) {
      final y =
          waveHeight * sin((i / circleRadius * 2 * pi) + waveAnimation.value);
      path.lineTo(i, adjustedWaveTop + y);
    }
    path.lineTo(circleRadius, waveBottom);
    path.lineTo(-circleRadius, waveBottom);
    path.close();

    final wavePaint = Paint()
      ..color = circleProgressColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, wavePaint);
  }

  void _drawProgressText(Canvas canvas) {
    final textSpan = TextSpan(
      text: "${(progress.value).toInt()}%",
      style: GoogleFonts.poppins(
        color: progressTextColor,
        fontSize: progressTextSize,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}