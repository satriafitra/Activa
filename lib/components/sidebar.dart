import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SidebarOverlay extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final String selectedItem; // untuk menandai menu aktif

  const SidebarOverlay({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (isOpen)
          GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          left: isOpen ? 0 : -300,
          top: 0,
          bottom: 0,
          child: Container(
            width: 280,
            color: Colors.white,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner gambar
                  Container(
                    width: double.infinity,
                    height: 170,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/sidebar_banner.png'), // ganti sesuai filemu
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(24),
                        bottomLeft: Radius.circular(24)
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "One step ahead dude!",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 24),
                        Text(
                          "1 days",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Your current streak",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SidebarMenuItem(Icons.calendar_today, "Today",
                      isActive: selectedItem == "Today"),
                  _SidebarMenuItem(Icons.bar_chart, "Your stats",
                      isActive: selectedItem == "Your stats"),
                  
                  _SidebarMenuItem(Icons.list, "All habits",
                      isActive: selectedItem == "All habits"),
                  _SidebarMenuItem(Icons.face_retouching_natural, "Acto's Pal", trailing: "NEW",
                      isActive: selectedItem == "Acto's Pal"),
                  _SidebarMenuItem(Icons.notifications_none, "Notifications",
                      isActive: selectedItem == "Notifications"),
                  _SidebarMenuItem(Icons.settings, "Settings",
                      isActive: selectedItem == "Settings"),
                  _SidebarMenuItem(Icons.diamond_outlined, "Premium Plan",
                      trailing: "HOT", isActive: selectedItem == "Premium Plan"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final bool isActive;

  const _SidebarMenuItem(this.icon, this.title,
      {this.trailing, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final textColor = isActive ? Colors.blueAccent : Colors.black87;
    final bgColor = isActive ? Colors.blue.withOpacity(0.08) : Colors.transparent;

    return Container(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (trailing != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(trailing!,
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
