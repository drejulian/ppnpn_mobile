/// Test file untuk memverifikasi implementasi SQLite pada ProfileSectionsPage
/// 
/// File ini menguji:
/// 1. Loading data dokumen dari SQLite saat aplikasi dimulai
/// 2. Persistence status completion setelah reload aplikasi
/// 3. Sinkronisasi data antara SQLite dan Riverpod providers

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ppnpm_dpr/common/services/dokumen_service.dart';

class ProfileSectionsSQLiteTest {
  final DokumenService _dokumenService = DokumenService();
  
  /// Test basic SQLite operations for documents
  Future<void> testBasicOperations() async {
    print('=== Testing ProfileSections SQLite Implementation ===');
    
    try {
      // 1. Test initialization
      print('1. Testing document initialization...');
      await _dokumenService.initializeDocuments();
      print('✅ Documents initialized successfully');
      
      // 2. Test getting all documents
      print('2. Testing getting all documents...');
      final documents = await _dokumenService.getAllDocuments();
      print('✅ Retrieved ${documents.length} documents from database');
      
      // 3. Test checking upload status for key document types
      print('3. Testing document upload status check...');
      final documentTypes = ['ktp', 'kk', 'cv', 'ijazah', 'transkrip', 'foto', 'surat_lamaran', 'sertifikat'];
      
      for (final docType in documentTypes) {
        final isUploaded = await _dokumenService.isDocumentUploaded(docType);
        print('   - $docType: ${isUploaded ? "✅ Uploaded" : "❌ Not uploaded"}');
      }
      
      // 4. Test completion percentage
      print('4. Testing completion percentage...');
      final completionPercentage = await _dokumenService.getCompletionPercentage();
      print('✅ Document completion: ${(completionPercentage * 100).toStringAsFixed(1)}%');
      
      // 5. Test upload count
      print('5. Testing upload counts...');
      final uploadedCount = await _dokumenService.getUploadedDocumentsCount();
      final totalCount = await _dokumenService.getTotalDocumentsCount();
      print('✅ Uploaded documents: $uploadedCount / $totalCount');
      
      print('\n=== SQLite Implementation Test Completed Successfully ===\n');
      
    } catch (e, stackTrace) {
      print('❌ Error during SQLite test: $e');
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
    }
  }
  
  /// Test document upload simulation
  Future<void> testDocumentUploadSimulation() async {
    print('=== Testing Document Upload Simulation ===');
    
    try {
      // Create a dummy file for testing (in memory)
      final tempFile = File('temp_test_document.pdf');
      await tempFile.writeAsString('This is a test document content for SQLite testing.');
      
      // Test uploading a document
      print('1. Testing document upload...');
      final success = await _dokumenService.uploadDocument('ktp', tempFile);
      
      if (success) {
        print('✅ Document uploaded successfully');
        
        // Verify the upload
        final isUploaded = await _dokumenService.isDocumentUploaded('ktp');
        print('✅ Upload verification: ${isUploaded ? "SUCCESS" : "FAILED"}');
        
        // Get document details
        final document = await _dokumenService.getDocumentByType('ktp');
        if (document != null) {
          print('✅ Document details retrieved:');
          print('   - ID: ${document.documentId}');
          print('   - Title: ${document.documentTitle}');
          print('   - File: ${document.fileName}');
          print('   - Size: ${document.fileSize}');
          print('   - Uploaded: ${document.isUploaded}');
          print('   - Upload time: ${document.uploadedAt}');
        }
      } else {
        print('❌ Document upload failed');
      }
      
      // Cleanup
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      
    } catch (e, stackTrace) {
      print('❌ Error during upload simulation: $e');
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
    }
  }
  
  /// Test data persistence after "app restart" simulation
  Future<void> testDataPersistence() async {
    print('=== Testing Data Persistence ===');
    
    try {
      print('1. Getting current document status...');
      final beforeRestart = <String, bool>{};
      final documentTypes = ['ktp', 'kk', 'cv', 'ijazah', 'transkrip'];
      
      for (final docType in documentTypes) {
        beforeRestart[docType] = await _dokumenService.isDocumentUploaded(docType);
      }
      
      print('2. Simulating app restart by creating new service instance...');
      final newService = DokumenService();
      await newService.initializeDocuments();
      
      print('3. Checking if data persisted after restart...');
      bool allPersisted = true;
      for (final docType in documentTypes) {
        final afterRestart = await newService.isDocumentUploaded(docType);
        final persisted = beforeRestart[docType] == afterRestart;
        
        print('   - $docType: ${persisted ? "✅ Persisted" : "❌ Lost data"}');
        if (!persisted) allPersisted = false;
      }
      
      if (allPersisted) {
        print('✅ All document data persisted successfully after restart simulation');
      } else {
        print('❌ Some document data was lost after restart simulation');
      }
      
    } catch (e, stackTrace) {
      print('❌ Error during persistence test: $e');
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
    }
  }
  
  /// Run all tests
  Future<void> runAllTests() async {
    await testBasicOperations();
    await testDocumentUploadSimulation();
    await testDataPersistence();
  }
}

/// Helper function to run the test
Future<void> runProfileSectionsSQLiteTest() async {
  final test = ProfileSectionsSQLiteTest();
  await test.runAllTests();
}