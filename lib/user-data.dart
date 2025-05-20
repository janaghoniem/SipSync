class User {
  String name;
  String email;
  String password;
  String age;
  String activityLevel;
  String weight;
  String height;
  String goal;
  String reminder;
  String recommendedGoal;
  double? currentIntake;
  List<HydrationHistory> history;

  User({
    required this.name,
    required this.email,
    required this.password,
    this.age = '20',
    this.activityLevel = 'Moderate',
    this.weight = '50 kg',
    this.height = '160 cm',
    this.goal = '1750 ml',
    this.reminder = '30 min',
    this.recommendedGoal = '1750 ml',
    this.currentIntake = 0,
    List<HydrationHistory>? history,
  }) : this.history = history ?? [];

  // Helper method to add a new hydration record
  void addHydrationRecord(DateTime date, double intake) {
    // Look for an existing record on the same day
    final existingRecordIndex = history.indexWhere((record) => 
      record.date.year == date.year && 
      record.date.month == date.month && 
      record.date.day == date.day
    );
    
    if (existingRecordIndex != -1) {
      // Update existing record
      history[existingRecordIndex].intake = intake;
    } else {
      // Add new record
      history.add(HydrationHistory(date: date, intake: intake));
    }
    
    // Sort records by date (newest first)
    history.sort((a, b) => b.date.compareTo(a.date));
  }
  
  // Get weeks of hydration data
  List<WeekData> getWeeklyHydrationData() {
    if (history.isEmpty) {
      return _generateSampleWeekData();
    }
    
    // Organize history by weeks
    Map<int, List<HydrationHistory>> weekMap = {};
    
    // Get the most recent date
    DateTime mostRecentDate = DateTime.now();
    if (history.isNotEmpty) {
      mostRecentDate = history.first.date;
    }
    
    // Start from the most recent Sunday
    DateTime currentWeekEnd = mostRecentDate;
    while (currentWeekEnd.weekday != DateTime.sunday) {
      currentWeekEnd = currentWeekEnd.add(Duration(days: 1));
    }
    
    // Generate 3 weeks of data (current week and 2 previous weeks)
    List<WeekData> weeklyData = [];
    
    for (int weekIndex = 0; weekIndex < 3; weekIndex++) {
      DateTime weekStart = currentWeekEnd.subtract(Duration(days: 6));
      
      // Get records for this week
      List<HydrationHistory> weekRecords = history.where((record) {
        return record.date.isAfter(weekStart.subtract(Duration(days: 1))) && 
               record.date.isBefore(currentWeekEnd.add(Duration(days: 1)));
      }).toList();
      
      // Create week data
      List<String> dates = [];
      List<double> values = [];
      double weekTotal = 0;
      
      // For each day of the week (Monday to Sunday)
      for (int i = 0; i < 7; i++) {
        DateTime currentDay = weekStart.add(Duration(days: i));
        dates.add(currentDay.day.toString());
        
        // Find record for this day
        final dayRecord = weekRecords.firstWhere(
          (record) => 
            record.date.year == currentDay.year && 
            record.date.month == currentDay.month && 
            record.date.day == currentDay.day,
          orElse: () => HydrationHistory(date: currentDay, intake: 0),
        );
        
        values.add(dayRecord.intake);
        weekTotal += dayRecord.intake;
      }
      
      double average = weekTotal / 7;
      
      weeklyData.add(WeekData(
        dates: dates,
        values: values,
        average: average,
      ));
      
      // Move to previous week
      currentWeekEnd = weekStart.subtract(Duration(days: 1));
    }
    
    return weeklyData.isEmpty ? _generateSampleWeekData() : weeklyData;
  }
  
  // Generate sample data if no history exists
  List<WeekData> _generateSampleWeekData() {
    double targetGoal = double.parse(goal.replaceAll(' ml', ''));
    double goalFactor = targetGoal / 2000; // Scale factor based on user's goal
    
    return [
      WeekData(
        dates: ['26', '27', '28', '29', '30', '31', '1'],
        values: [
          4.0 * goalFactor, 
          0.8 * goalFactor, 
          2.8 * goalFactor, 
          1.8 * goalFactor, 
          3.3 * goalFactor, 
          2.1 * goalFactor, 
          3.9 * goalFactor
        ],
        average: 2.7 * goalFactor,
      ),
      WeekData(
        dates: ['3', '4', '5', '6', '7', '8', '9'],
        values: [
          3.5 * goalFactor, 
          0.7 * goalFactor, 
          2.5 * goalFactor, 
          1.2 * goalFactor, 
          3.8 * goalFactor, 
          2.9 * goalFactor, 
          1.5 * goalFactor
        ],
        average: 2.3 * goalFactor,
      ),
      WeekData(
        dates: ['10', '11', '12', '13', '14', '15', '16'],
        values: [
          2.2 * goalFactor, 
          3.7 * goalFactor, 
          0.8 * goalFactor, 
          3.1 * goalFactor, 
          0.6 * goalFactor, 
          4.0 * goalFactor, 
          2.8 * goalFactor
        ],
        average: 2.5 * goalFactor,
      ),
    ];
  }
  
}

// Class to store individual hydration records
class HydrationHistory {
  DateTime date;
  double intake; // in liters

  HydrationHistory({
    required this.date,
    required this.intake,
  });
}

// Class to represent weekly hydration data
class WeekData {
  List<String> dates;
  List<double> values;
  double average;

  WeekData({
    required this.dates,
    required this.values,
    required this.average,
  });
}

List<User> registeredUsers = [];