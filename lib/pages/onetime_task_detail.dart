import 'package:active/pages/add_habit/one_time_task_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../models/one_time_task.dart';
import '../services/one_time_task_helper.dart';

class OneTimeTaskDetailPage extends StatelessWidget {
  final OneTimeTask task;
  final VoidCallback onReload;

  const OneTimeTaskDetailPage({
    super.key,
    required this.task,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail One-Time Task', style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Task
            Text(
              task.name,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Waktu & info
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  task.reminderTime ?? 'Tidak ada pengingat',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  task.date,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
            const Spacer(),

            // Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol Edit (sementara belum ada logic-nya)
                ElevatedButton.icon(
                  onPressed: () async {
                    // Buka halaman edit
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OneTimeTaskPage(task: task),
                      ),
                    );

                    // Setelah kembali dari edit, reload data biar tampilan up to date
                    onReload();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: Text('Edit',
                      style: GoogleFonts.poppins(color: Colors.white)),
                ),

                // Tombol Hapus
                ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.all(20),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 150,
                              child:
                                  Lottie.asset('assets/animations/alert.json'),
                            ),
                            const SizedBox(height: 16),
                            Text('Konfirmasi',
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              'Apakah kamu yakin ingin menghapus task ini?',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Batal',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey[700])),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Hapus',
                                style:
                                    GoogleFonts.poppins(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await OneTimeTaskHelper().deleteOneTimeTask(task.id!);
                      onReload();
                      Navigator.pop(context); // kembali ke halaman sebelumnya
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: Text('Hapus',
                      style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
