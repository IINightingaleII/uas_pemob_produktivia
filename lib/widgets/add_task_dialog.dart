import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'color_option.dart';
import 'duration_picker.dart';

class AddTaskDialog extends StatelessWidget {
  final Function(TaskModel) onTaskAdded;

  const AddTaskDialog({
    super.key,
    required this.onTaskAdded,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    DateTime selectedDate = today; // Default ke hari ini
    int selectedColor = 0xFFFF9800; // Material Orange (default)
    TimeOfDay? selectedAlarmTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay? selectedDuration = const TimeOfDay(hour: 1, minute: 0);

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
                  SizedBox(
                    height: 48, // Fixed height untuk color options
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ColorOption(
                          color: 0xFF4CAF50, // Material Green - kontras dengan putih
                          isSelected: selectedColor == 0xFF4CAF50,
                          onTap: () {
                            setDialogState(() {
                              selectedColor = 0xFF4CAF50;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ColorOption(
                          color: 0xFFF44336, // Material Red - kontras dengan putih
                          isSelected: selectedColor == 0xFFF44336,
                          onTap: () {
                            setDialogState(() {
                              selectedColor = 0xFFF44336;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ColorOption(
                          color: 0xFFFF9800, // Material Orange - kontras dengan putih
                          isSelected: selectedColor == 0xFFFF9800,
                          onTap: () {
                            setDialogState(() {
                              selectedColor = 0xFFFF9800;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ColorOption(
                          color: 0xFFFFC107, // Material Amber - kontras dengan putih
                          isSelected: selectedColor == 0xFFFFC107,
                          onTap: () {
                            setDialogState(() {
                              selectedColor = 0xFFFFC107;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ColorOption(
                          color: 0xFF2196F3, // Material Blue - kontras dengan putih
                          isSelected: selectedColor == 0xFF2196F3,
                          onTap: () {
                            setDialogState(() {
                              selectedColor = 0xFF2196F3;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ColorOption(
                          color: 0xFF9C27B0, // Material Purple - kontras dengan putih
                          isSelected: selectedColor == 0xFF9C27B0,
                          onTap: () {
                            setDialogState(() {
                              selectedColor = 0xFF9C27B0;
                            });
                          },
                        ),
                      ],
                    ),
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
                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          final startTime = selectedAlarmTime ?? const TimeOfDay(hour: 9, minute: 0);
                          final duration = selectedDuration ?? const TimeOfDay(hour: 1, minute: 0);
                          
                          final newTask = TaskModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: nameController.text,
                            time: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                            color: selectedColor,
                            date: selectedDate,
                            alarmTime: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                            duration: '${duration.hour.toString().padLeft(2, '0')}:${duration.minute.toString().padLeft(2, '0')}',
                          );
                          onTaskAdded(newTask);
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
                        'Add',
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

