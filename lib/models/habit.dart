class Habit {
  
  List<String> get dayList => days.split(',').map((e) => e.trim()).toList();

  set dayList(List<String> newDays) {
    days = newDays.join(',');
  }

  int? id;
  String name;
  String icon;
  String color;
  String timeOfDay;
  String days;
  int streak;
  String medal;
  int quantity;
  int progress;
  String unit;
  String? reminderTime; // format: "HH:mm"
  bool hasReminder;
  int currentStreak;
  int longestStreak;

  Habit({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.timeOfDay,
    required this.days,
    required this.currentStreak,
    required this.longestStreak,
    this.streak = 0,
    this.medal = 'bronze',
    this.quantity = 1,
    this.progress = 0,
    this.unit = 'kali',
    this.reminderTime,
    this.hasReminder = false,
  });

  

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      timeOfDay: map['time_of_day'],
      days: map['days'],
      streak: map['streak'],
      medal: map['medal'],
      quantity: map['quantity'],
      progress: map['progress'],
      unit: map['unit'],
      hasReminder: map['has_reminder'] == 1,
      reminderTime: map['reminder_time'],
      currentStreak: map['current_streak'] ?? 0,
      longestStreak: map['longest_streak'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'time_of_day': timeOfDay,
      'days': days,
      'streak': streak,
      'medal': medal,
      'quantity': quantity,
      'progress': progress,
      'unit': unit,
      'has_reminder': hasReminder ? 1 : 0,
      'reminder_time': reminderTime,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
  }
}
