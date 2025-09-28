class MediaSosialAnggotaModel {
  final int? id;
  final String platform;
  final String username;
  final String url;
  final int followers;
  final bool isVerified;
  final String status; // 'aktif', 'tidak_aktif'
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaSosialAnggotaModel({
    this.id,
    required this.platform,
    required this.username,
    required this.url,
    this.followers = 0,
    this.isVerified = false,
    this.status = 'aktif',
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'platform': platform,
      'username': username,
      'url': url,
      'followers': followers,
      'is_verified': isVerified ? 1 : 0,
      'status': status,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MediaSosialAnggotaModel.fromMap(Map<String, dynamic> map) {
    return MediaSosialAnggotaModel(
      id: map['id']?.toInt(),
      platform: map['platform'] ?? '',
      username: map['username'] ?? '',
      url: map['url'] ?? '',
      followers: map['followers']?.toInt() ?? 0,
      isVerified: (map['is_verified'] ?? 0) == 1,
      status: map['status'] ?? 'aktif',
      userId: map['user_id']?.toInt(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  MediaSosialAnggotaModel copyWith({
    int? id,
    String? platform,
    String? username,
    String? url,
    int? followers,
    bool? isVerified,
    String? status,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaSosialAnggotaModel(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      username: username ?? this.username,
      url: url ?? this.url,
      followers: followers ?? this.followers,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MediaSosialAnggotaModel(id: $id, platform: $platform, username: $username, url: $url, followers: $followers, isVerified: $isVerified, status: $status, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaSosialAnggotaModel &&
        other.id == id &&
        other.platform == platform &&
        other.username == username &&
        other.url == url &&
        other.followers == followers &&
        other.isVerified == isVerified &&
        other.status == status &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        platform.hashCode ^
        username.hashCode ^
        url.hashCode ^
        followers.hashCode ^
        isVerified.hashCode ^
        status.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}