import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:active/components/sidebar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  TimeOfDay _defaultReminder = const TimeOfDay(hour: 8, minute: 0);
  bool _isSidebarOpen = false;

  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _defaultReminder,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF8A00),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _defaultReminder) {
      setState(() => _defaultReminder = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFeaf3fb), Color(0xFFfefefe)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleSidebar,
                          child: const Icon(
                            Icons.menu,
                            color: Colors.black87,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Settings",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // LIST ITEM SETTINGS
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildSwitchTile(
                          Icons.notifications_active,
                          "Notifikasi",
                          _notifications,
                          (val) => setState(() => _notifications = val),
                        ),
                        _buildTile(
                          Icons.access_time,
                          "Waktu Pengingat Default",
                          subtitle:
                              "${_defaultReminder.hour.toString().padLeft(2, '0')}:${_defaultReminder.minute.toString().padLeft(2, '0')}",
                          onTap: () => _selectTime(context),
                        ),
                        _buildTile(
                          Icons.backup,
                          "Backup & Restore Data",
                          onTap: () {
                            // TODO: navigasi ke halaman backup
                          },
                        ),
                        _buildTile(
                          Icons.info_outline,
                          "Tentang Aplikasi",
                          onTap: () {
                            // TODO: navigasi ke halaman about
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // SIDEBAR OVERLAY
        SidebarOverlay(
          isOpen: _isSidebarOpen,
          onClose: _toggleSidebar,
          selectedItem: "Settings",
        ),
      ],
    );
  }

  // 🔸 Tile dengan switch
  Widget _buildSwitchTile(
      IconData icon, String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.orangeAccent),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.orangeAccent,
        ),
      ),
    );
  }

  // 🔹 Tile biasa
  Widget _buildTile(IconData icon, String title,
      {String? subtitle, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.orangeAccent),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
