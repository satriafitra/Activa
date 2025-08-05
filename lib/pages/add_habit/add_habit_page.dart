import 'package:active/pages/add_habit/add_habit_utils.dart';
import 'package:active/pages/habit_list/habit_list_page.dart';
import 'package:flutter/material.dart';
import 'package:active/models/habit.dart';
import 'package:active/services/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:active/services/notification_helper.dart';

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
  final List<String> _unitOptions = unitOptions;
  final List<String> _days = kDays;
  final List<IconData> iconList = kHabitIcons;

  String? _selectedUnit;
  final TextEditingController _customUnitController = TextEditingController();

  String _icon =
      Icons.local_drink.codePoint.toString(); // default pakai codePoint

  String _color = '0xFF42A5F5';
  String _timeOfDay = 'Pagi';
  List<String> _selectedDays = [];

  Future<bool> _saveHabit() async {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih minimal 1 hari'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }

    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        id: widget.habit?.id,
        name: _nameController.text,
        icon: _icon,
        color: _color,
        timeOfDay: _timeOfDay,
        days: _selectedDays.join(','), // Misal: "1,3,5"
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
        currentStreak: widget.habit?.currentStreak ?? 0,
        longestStreak: widget.habit?.longestStreak ?? 0,
      );

      print("📅 Selected days saat simpan: ${_selectedDays.join(',')}");

      try {
        if (widget.habit == null) {
          // 🔹 Simpan habit baru
          final habitId = await DatabaseHelper.instance.insertHabit(habit);

          final db = await DatabaseHelper.instance.database;

          // 🔁 UNDO STREAK JIKA PERLU
          await DatabaseHelper.instance.undoStreakIfNeeded(DateTime.now());

          // Bersihkan habit_logs yang tanggalnya sudah lewat
          await db.delete(
            'habit_logs',
            where: 'habit_id = ? AND date < ?',
            whereArgs: [
              habitId,
              DateFormat('yyyy-MM-dd').format(DateTime.now())
            ],
          );

          if (habit.hasReminder && habit.reminderTime != null) {
            final parts = habit.reminderTime!.split(':');
            final reminderTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );

            await NotificationHelper.scheduleHabitNotification(
              id: habitId,
              reminderTime: reminderTime,
              title: 'Yuk selesaikan habit! 🔥',
              body: '${habit.name} Udah nungguin nih..',
            );
          }

          print("✅ Habit ditambahkan!");

          // 🔹 Generate logs hanya untuk masa depan
          final Map<String, int> dayNameToNumber = {
            'Senin': 1,
            'Selasa': 2,
            'Rabu': 3,
            'Kamis': 4,
            'Jumat': 5,
            'Sabtu': 6,
            'Minggu': 7,
          };

          final repeatDays =
              habit.dayList.map((e) => dayNameToNumber[e]!).toList();

          print("🎯 Hari yang dipilih (angka): $repeatDays");

          await DatabaseHelper.instance.generateHabitLogs(
            habitId: habitId,
            repeatDays: repeatDays,
          );
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

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        const int colorsPerPage = 8;
        int currentPage = 0;

        final List<String> colorList = [
          '0xFF42A5F5', // Biru
          '0xFF66BB6A', // Hijau
          '0xFFFFCA28', // Kuning
          '0xFFEF5350', // Merah
          '0xFFAB47BC', // Ungu
          '0xFF5C6BC0', // Indigo
          '0xFF26C6DA', // Cyan
          '0xFFFF7043', // Orange
          '0xFF8D6E63', // Coklat
          '0xFF7E57C2', // Deep Purple
          '0xFF78909C', // Blue Grey
        ];

        return StatefulBuilder(
          builder: (context, setModalState) {
            int totalPages = (colorList.length / colorsPerPage).ceil();
            int start = currentPage * colorsPerPage;
            int end = (start + colorsPerPage) > colorList.length
                ? colorList.length
                : start + colorsPerPage;

            List<String> pageColors = colorList.sublist(start, end);

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: pageColors.map((colorHex) {
                      bool isSelected = _color == colorHex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _color = colorHex;
                          });
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              Color(int.parse(colorHex)).withOpacity(0.2),
                          child: isSelected
                              ? Icon(Icons.check,
                                  color: Color(int.parse(colorHex)))
                              : CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Color(int.parse(colorHex)),
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Add habit',
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () async {
              final success = await _saveHabit();
              if (success) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HabitListPage()),
                  (route) => false,
                );
              }
            },
            child: Text('SAVE',
                style: GoogleFonts.poppins(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                )),
          )
        ],
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.poppins(color: Color(0xFF7D7D7D)),
              decoration: InputDecoration(
                hintText: 'Name of your habit',
                hintStyle: GoogleFonts.poppins(color: Color(0xFF7D7D7D)),
                filled: true,
                fillColor: Color(0xfff9f9f9),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Masukkan nama habit' : null,
            ),

            const SizedBox(height: 26),

            // Icon & Color Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showIconPicker,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.blue.withOpacity(0.05),
                        child: Icon(
                          IconData(int.parse(_icon),
                              fontFamily: 'MaterialIcons'),
                          size: 28,
                          color: Color(int.parse(_color)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Icon',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 36,
                ),
                GestureDetector(
                  onTap: _showColorPicker,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor:
                            Color(int.parse(_color)).withOpacity(0.05),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(int.parse(_color)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Color',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Divider sebelum waktu pelaksanaan
            const Divider(
              thickness: 1.5,
              height: 0,
              color: Color(0xFFf7f7f7), // atau bisa pakai Colors.grey[300]
            ),

            SizedBox(
              height: 28,
            ),

            // Waktu pelaksanaan
            DropdownButtonFormField2(
              value: _timeOfDay,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
              ),
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 16),
              hint: Text(
                'Waktu pelaksanaan',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              dropdownStyleData: DropdownStyleData(
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                elevation: 3,
                offset: const Offset(0, -4),
              ),
              items: ['Pagi', 'Siang', 'Malam']
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e, style: GoogleFonts.poppins()),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _timeOfDay = val!),
            ),

            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 2,
              children: _days.map((day) {
                final selected = _selectedDays.contains(day);
                return ChoiceChip(
                  label: Text(
                    day,
                    style: GoogleFonts.poppins(
                        color: selected ? Colors.green : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                  selected: selected,
                  backgroundColor: Color.fromARGB(7, 0, 0, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

                  selectedColor:
                      Colors.green.withOpacity(0.15), // 🔸 Warna saat dipilih
                  showCheckmark: false, // 🔸 Hilangkan centang
                  side: BorderSide.none, // 🔸 Hilangkan outline border
                  shape: RoundedRectangleBorder(
                    // Optional: bikin sudut agak halus
                    borderRadius: BorderRadius.circular(14),
                  ),
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

            const SizedBox(height: 28),

            // Divider sebelum waktu pelaksanaan
            const Divider(
              thickness: 1.5,
              height: 0,
              color: Color(0xFFf7f7f7), // atau bisa pakai Colors.grey[300]
            ),

            SizedBox(
              height: 28,
            ),

            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Masukkan goals habit kamu',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                filled: true,
                fillColor: Color(0xfff9f9f9),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Masukkan jumlah';
                if (int.tryParse(value) == null) return 'Harus berupa angka';
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Unit Options
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _unitOptions.map((unit) {
                final isSelected = _selectedUnit == unit;
                return GestureDetector(
                  onTap: () => setState(() => _selectedUnit = unit),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.withOpacity(0.1)
                          : Color(0xfff9f9f9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      unit,
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.green : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_selectedUnit == 'Lainnya') ...[
              const SizedBox(height: 24),
              TextFormField(
                controller: _customUnitController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  hintText: 'Masukkan satuan sendiri',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  filled: true,
                  fillColor: Color(0xfff9f9f9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (_selectedUnit == 'Lainnya' &&
                      (value == null || value.isEmpty)) {
                    return 'Satuan tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 28),

            // Divider sebelum waktu pelaksanaan
            const Divider(
              thickness: 1.5,
              height: 0,
              color: Color(0xFFf7f7f7), // atau bisa pakai Colors.grey[300]
            ),

            SizedBox(
              height: 28,
            ),

            // Reminder toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _hasReminder = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: !_hasReminder
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'No reminder',
                      style: GoogleFonts.poppins(
                        color: !_hasReminder ? Colors.green : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () => setState(() => _hasReminder = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: _hasReminder
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Activate reminder',
                      style: GoogleFonts.poppins(
                        color: _hasReminder ? Colors.green : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_hasReminder) ...[
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _selectedReminderTime != null
                      ? "Waktu: ${_selectedReminderTime!.format(context)}"
                      : "Pilih Waktu Reminder",
                  style: GoogleFonts.poppins(),
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() => _selectedReminderTime = time);
                  }
                },
              ),
            ],

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
