import 'package:flutter/material.dart';

class UserModel {
  final int? id;
  final String userId;
  final String name;
  final String email;
  final String? nip;
  final String? position;
  final String? department;
  final String? phone;
  final String? profilePicture;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.nip,
    this.position,
    this.department,
    this.phone,
    this.profilePicture,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  String get displayName => name.isNotEmpty ? name : email.split('@').first;
  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'U';
  }

  // Validation methods
  String? validate() {
    if (userId.isEmpty) return 'User ID tidak boleh kosong';
    if (name.trim().isEmpty) return 'Nama tidak boleh kosong';
    if (email.isEmpty) return 'Email tidak boleh kosong';
    if (!_isValidEmail(email)) return 'Format email tidak valid';
    if (nip != null && nip!.isNotEmpty && nip!.length < 8) return 'NIP harus minimal 8 karakter';
    return null; // Valid
  }

  bool get isValid => validate() == null;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'nip': nip,
      'position': position,
      'department': department,
      'phone': phone,
      'profilePicture': profilePicture,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      nip: map['nip'],
      position: map['position'],
      department: map['department'],
      phone: map['phone'],
      profilePicture: map['profilePicture'],
      isActive: (map['isActive'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  UserModel copyWith({
    int? id,
    String? userId,
    String? name,
    String? email,
    String? nip,
    String? position,
    String? department,
    String? phone,
    String? profilePicture,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      nip: nip ?? this.nip,
      position: position ?? this.position,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Create from form data
  factory UserModel.fromFormData({
    required String name,
    required String email,
    String? nip,
    String? position,
    String? department,
    String? phone,
  }) {
    final now = DateTime.now();
    return UserModel(
      userId: 'USR${now.millisecondsSinceEpoch.toString().substring(8)}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      nip: nip?.trim(),
      position: position?.trim(),
      department: department?.trim(),
      phone: phone?.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'UserModel{id: $id, userId: $userId, name: $name, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.userId == userId &&
        other.email == email;
  }

  @override
  int get hashCode {
    return userId.hashCode ^ email.hashCode;
  }
}