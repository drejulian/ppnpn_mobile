import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileStorageService {
  static const String _dokumenAnggotaFolder = 'dokumen_anggota';

  // Get application documents directory
  Future<Directory> _getAppDocumentsDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir;
  }

  // Create dokumen anggota directory if it doesn't exist
  Future<Directory> _getDokumenAnggotaDirectory() async {
    final appDocDir = await _getAppDocumentsDirectory();
    final dokumenDir = Directory(path.join(appDocDir.path, _dokumenAnggotaFolder));
    
    if (!await dokumenDir.exists()) {
      await dokumenDir.create(recursive: true);
      print('📁 Created dokumen anggota directory: ${dokumenDir.path}');
    }
    
    return dokumenDir;
  }

  // Copy uploaded file to app storage
  Future<File> saveUploadedFile({
    required File sourceFile,
    required String namaAnggota,
    required String documentId,
    required String originalFileName,
  }) async {
    try {
      print('💾 Starting file save process...'); // Debug log
      print('   Source file: ${sourceFile.path}');
      print('   Nama anggota: $namaAnggota');
      print('   Document ID: $documentId');
      print('   Original filename: $originalFileName');

      // Get dokumen anggota directory
      final dokumenDir = await _getDokumenAnggotaDirectory();
      
      // Create subdirectory for the member
      final memberDir = Directory(path.join(dokumenDir.path, _sanitizeFileName(namaAnggota)));
      if (!await memberDir.exists()) {
        await memberDir.create(recursive: true);
        print('📁 Created member directory: ${memberDir.path}');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(originalFileName);
      final newFileName = '${documentId}_${timestamp}$extension';
      
      // Create destination path
      final destinationPath = path.join(memberDir.path, newFileName);
      final destinationFile = File(destinationPath);

      // Copy file to destination
      final copiedFile = await sourceFile.copy(destinationPath);
      print('✅ File saved successfully: ${copiedFile.path}');

      return copiedFile;
    } catch (e) {
      print('❌ Error saving file: $e'); // Debug log
      throw Exception('Failed to save file: $e');
    }
  }

  // Delete file from storage
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ File deleted: $filePath');
        return true;
      } else {
        print('⚠️ File not found: $filePath');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting file: $e'); // Debug log
      return false;
    }
  }

  // Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      print('❌ Error checking file existence: $e'); // Debug log
      return false;
    }
  }

  // Get file size
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      print('❌ Error getting file size: $e'); // Debug log
      return 0;
    }
  }

  // Format file size to human readable string
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  // Sanitize filename for safe storage
  String _sanitizeFileName(String fileName) {
    // Remove or replace invalid characters
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  // Get all files for a member
  Future<List<File>> getMemberFiles(String namaAnggota) async {
    try {
      final dokumenDir = await _getDokumenAnggotaDirectory();
      final memberDir = Directory(path.join(dokumenDir.path, _sanitizeFileName(namaAnggota)));
      
      if (!await memberDir.exists()) {
        return [];
      }

      final files = <File>[];
      await for (final entity in memberDir.list()) {
        if (entity is File) {
          files.add(entity);
        }
      }

      return files;
    } catch (e) {
      print('❌ Error getting member files: $e'); // Debug log
      return [];
    }
  }

  // Clean up orphaned files (files without database entries)
  Future<void> cleanupOrphanedFiles() async {
    try {
      final dokumenDir = await _getDokumenAnggotaDirectory();
      
      if (!await dokumenDir.exists()) {
        return;
      }

      print('🧹 Starting cleanup of orphaned files...');
      
      // This is a basic implementation
      // In a production app, you would compare with database entries
      // and remove files that don't have corresponding database records
      
      print('🧹 Cleanup completed');
    } catch (e) {
      print('❌ Error during cleanup: $e'); // Debug log
    }
  }

  // Get storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final dokumenDir = await _getDokumenAnggotaDirectory();
      
      int totalFiles = 0;
      int totalSize = 0;

      await for (final entity in dokumenDir.list(recursive: true)) {
        if (entity is File) {
          totalFiles++;
          totalSize += await entity.length();
        }
      }

      return {
        'totalFiles': totalFiles,
        'totalSize': totalSize,
        'totalSizeFormatted': formatFileSize(totalSize),
        'storagePath': dokumenDir.path,
      };
    } catch (e) {
      print('❌ Error getting storage info: $e'); // Debug log
      return {
        'totalFiles': 0,
        'totalSize': 0,
        'totalSizeFormatted': '0 B',
        'storagePath': '',
      };
    }
  }
}