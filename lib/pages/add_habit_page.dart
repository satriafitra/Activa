import 'package:active/pages/habit_list_page.dart';
import 'package:flutter/material.dart';
import 'package:active/models/habit.dart';
import 'package:active/db/database_helper.dart';

class AddHabitPage extends StatefulWidget {
  final Habit? habit; // habit yang ingin diedit

  AddHabitPage({this.habit});

  @override
  _AddHabitPageState createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final List<String> _unitOptions = [
    'gelas',
    'kali',
    'menit',
    'jam',
    'langkah',
    'Lainnya'
  ];
  String? _selectedUnit;
  final TextEditingController _customUnitController = TextEditingController();

  String _icon =
      Icons.local_drink.codePoint.toString(); // default pakai codePoint

  String _color = '0xFF42A5F5';
  String _timeOfDay = 'Pagi';
  List<String> _selectedDays = [];

  final List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  final List<IconData> iconList = [
    // Basic & Lifestyle
    Icons.local_drink,
    Icons.directions_run,
    Icons.book,
    Icons.bedtime,
    Icons.self_improvement,
    Icons.fitness_center,
    Icons.spa,
    Icons.check_circle,
    Icons.alarm,
    Icons.access_time,
    Icons.brush,
    Icons.edit,
    Icons.fastfood,
    Icons.sunny,
    Icons.favorite,
    Icons.headset,
    Icons.clean_hands,
    Icons.face_retouching_natural,
    Icons.shopping_bag,
    Icons.school,
    Icons.pets,
    Icons.emoji_emotions,
    Icons.nature,
    Icons.local_florist,
    Icons.park,
    Icons.nightlight_round,
    Icons.wb_twilight,

    // Productivity
    Icons.task,
    Icons.today,
    Icons.calendar_month,
    Icons.notes,
    Icons.sticky_note_2,
    Icons.timer,
    Icons.hourglass_empty,
    Icons.mark_chat_read,
    Icons.lightbulb,
    Icons.check_box,
    Icons.checklist,

    // Health & Self-care
    Icons.health_and_safety,
    Icons.monitor_heart,
    Icons.medication,
    Icons.bubble_chart,
    Icons.psychology,
    Icons.healing,
    Icons.heart_broken,
    Icons.hotel_class,

    // Social / Fun
    Icons.people,
    Icons.group,
    Icons.chat,
    Icons.camera_alt,
    Icons.movie,
    Icons.videogame_asset,
    Icons.music_note,
    Icons.local_cafe,
    Icons.cake,
    Icons.sports_esports,

    // Travel / Movement
    Icons.directions_walk,
    Icons.directions_bike,
    Icons.flight,
    Icons.train,
    Icons.hiking,
    Icons.explore,
    Icons.place,
    Icons.map,

    // Work / Study
    Icons.computer,
    Icons.desktop_mac,
    Icons.laptop_mac,
    Icons.code,
    Icons.work,
    Icons.business_center,
    Icons.science,
    Icons.calculate,
    Icons.menu_book,
    Icons.language,
  ];

