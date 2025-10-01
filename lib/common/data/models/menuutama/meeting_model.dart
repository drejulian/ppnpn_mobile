import 'package:flutter/material.dart';

enum MeetingStatus {
  scheduled('Scheduled', Colors.blue),
  ongoing('Ongoing', Colors.green),
  completed('Completed', Colors.grey),
  cancelled('Cancelled', Colors.red);

  const MeetingStatus(this.label, this.color);
  final String label;
  final Color color;

  static MeetingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return MeetingStatus.ongoing;
      case 'completed':
        return MeetingStatus.completed;
      case 'cancelled':
        return MeetingStatus.cancelled;
      case 'scheduled':
      default:
        return MeetingStatus.scheduled;
    }
  }
}

class MeetingModel {
  final int? id;
  final String meetingId;
  final String title;
  final String? description;
  final String room;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String organizer;
  final List<String> attendees;
  final bool isOnline;
  final String? meetingLink;
  final MeetingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  MeetingModel({
    this.id,
    required this.meetingId,
    required this.title,
    this.description,
    required this.room,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.organizer,
    this.attendees = const [],
    this.isOnline = false,
    this.meetingLink,
    this.status = MeetingStatus.scheduled,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  String get formattedDate {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  String get timeRange => '$startTime - $endTime';
  
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  bool get isPast => DateTime.now().isAfter(date);
  bool get canEdit => status == MeetingStatus.scheduled && !isPast;

  // Validation methods
  String? validate() {
    if (meetingId.isEmpty) return 'Meeting ID tidak boleh kosong';
    if (title.trim().isEmpty) return 'Judul meeting tidak boleh kosong';
    if (room.trim().isEmpty) return 'Ruangan tidak boleh kosong';
    if (organizer.isEmpty) return 'Organizer tidak boleh kosong';
    if (startTime.isEmpty) return 'Waktu mulai tidak boleh kosong';
    if (endTime.isEmpty) return 'Waktu selesai tidak boleh kosong';
    if (isOnline && (meetingLink == null || meetingLink!.isEmpty)) {
      return 'Link meeting diperlukan untuk meeting online';
    }
    return null; // Valid
  }

  bool get isValid => validate() == null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meetingId': meetingId,
      'title': title,
      'description': description,
      'room': room,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'organizer': organizer,
      'attendees': attendees.join(','),
      'isOnline': isOnline ? 1 : 0,
      'meetingLink': meetingLink,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MeetingModel.fromMap(Map<String, dynamic> map) {
    return MeetingModel(
      id: map['id'],
      meetingId: map['meetingId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      room: map['room'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      organizer: map['organizer'] ?? '',
      attendees: map['attendees']?.toString().split(',').where((att) => att.isNotEmpty).toList() ?? [],
      isOnline: (map['isOnline'] as int?) == 1,
      meetingLink: map['meetingLink'],
      status: MeetingStatus.fromString(map['status'] ?? 'scheduled'),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  MeetingModel copyWith({
    int? id,
    String? meetingId,
    String? title,
    String? description,
    String? room,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? organizer,
    List<String>? attendees,
    bool? isOnline,
    String? meetingLink,
    MeetingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      title: title ?? this.title,
      description: description ?? this.description,
      room: room ?? this.room,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      organizer: organizer ?? this.organizer,
      attendees: attendees ?? this.attendees,
      isOnline: isOnline ?? this.isOnline,
      meetingLink: meetingLink ?? this.meetingLink,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Create from form data
  factory MeetingModel.fromFormData({
    required String title,
    String? description,
    required String room,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String organizer,
    List<String>? attendees,
    bool isOnline = false,
    String? meetingLink,
  }) {
    final now = DateTime.now();
    return MeetingModel(
      meetingId: 'MTG${now.millisecondsSinceEpoch.toString().substring(8)}',
      title: title.trim(),
      description: description?.trim(),
      room: room.trim(),
      date: date,
      startTime: startTime,
      endTime: endTime,
      organizer: organizer,
      attendees: attendees ?? [],
      isOnline: isOnline,
      meetingLink: meetingLink?.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'MeetingModel{id: $id, meetingId: $meetingId, title: $title, date: $formattedDate, status: ${status.label}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MeetingModel &&
        other.meetingId == meetingId &&
        other.date == date &&
        other.startTime == startTime;
  }

  @override
  int get hashCode {
    return meetingId.hashCode ^
        date.hashCode ^
        startTime.hashCode;
  }
}