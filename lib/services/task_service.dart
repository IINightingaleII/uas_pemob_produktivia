import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get tasks stream (real-time updates)
  Stream<List<TaskModel>> getTasksStream() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs.map((doc) {
        return TaskModel.fromFirestore(doc.data(), doc.id);
      }).toList();
      // Sort secara manual di client side untuk menghindari composite index
      tasks.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        final dateCompare = a.date!.compareTo(b.date!);
        if (dateCompare != 0) return dateCompare;
        return a.time.compareTo(b.time);
      });
      return tasks;
    });
  }

  // Get tasks (one-time fetch)
  Future<List<TaskModel>> getTasks() async {
    if (_userId == null) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .get();
      
      final tasks = snapshot.docs.map((doc) {
        return TaskModel.fromFirestore(doc.data(), doc.id);
      }).toList();
      
      // Sort secara manual di client side untuk menghindari composite index
      tasks.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        final dateCompare = a.date!.compareTo(b.date!);
        if (dateCompare != 0) return dateCompare;
        return a.time.compareTo(b.time);
      });
      
      return tasks;

      return snapshot.docs.map((doc) {
        return TaskModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  // Add task
  Future<void> addTask(TaskModel task) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .doc(task.id)
          .set(task.toFirestore());
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  // Update task
  Future<void> updateTask(TaskModel task) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .doc(task.id)
          .update(task.toFirestore());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(TaskModel task) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .doc(task.id)
          .update({
        'is_completed': !task.isCompleted,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to toggle task: $e');
    }
  }
}