  Future<bool> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        id: widget.habit?.id,
        name: _nameController.text,
        icon: _icon,
        color: _color,
        timeOfDay: _timeOfDay,
        days: _selectedDays.join(','),
        streak: widget.habit?.streak ?? 0,
        medal: widget.habit?.medal ?? 'bronze',
        quantity: int.parse(_quantityController.text),
        progress: widget.habit?.progress ?? 0,
        unit: _selectedUnit == 'Lainnya'
            ? _customUnitController.text
            : _selectedUnit ?? '',
        hasReminder: _hasReminder,
        reminderTime: _hasReminder && _selectedReminderTime != null
            ? '${_selectedReminderTime!.hour.toString().padLeft(2, '0')}:${_selectedReminderTime!.minute.toString().padLeft(2, '0')}'
            : null,
      );

      try {
        if (widget.habit == null) {
          await DatabaseHelper.instance.insertHabit(habit);
          print("✅ Habit ditambahkan!");
        } else {
          await DatabaseHelper.instance.updateHabit(habit);
          print("✅ Habit diupdate!");
        }
        return true;
      } catch (e) {
        print("❌ Gagal menyimpan: $e");
        return false;
      }
    } else {
      return false;
    }
  }

  bool _hasReminder = false;
  TimeOfDay? _selectedReminderTime;

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // Tentukan jumlah icon per halaman
        const int iconsPerPage = 8;
        int currentPage = 0;

        return StatefulBuilder(
          builder: (context, setModalState) {
            int totalPages = (iconList.length / iconsPerPage).ceil();
            int start = currentPage * iconsPerPage;
            int end = (start + iconsPerPage) > iconList.length
                ? iconList.length
                : start + iconsPerPage;

            List<IconData> pageIcons = iconList.sublist(start, end);

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: pageIcons.map((iconData) {
                      bool isSelected = _icon == iconData.codePoint.toString();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _icon = iconData.codePoint.toString();
                          });
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: isSelected
                              ? Color(int.parse(_color)).withOpacity(0.2)
                              : Colors.grey[200],
                          child: Icon(
                            iconData,
                            size: 24,
                            color: isSelected
                                ? Color(int.parse(_color))
                                : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: currentPage > 0
                            ? () => setModalState(() => currentPage--)
                            : null,
                      ),
                      Text('${currentPage + 1} / $totalPages'),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: currentPage < totalPages - 1
                            ? () => setModalState(() => currentPage++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.habit != null) {
      final habit = widget.habit!;
      _nameController.text = habit.name;
      _quantityController.text = habit.quantity.toString();
      _unitController.text = habit.unit;
      _icon = habit.icon;
      _color = habit.color;
      _timeOfDay = habit.timeOfDay;
      _selectedDays = habit.days.split(',');
      _selectedUnit =
          _unitOptions.contains(habit.unit) ? habit.unit : 'Lainnya';

      if (_selectedUnit == 'Lainnya') {
        _customUnitController.text = habit.unit;
      }

      // ⏰ Load reminder data
      _hasReminder = habit.hasReminder;

      if (habit.reminderTime != null) {
        final parts = habit.reminderTime!.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour != null && minute != null) {
            _selectedReminderTime = TimeOfDay(hour: hour, minute: minute);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Habit")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Habit'),
                validator: (value) =>
                    value!.isEmpty ? 'Masukkan nama habit' : null,
              ),
              SizedBox(
                height: 16,
              ),
              Text("Icon", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showIconPicker(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        IconData(int.parse(_icon), fontFamily: 'MaterialIcons'),
                        color: Color(int.parse(_color)),
                      ),
                      SizedBox(width: 12),
                      Text("Pilih Icon", style: TextStyle(fontSize: 16)),
                      Spacer(),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("Pilih Warna",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: [
                  '0xFF42A5F5', // biru
                  '0xFF66BB6A', // hijau
                  '0xFFFFCA28', // kuning
                  '0xFFEF5350', // merah
                  '0xFFAB47BC', // ungu
                ].map((colorHex) {
                  bool isSelected = _color == colorHex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _color = colorHex;
                      });
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          Color(int.parse(colorHex)).withOpacity(0.2),
                      child: isSelected
                          ? Icon(Icons.check, color: Color(int.parse(colorHex)))
                          : CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(int.parse(colorHex)),
                            ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _timeOfDay,
                decoration: InputDecoration(labelText: 'Waktu Pelaksanaan'),
                items: ['Pagi', 'Siang', 'Malam'].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => _timeOfDay = val!),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: _days.map((day) {
                  final selected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Jumlah'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Masukkan jumlah';
                  if (int.tryParse(value) == null) return 'Harus berupa angka';
                  return null;
                },
              ),
              SizedBox(height: 12),
              Text("Pilih satuan:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _unitOptions.map((unit) {
                  final isSelected = _selectedUnit == unit;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedUnit = unit;
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.green
                              : const Color.fromARGB(255, 255, 255, 255),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            Icon(Icons.check, color: Colors.white, size: 18),
                          if (isSelected) SizedBox(width: 6),
                          Text(
                            unit,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(
                height: 18,
              ),
              if (_selectedUnit == 'Lainnya')
                TextFormField(
                  controller: _customUnitController,
                  decoration:
                      InputDecoration(labelText: 'Masukkan satuan sendiri'),
                  validator: (value) {
                    if (_selectedUnit == 'Lainnya' &&
                        (value == null || value.isEmpty)) {
                      return 'Satuan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 4),
              SwitchListTile(
                title: const Text("Aktifkan Reminder"),
                value: _hasReminder,
                onChanged: (val) {
                  setState(() {
                    _hasReminder = val;
                  });
                },
              ),
              if (_hasReminder)
                ListTile(
                  title: Text(_selectedReminderTime != null
                      ? "Waktu: ${_selectedReminderTime!.format(context)}"
                      : "Pilih Waktu Reminder"),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedReminderTime = time;
                      });
                    }
                  },
                ),
              SizedBox(
                height: 60,
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await _saveHabit();
                  if (success) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => HabitListPage()),
                      (route) => false, // semua halaman sebelumnya dihapus
                    );
                  }
                },
                child: Text("Simpan Habit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
