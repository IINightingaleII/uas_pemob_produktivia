import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'color_option.dart';
import 'duration_picker.dart';

class EditTaskDialog extends StatelessWidget {
  final TaskModel task;
  final Function(TaskModel) onTaskEdited;
  final Function(String) onTaskDeleted;

  const EditTaskDialog({
    super.key,
    required this.task,
    required this.onTaskEdited,
    required this.onTaskDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: task.title);
    
    // Parse existing date
    DateTime selectedDate = task.date ?? DateTime.now();
    
    // Parse existing time
    TimeOfDay? selectedAlarmTime;
    if (task.alarmTime != null) {
      final timeParts = task.alarmTime!.split(':');
      selectedAlarmTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    } else {
      selectedAlarmTime = const TimeOfDay(hour: 9, minute: 0);
    }
    
    // Parse existing duration
    TimeOfDay? selectedDuration;
    if (task.duration != null) {
      final durationParts = task.duration!.split(':');
      selectedDuration = TimeOfDay(
        hour: int.parse(durationParts[0]),
        minute: int.parse(durationParts[1]),
      );
    } else {
      selectedDuration = const TimeOfDay(hour: 1, minute: 0);
    }
    
    int selectedColor = task.color;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Field
                  const Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF9183DE), // Light purple
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF9183DE), // Light purple
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF9183DE), // Light purple
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date Field
                  const Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final DateTime now = DateTime.now();
                      final DateTime today = DateTime(now.year, now.month, now.day);
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate.isBefore(today) ? today : selectedDate,
                        firstDate: today, // Mulai dari hari ini
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF9183DE), // Light purple
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Color Selection
                  const Text(
                    'Color',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ColorOption(
                        color: 0xFF4CAF50,
                        isSelected: selectedColor == 0xFF4CAF50,
                        onTap: () {
                          setDialogState(() {
                            selectedColor = 0xFF4CAF50;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ColorOption(
                        color: 0xFFF44336,
                        isSelected: selectedColor == 0xFFF44336,
                        onTap: () {
                          setDialogState(() {
                            selectedColor = 0xFFF44336;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ColorOption(
                        color: 0xFFFF9800,
                        isSelected: selectedColor == 0xFFFF9800,
                        onTap: () {
                          setDialogState(() {
                            selectedColor = 0xFFFF9800;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ColorOption(
                        color: 0xFFFFC107,
                        isSelected: selectedColor == 0xFFFFC107,
                        onTap: () {
                          setDialogState(() {
                            selectedColor = 0xFFFFC107;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ColorOption(
                        color: 0xFF2196F3,
                        isSelected: selectedColor == 0xFF2196F3,
                        onTap: () {
                          setDialogState(() {
                            selectedColor = 0xFF2196F3;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ColorOption(
                        color: 0xFF9C27B0,
                        isSelected: selectedColor == 0xFF9C27B0,
                        onTap: () {
                          setDialogState(() {
                            selectedColor = 0xFF9C27B0;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Set Time Field (Start Time)
                  const Text(
                    'Set Time',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedAlarmTime ?? const TimeOfDay(hour: 9, minute: 0),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedAlarmTime = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF9183DE), // Light purple
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedAlarmTime != null
                                ? '${selectedAlarmTime!.hour.toString().padLeft(2, '0')}:${selectedAlarmTime!.minute.toString().padLeft(2, '0')}'
                                : '9:00',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Time During Field (Duration)
                  const Text(
                    'Time During',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      await showDurationPicker(
                        context,
                        selectedDuration ?? const TimeOfDay(hour: 1, minute: 0),
                        (duration) {
                          setDialogState(() {
                            selectedDuration = duration;
                          });
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF9183DE), // Light purple
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDuration != null
                                ? '${selectedDuration!.hour.toString().padLeft(2, '0')}:${selectedDuration!.minute.toString().padLeft(2, '0')}'
                                : '1:00',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Edit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          final startTime = selectedAlarmTime ?? const TimeOfDay(hour: 9, minute: 0);
                          final duration = selectedDuration ?? const TimeOfDay(hour: 1, minute: 0);
                          
                          final editedTask = task.copyWith(
                            title: nameController.text,
                            time: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                            color: selectedColor,
                            date: selectedDate,
                            alarmTime: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                            duration: '${duration.hour.toString().padLeft(2, '0')}:${duration.minute.toString().padLeft(2, '0')}',
                          );
                          onTaskEdited(editedTask);
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9183DE), // Muted purple
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onTaskDeleted(task.id);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B), // Light coral/red
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

