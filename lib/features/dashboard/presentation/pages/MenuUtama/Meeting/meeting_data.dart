import 'package:flutter/material.dart';

class MeetingData {
  final String title;
  final String room;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool hasReminder;
  final DateTime? reminderDateTime;

  MeetingData({
    required this.title,
    required this.room,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.hasReminder = false,
    this.reminderDateTime,
  });
}
