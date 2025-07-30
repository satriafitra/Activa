import 'package:active/pages/onetime_task_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/one_time_task.dart';
import '../services/one_time_task_helper.dart';
import 'package:lottie/lottie.dart';

class OneTimeTaskCard extends StatelessWidget {
  final OneTimeTask task;
  final VoidCallback onReload;

  const OneTimeTaskCard({
    super.key,
    required this.task,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted == 1;

    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: isCompleted ? const BehindMotion() : const DrawerMotion(),
        children: [
          Flexible(
            flex: 1,
            child: CustomSlidableAction(
              onPressed: (_) async {
                if (isCompleted) {
                  await OneTimeTaskHelper()
                      .unmarkOneTimeTaskAsCompleted(task.id!);
                } else {
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
                            child: Lottie.asset('assets/animations/alert.json'),
                          ),
                          const SizedBox(height: 16),
                          Text('Konfirmasi',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            'Apakah kamu yakin ingin menyelesaikan task ini?',
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
                              style:
                                  GoogleFonts.poppins(color: Colors.grey[700])),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Selesai',
                              style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await OneTimeTaskHelper()
                        .markOneTimeTaskAsCompleted(task.id!);
                  }
                }

                onReload();
              },
              backgroundColor: Colors.transparent,
              child: Container(
                width: 1000,
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.orange : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isCompleted ? Colors.orange : Colors.green)
                          .withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted ? Icons.undo : Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted ? 'Undo' : 'Selesai',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OneTimeTaskDetailPage(
                task: task,
                onReload: onReload,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isCompleted ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isCompleted
                ? []
                : [
                    const BoxShadow(
                      color: Color.fromARGB(20, 0, 0, 0),
                      blurRadius: 12,
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.grey.shade400
                      : Color(int.parse(task.color)).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconData(int.parse(task.icon), fontFamily: 'MaterialIcons'),
                  color:
                      isCompleted ? Colors.white : Color(int.parse(task.color)),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 600),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.grey : Colors.black,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      child: Text(task.name),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${task.quantity ?? 0} ${task.unit ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isCompleted
                                ? Colors.grey
                                : Color(int.parse(task.color)),
                          ),
                        ),
                        if (task.reminderTime != null &&
                            task.reminderTime!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.alarm,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                task.reminderTime!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isCompleted
                                      ? Colors.grey
                                      : const Color.fromARGB(
                                          221, 123, 123, 123),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
