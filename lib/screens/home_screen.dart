import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../services/dummy_auth_service.dart';
import '../widgets/clock_widget.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/activity_item.dart';
import '../widgets/home_header.dart';
import '../widgets/home_drawer.dart';
import '../widgets/date_calendar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List tasks (kosong di awal, akan diisi dari add task dialog)
  final List<TaskModel> _tasks = [];
  
  // Selected date untuk filter tasks
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimer();
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


  void _toggleTask(int index) {
    // Optimasi: hanya update task yang di-toggle, tidak rebuild seluruh list
    final updatedTask = _tasks[index].copyWith(
      isCompleted: !_tasks[index].isCompleted,
    );
    setState(() {
      _tasks[index] = updatedTask;
    });
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTaskDialog(
          onTaskAdded: (newTask) {
            setState(() {
              _tasks.add(newTask);
            });
          },
        );
      },
    );
  }

  void _showEditTaskDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTaskDialog(
          task: _tasks[index],
          onTaskEdited: (editedTask) {
            setState(() {
              _tasks[index] = editedTask;
            });
          },
          onTaskDeleted: (taskId) {
            setState(() {
              _tasks.removeWhere((task) => task.id == taskId);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = DummyAuthService();
    final currentUser = authService.currentUser;

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
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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

