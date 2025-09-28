class DokumenAnggotaModel {
  final int? id;
  final String namaAnggota;
  final String documentId;
  final String documentTitle;
  final String filePath;
  final String fileName;
  final String fileType;
  final String fileSize;
  final bool isRequired;
  final String uploadedAt;
  final String createdAt;
  final String updatedAt;

  DokumenAnggotaModel({
    this.id,
    required this.namaAnggota,
    required this.documentId,
    required this.documentTitle,
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.isRequired,
    required this.uploadedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DokumenAnggotaModel.fromMap(Map<String, dynamic> map) {
    return DokumenAnggotaModel(
      id: map['id'],
      namaAnggota: map['nama_anggota'] ?? '',
      documentId: map['document_id'] ?? '',
      documentTitle: map['document_title'] ?? '',
      filePath: map['file_path'] ?? '',
      fileName: map['file_name'] ?? '',
      fileType: map['file_type'] ?? '',
      fileSize: map['file_size'] ?? '',
      isRequired: (map['is_required'] ?? 0) == 1,
      uploadedAt: map['uploaded_at'] ?? '',
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_anggota': namaAnggota,
      'document_id': documentId,
      'document_title': documentTitle,
      'file_path': filePath,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'is_required': isRequired ? 1 : 0,
      'uploaded_at': uploadedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  DokumenAnggotaModel copyWith({
    int? id,
    String? namaAnggota,
    String? documentId,
    String? documentTitle,
    String? filePath,
    String? fileName,
    String? fileType,
    String? fileSize,
    bool? isRequired,
    String? uploadedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return DokumenAnggotaModel(
      id: id ?? this.id,
      namaAnggota: namaAnggota ?? this.namaAnggota,
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      isRequired: isRequired ?? this.isRequired,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DokumenAnggotaModel(id: $id, namaAnggota: $namaAnggota, documentId: $documentId, documentTitle: $documentTitle, fileName: $fileName, fileType: $fileType, fileSize: $fileSize, isRequired: $isRequired, uploadedAt: $uploadedAt)';
  }
}