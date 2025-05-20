import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user-data.dart';

class HistoryPage extends StatefulWidget {
  final User user;
  
  HistoryPage({super.key, required this.user});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final PageController _weekController = PageController(viewportFraction: 0.9);
  int _currentWeekIndex = 0;
  late List<WeekData> _weekData;
  
  @override
  void initState() {
    super.initState();
    _weekData = widget.user.getWeeklyHydrationData();
    _weekController.addListener(_handleWeekChange);
  }

  void _handleWeekChange() {
    final page = _weekController.page?.round();
    if (page != null && page != _currentWeekIndex) {
      setState(() {
        _currentWeekIndex = page;
      });
    }
  }

  @override
  void dispose() {
    _weekController.removeListener(_handleWeekChange);
    _weekController.dispose();
    super.dispose();
  }

  double get _targetIntake => double.parse(widget.user.goal.replaceAll(' ml', '')) / 1000;

  @override
  Widget build(BuildContext context) {
    final currentWeek = _weekData[_currentWeekIndex];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 140,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'HYDRATION HISTORY',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F5E8C), // Primary blue
                      Color(0xFF0A4D73), // Darker blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Current week title
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'THIS WEEK',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F5E8C),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Week selector
                SizedBox(
                  height: 80,
                  child: PageView.builder(
                    controller: _weekController,
                    itemCount: _weekData.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentWeekIndex = index;
                      });
                    },
                    itemBuilder: (context, weekIndex) {
                      final week = _weekData[weekIndex];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (int i = 0; i < 7; i++)
                              SizedBox(
                                width: 36,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF0F5E8C),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFE1F5FE),
                                            Color(0xFFB3E5FC)
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          week.dates[i],
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF0F5E8C),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Weekly summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE1F5FE),
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEEKLY PERFORMANCE',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F5E8C),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${currentWeek.average.toStringAsFixed(1)}L average daily intake',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F5E8C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPerformanceText(currentWeek.average),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _getPerformanceColor(currentWeek.average),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Color(0xFF0F5E8C),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your goal: ${_targetIntake.toStringAsFixed(1)}L per day',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF0F5E8C),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Daily details
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'DAILY DETAILS',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F5E8C),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Bar graph
                Column(
                  children: [
                    for (int i = 0; i < 7; i++)
                      _DataBar(
                        label: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][i],
                        value: currentWeek.values[i],
                        maxValue: _targetIntake,
                        targetValue: _targetIntake,
                      ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Stats section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEEKLY STATS',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F5E8C),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        'Most Hydrated Day',
                        _getMostHydratedDay(currentWeek),
                        Icons.local_drink_outlined,
                        _getHighestValue(currentWeek),
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        'Least Hydrated Day',
                        _getLeastHydratedDay(currentWeek),
                        Icons.water_drop_outlined,
                        _getLowestValue(currentWeek),
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        'Days Met Goal',
                        '${_getDaysMetGoal(currentWeek)} of 7',
                        Icons.check_circle_outline,
                        null,
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String title, String value, IconData icon, double? literValue) {
    return Row(
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
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (literValue != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F5E8C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${literValue.toStringAsFixed(1)}L',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F5E8C),
              ),
            ),
          ),
      ],
    );
  }

  String _getPerformanceText(double average) {
    double percentOfTarget = (average / _targetIntake) * 100;
    if (percentOfTarget >= 95) return 'Excellent hydration week!';
    if (percentOfTarget >= 75) return 'Good hydration week';
    if (percentOfTarget >= 50) return 'Moderate hydration week';
    return 'Keep improving hydration';
  }

  Color _getPerformanceColor(double average) {
    double percentOfTarget = (average / _targetIntake) * 100;
    if (percentOfTarget >= 95) return const Color(0xFF0F5E8C);
    if (percentOfTarget >= 75) return const Color(0xFF1976D2);
    if (percentOfTarget >= 50) return const Color(0xFF42A5F5);
    return const Color(0xFF90CAF9);
  }

  String _getMostHydratedDay(WeekData weekData) {
    int maxIndex = 0;
    double maxValue = weekData.values[0];
    
    for (int i = 1; i < weekData.values.length; i++) {
      if (weekData.values[i] > maxValue) {
        maxValue = weekData.values[i];
        maxIndex = i;
      }
    }
    
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][maxIndex];
  }

  String _getLeastHydratedDay(WeekData weekData) {
    int minIndex = 0;
    double minValue = weekData.values[0];
    
    for (int i = 1; i < weekData.values.length; i++) {
      if (weekData.values[i] < minValue) {
        minValue = weekData.values[i];
        minIndex = i;
      }
    }
    
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][minIndex];
  }

  double _getHighestValue(WeekData weekData) {
    return weekData.values.reduce((a, b) => a > b ? a : b);
  }

  double _getLowestValue(WeekData weekData) {
    return weekData.values.reduce((a, b) => a < b ? a : b);
  }

  int _getDaysMetGoal(WeekData weekData) {
    return weekData.values.where((value) => value >= _targetIntake).length;
  }
}

class _DataBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final double targetValue;

  const _DataBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.targetValue,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    final percentageOfTarget = (value / targetValue).clamp(0.0, 1.0);
    final gradient = _getProgressGradient(percentageOfTarget);
    final textColor = percentage > 0.3 ? Colors.white : const Color(0xFF0F5E8C);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: const Color(0xFF0F5E8C),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: Stack(
              children: [
                // Background
                Container(
                  width: double.infinity,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F5FE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                // Progress bar
                LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = percentage == 1.0
                        ? constraints.maxWidth
                        : constraints.maxWidth * percentage;
                    return Container(
                      width: barWidth,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.colors.first.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(2, 0),
                          )
                        ],
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Text(
                            '${value.toStringAsFixed(1)}L',
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getProgressGradient(double percentageOfTarget) {
    if (percentageOfTarget < 0.25) {
      return const LinearGradient(
        colors: [Color(0xFF90CAF9), Color(0xFF64B5F6)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (percentageOfTarget < 0.5) {
      return const LinearGradient(
        colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (percentageOfTarget < 0.75) {
      return const LinearGradient(
        colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF0F5E8C), Color(0xFF0A4D73)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
}