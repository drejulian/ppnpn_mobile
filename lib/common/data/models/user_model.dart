enum UserRole {
  admin,
  pegawai,
  magang,
}

class UserModel {
  final int? id;
  final String username;
  final String email;
  final String nama;
  final String password;
  final UserRole role;
  final String? noTelepon;
  final String? alamat;
  final DateTime? lastLogin;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.nama,
    required this.password,
    required this.role,
    this.noTelepon,
    this.alamat,
    this.lastLogin,
    required this.createdAt,
  });

  /// Factory constructor dari Map (database)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String,
      nama: map['nama'] as String,
      password: map['password'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.pegawai,
      ),
      noTelepon: map['noTelepon'] as String?,
      alamat: map['alamat'] as String?,
      lastLogin: map['lastLogin'] != null ? DateTime.parse(map['lastLogin'] as String) : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Factory constructor dari form data
  factory UserModel.fromFormData({
    required String username,
    required String email,
    required String nama,
    required String password,
    required UserRole role,
    String? noTelepon,
    String? alamat,
  }) {
    return UserModel(
      username: username,
      email: email,
      nama: nama,
      password: password,
      role: role,
      noTelepon: noTelepon,
      alamat: alamat,
      createdAt: DateTime.now(),
    );
  }

  /// Convert ke Map untuk database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      'nama': nama,
      'password': password,
      'role': role.toString().split('.').last,
      'noTelepon': noTelepon,
      'alamat': alamat,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Copy dengan perubahan
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? nama,
    String? password,
    UserRole? role,
    String? noTelepon,
    String? alamat,
    DateTime? lastLogin,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      password: password ?? this.password,
      role: role ?? this.role,
      noTelepon: noTelepon ?? this.noTelepon,
      alamat: alamat ?? this.alamat,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Validasi data user
  void validate() {
    if (username.isEmpty) throw Exception('Username tidak boleh kosong');
    if (username.length < 3) throw Exception('Username minimal 3 karakter');
    if (email.isEmpty) throw Exception('Email tidak boleh kosong');
    if (!email.contains('@')) throw Exception('Format email tidak valid');
    if (nama.isEmpty) throw Exception('Nama tidak boleh kosong');
    if (password.isEmpty) throw Exception('Password tidak boleh kosong');
    if (password.length < 6) throw Exception('Password minimal 6 karakter');
  }

  /// Get initials untuk avatar
  String get initials {
    final words = nama.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'U';
  }

  /// Get display name
  String get displayName => nama;

  /// Get role display name
  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.pegawai:
        return 'Pegawai';
      case UserRole.magang:
        return 'Magang';
    }
  }

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is pegawai
  bool get isPegawai => role == UserRole.pegawai;

  /// Check if user is magang
  bool get isMagang => role == UserRole.magang;

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, nama: $nama, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}