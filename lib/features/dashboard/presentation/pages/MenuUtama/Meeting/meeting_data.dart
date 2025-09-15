import 'package:flutter/material.dart';

class MeetingData {
  final String title;
  final String room;
  final DateTime date;
  final String startTime;
  final String endTime;
  final Color color;

  MeetingData({
    required this.title,
    required this.room,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
  });
}
