import 'package:flutter/material.dart';

class TaskData {
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final String status;
  final List<String> assignees;
  final int commentsCount;
  final int filesCount;
  final Color priorityColor;
  final Color statusColor;

  TaskData({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.assignees,
    required this.commentsCount,
    required this.filesCount,
    required this.priorityColor,
    required this.statusColor,
  });
}
