import 'package:flutter/material.dart';

Future<void> showDurationPicker(
  BuildContext context,
  TimeOfDay initialDuration,
  Function(TimeOfDay) onDurationSelected,
) async {
  int hours = initialDuration.hour;
  int minutes = initialDuration.minute;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Duration'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Hours'),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                  iconSize: 18,
                                  onPressed: () {
                                    setState(() {
                                      if (hours > 0) hours--;
                                    });
                                  },
                                ),
                                Text(
                                  hours.toString().padLeft(2, '0'),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                  iconSize: 18,
                                  onPressed: () {
                                    setState(() {
                                      if (hours < 23) hours++;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Minutes'),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                  iconSize: 18,
                                  onPressed: () {
                                    setState(() {
                                      if (minutes > 0) {
                                        minutes--;
                                      } else if (minutes == 0 && hours > 0) {
                                        minutes = 59;
                                        hours--;
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  minutes.toString().padLeft(2, '0'),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                  iconSize: 18,
                                  onPressed: () {
                                    setState(() {
                                      if (minutes < 59) {
                                        minutes++;
                                      } else {
                                        minutes = 0;
                                        if (hours < 23) hours++;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  onDurationSelected(TimeOfDay(hour: hours, minute: minutes));
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}

