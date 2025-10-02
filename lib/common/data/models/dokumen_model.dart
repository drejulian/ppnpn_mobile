class DokumenModel {
  final int? id;
  final String userId;
  final String documentId;
  final String documentTitle;
  final String? filePath;
  final String? fileName;
  final String? fileType;
  final String? fileSize;
  final bool isRequired;
  final bool isUploaded;
  final DateTime? uploadedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  DokumenModel({
    this.id,
    required this.userId,
    required this.documentId,
    required this.documentTitle,
    this.filePath,
    this.fileName,
    this.fileType,
    this.fileSize,
    this.isRequired = false,
    this.isUploaded = false,
    this.uploadedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'document_id': documentId,
      'document_title': documentTitle,
      'file_path': filePath,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'is_required': isRequired ? 1 : 0,
      'is_uploaded': isUploaded ? 1 : 0,
      'uploaded_at': uploadedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DokumenModel.fromMap(Map<String, dynamic> map) {
    return DokumenModel(
      id: map['id']?.toInt(),
      userId: map['user_id'] ?? '',
      documentId: map['document_id'] ?? '',
      documentTitle: map['document_title'] ?? '',
      filePath: map['file_path'],
      fileName: map['file_name'],
      fileType: map['file_type'],
      fileSize: map['file_size'],
      isRequired: (map['is_required'] ?? 0) == 1,
      isUploaded: (map['is_uploaded'] ?? 0) == 1,
      uploadedAt: map['uploaded_at'] != null 
          ? DateTime.parse(map['uploaded_at']) 
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  DokumenModel copyWith({
    int? id,
    String? userId,
    String? documentId,
    String? documentTitle,
    String? filePath,
    String? fileName,
    String? fileType,
    String? fileSize,
    bool? isRequired,
    bool? isUploaded,
    DateTime? uploadedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DokumenModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      isRequired: isRequired ?? this.isRequired,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DokumenModel(id: $id, userId: $userId, documentId: $documentId, documentTitle: $documentTitle, isUploaded: $isUploaded)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DokumenModel &&
      other.id == id &&
      other.userId == userId &&
      other.documentId == documentId &&
      other.documentTitle == documentTitle &&
      other.filePath == filePath &&
      other.fileName == fileName &&
      other.fileType == fileType &&
      other.fileSize == fileSize &&
      other.isRequired == isRequired &&
      other.isUploaded == isUploaded &&
      other.uploadedAt == uploadedAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      documentId.hashCode ^
      documentTitle.hashCode ^
      filePath.hashCode ^
      fileName.hashCode ^
      fileType.hashCode ^
      fileSize.hashCode ^
      isRequired.hashCode ^
      isUploaded.hashCode ^
      uploadedAt.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}