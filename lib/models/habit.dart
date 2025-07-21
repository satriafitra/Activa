class Habit {
  int? id;
  String name;
  String icon;
  String color;
  String timeOfDay;
  String days;
  int streak;
  String medal;
  int quantity;
  String unit;
  String? reminderTime; // format: "HH:mm"
  bool hasReminder;

  Habit({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.timeOfDay,
    required this.days,
    this.streak = 0,
    this.medal = 'bronze',
    this.quantity = 1,
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
      unit: map['unit'],
      hasReminder: map['has_reminder'] == 1,
      reminderTime: map['reminder_time'],
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
      'unit': unit,
      'has_reminder': hasReminder ? 1 : 0,
      'reminder_time': reminderTime,
    };
  }
}
