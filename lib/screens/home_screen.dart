import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import '../widgets/clock_widget.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/activity_item.dart';
import '../widgets/home_header.dart';
import '../widgets/home_drawer.dart';
import '../widgets/date_calendar_widget.dart';
import '../utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TaskService _taskService = TaskService();

  // List tasks (akan di-load dari Firestore)
  List<TaskModel> _tasks = [];
  
  // Selected date untuk filter tasks
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Initialize notification service and schedule all task notifications
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      
      // Schedule notifications for all tasks when tasks are loaded
      _taskService.getTasksStream().listen((tasks) async {
        await notificationService.scheduleAllTaskNotifications(tasks);
      });
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  Future<void> _toggleTask(int index) async {
    try {
      final task = _tasks[index];
      await _taskService.toggleTaskCompletion(task);
      // Task akan otomatis update via stream
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddTaskDialog() {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddTaskDialog(
          onTaskAdded: (newTask) async {
            try {
              // Set created_at timestamp
              final taskWithTimestamp = newTask.copyWith(
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await _taskService.addTask(taskWithTimestamp);
              // Task akan otomatis muncul via stream
              if (mounted && navigator.canPop()) {
                navigator.pop();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error adding task: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  void _showEditTaskDialog(int index) {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return EditTaskDialog(
          task: _tasks[index],
          onTaskEdited: (editedTask) async {
            try {
              // Set updated_at timestamp
              final taskWithTimestamp = editedTask.copyWith(
                updatedAt: DateTime.now(),
              );
              await _taskService.updateTask(taskWithTimestamp);
              // Task akan otomatis update via stream
              if (mounted && navigator.canPop()) {
                navigator.pop();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating task: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          onTaskDeleted: (taskId) async {
            try {
              await _taskService.deleteTask(taskId);
              // Task akan otomatis dihapus via stream
              if (mounted && navigator.canPop()) {
                navigator.pop();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting task: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.userChanges, // Use userChanges to listen for email/displayName updates
      builder: (context, snapshot) {
        final currentUser = authService.currentUser;

        return StreamBuilder<List<TaskModel>>(
          stream: _taskService.getTasksStream(),
          builder: (context, taskSnapshot) {
            // Update tasks dari stream
            if (taskSnapshot.hasData) {
              _tasks = taskSnapshot.data!;
            }

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              drawer: HomeDrawer(currentUser: currentUser),
              body: SafeArea(
                child: Column(
                  children: [
                    // Custom Header
                    HomeHeader(
                      onMenuTap: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    // Clock Widget dengan key berdasarkan tasks untuk optimasi
                    ClockWidget(
                      key: ValueKey('clock_${_filteredTasks.length}_${_filteredTasks.where((t) => t.isCompleted).length}'),
                      currentTime: _currentTime,
                      tasks: _filteredTasks,
                    ),
                    // Activities Section
                    Expanded(
                      child: _buildActivitiesSection(),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _showAddTaskDialog,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(
                  Icons.add,
                  color: Color(0xFF9183DE), // Purple
                ),
              ),
            );
          },
        );
      },
    );
  }


  // Filter tasks berdasarkan selected date
  List<TaskModel> get _filteredTasks {
    return _tasks.where((task) {
      if (task.date == null) return false;
      return task.date!.year == _selectedDate.year &&
          task.date!.month == _selectedDate.month &&
          task.date!.day == _selectedDate.day;
    }).toList();
  }

  // Get index dari filtered tasks untuk toggle
  int _getTaskIndexInAllTasks(TaskModel filteredTask) {
    return _tasks.indexWhere((task) => task.id == filteredTask.id);
  }

  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar Widget
        DateCalendarWidget(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),
        // Activities List
        Expanded(
          child: _filteredTasks.isEmpty
              ? Center(
                  child: Text(
                    'No tasks for this date',
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: Responsive.fontSize(context, 14),
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.paddingHorizontal(context),
                  ),
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    final taskIndex = _getTaskIndexInAllTasks(task);
                    return ActivityItem(
                      key: ValueKey('${task.id}_${task.isCompleted}'), // Key untuk optimasi ListView
                      task: task,
                      onToggle: () => _toggleTask(taskIndex),
                      onEdit: () => _showEditTaskDialog(taskIndex),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

