class OneTimeTask {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final String date;
  final int quantity;
  final String unit;
  final bool hasReminder;
  final String? reminderTime;

  OneTimeTask({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.date,
    required this.quantity,
    required this.unit,
    required this.hasReminder,
    this.reminderTime,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon': icon,
        'color': color,
        'date': date,
        'quantity': quantity,
        'unit': unit,
        'has_reminder': hasReminder ? 1 : 0,
        'reminder_time': reminderTime,
      };

  factory OneTimeTask.fromMap(Map<String, dynamic> map) => OneTimeTask(
        id: map['id'],
        name: map['name'],
        icon: map['icon'],
        color: map['color'],
        date: map['date'],
        quantity: map['quantity'],
        unit: map['unit'],
        hasReminder: map['has_reminder'] == 1,
        reminderTime: map['reminder_time'],
      );
}
