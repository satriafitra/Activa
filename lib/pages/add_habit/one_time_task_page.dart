import 'package:active/services/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/one_time_task.dart';
import '../../services/one_time_task_helper.dart';
import 'package:active/pages/add_habit/add_habit_utils.dart';

class OneTimeTaskPage extends StatefulWidget {
  final OneTimeTask? task; // <--- tambahkan ini

  const OneTimeTaskPage({super.key, this.task}); // <--- dan ini

  @override
  State<OneTimeTaskPage> createState() => _OneTimeTaskPageState();
}

class _OneTimeTaskPageState extends State<OneTimeTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _customUnitController = TextEditingController();
  final List<IconData> iconList = kHabitIcons;

  DateTime _selectedDate = DateTime.now();

  String _icon = Icons.local_drink.codePoint.toString();
  String _color = Colors.blue.value.toString();
  String? _selectedUnit;

  bool _hasReminder = true;
  TimeOfDay? _selectedReminderTime;

  final List<String> _unitOptions = [
    'Gelas',
    'Kali',
    'Menit',
    'Jam',
    'Langkah',
    'Lainnya'
  ];

  Future<void> _saveTask() async {
    if (_hasReminder && _selectedReminderTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder wajib dipilih')),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _selectedDate != null) {
      // Bangun task dari input user
      final task = OneTimeTask(
        id: widget.task?.id, // jika null, berarti add mode
        name: _nameController.text,
        icon: _icon,
        color: _color,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        quantity: int.parse(_quantityController.text),
        unit: _selectedUnit == 'Lainnya'
            ? _customUnitController.text
            : _selectedUnit!,
        hasReminder: _hasReminder,
        reminderTime: _hasReminder && _selectedReminderTime != null
            ? '${_selectedReminderTime!.hour.toString().padLeft(2, '0')}:${_selectedReminderTime!.minute.toString().padLeft(2, '0')}'
            : null,
      );

      int taskId;

      if (widget.task != null) {
        // EDIT MODE
        await OneTimeTaskHelper.update(task);
        taskId = task.id!;

        // Cancel notifikasi lama dulu
        await NotificationHelper.cancel(taskId);
      } else {
        // ADD MODE
        taskId = await OneTimeTaskHelper.insert(task);
      }

      // Atur notifikasi jika perlu
      if (task.hasReminder && task.reminderTime != null) {
        final parts = task.reminderTime!.split(':');
        final reminderTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );

        print('[✅ NOTIF] Reminder akan muncul pada: $reminderTime');

        await NotificationHelper.scheduleOneTimeTaskNotification(
          id: taskId,
          dateTime: reminderTime,
          title: 'Hai, waktunya tugasmu!🔥',
          body: '${task.name} udah nunggu nih. Yuk kerjain!',
        );
      }

      Navigator.pop(context); // kembali ke halaman sebelumnya
    }
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

    if (widget.task != null) {
      _nameController.text = widget.task!.name;
      _selectedDate = DateTime.parse(widget.task!.date);
      _selectedReminderTime = widget.task!.reminderTime != null
          ? TimeOfDay(
              hour: int.parse(widget.task!.reminderTime!.split(":")[0]),
              minute: int.parse(widget.task!.reminderTime!.split(":")[1]),
            )
          : null;
      _quantityController.text = widget.task!.quantity?.toString() ?? '0';
      _selectedUnit = widget.task!.unit;
      _icon = widget.task!.icon;
      _color = widget.task!.color;
      _hasReminder = widget.task!.hasReminder;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Create one-time task',
            style: GoogleFonts.poppins(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: Text('Save',
                style: GoogleFonts.poppins(
                    color: Colors.green, fontWeight: FontWeight.bold)),
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
            // Nama task
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
            const SizedBox(height: 24),

            // Icon & Color Picker (dummy UI placeholder)
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

            // Date Picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFf9f9f9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                    )
                  ],
                ),
              ),
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

            // Quantity
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
            // Wajib reminder, langsung tampil aktif
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Activate reminder (required)',
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ListTile(
              title: Text(
                _selectedReminderTime != null
                    ? 'Waktu: ${_selectedReminderTime!.format(context)}'
                    : 'Pilih Waktu Reminder',
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

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
