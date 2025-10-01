class TataNaskahModel {
  final int? id;
  final String namaAnggota;
  final String documentId;
  final String documentTitle;
  final String fileName;
  final String filePath;
  final String fileType;
  final String fileSize;
  final bool isRequired;
  final bool isUploaded;
  final String? uploadedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  TataNaskahModel({
    this.id,
    required this.namaAnggota,
    required this.documentId,
    required this.documentTitle,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.isRequired,
    required this.isUploaded,
    this.uploadedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Map (database) to Model
  factory TataNaskahModel.fromMap(Map<String, dynamic> map) {
    return TataNaskahModel(
      id: map['id'] as int?,
      namaAnggota: map['nama_anggota'] as String,
      documentId: map['document_id'] as String,
      documentTitle: map['document_title'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      fileType: map['file_type'] as String,
      fileSize: map['file_size'] as String,
      isRequired: (map['is_required'] as int) == 1,
      isUploaded: (map['is_uploaded'] as int) == 1,
      uploadedAt: map['uploaded_at'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert from Model to Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_anggota': namaAnggota,
      'document_id': documentId,
      'document_title': documentTitle,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'is_required': isRequired ? 1 : 0,
      'is_uploaded': isUploaded ? 1 : 0,
      'uploaded_at': uploadedAt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  TataNaskahModel copyWith({
    int? id,
    String? namaAnggota,
    String? documentId,
    String? documentTitle,
    String? fileName,
    String? filePath,
    String? fileType,
    String? fileSize,
    bool? isRequired,
    bool? isUploaded,
    String? uploadedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TataNaskahModel(
      id: id ?? this.id,
      namaAnggota: namaAnggota ?? this.namaAnggota,
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
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
    return 'TataNaskahModel{id: $id, namaAnggota: $namaAnggota, documentId: $documentId, fileName: $fileName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TataNaskahModel &&
        other.id == id &&
        other.namaAnggota == namaAnggota &&
        other.documentId == documentId &&
        other.fileName == fileName &&
        other.filePath == filePath &&
        other.fileType == fileType &&
        other.fileSize == fileSize &&
        other.isRequired == isRequired &&
        other.isUploaded == isUploaded;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      namaAnggota,
      documentId,
      fileName,
      filePath,
      fileType,
      fileSize,
      isRequired,
      isUploaded,
    );
  }
}