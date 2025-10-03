import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/services/profile_service.dart';

/// Debug page to test ID Card SQLite operations
class IdCardDebugPage extends ConsumerStatefulWidget {
  const IdCardDebugPage({super.key});

  @override
  ConsumerState<IdCardDebugPage> createState() => _IdCardDebugPageState();
}

class _IdCardDebugPageState extends ConsumerState<IdCardDebugPage> {
  final ProfileService _profileService = ProfileService();
  String _debugOutput = '';

  void _addDebugOutput(String message) {
    setState(() {
      _debugOutput += '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
  }

  Future<void> _testIdCardRetrieval() async {
    _addDebugOutput('=== Testing ID Card Retrieval ===');
    
    try {
      final data = await _profileService.getCurrentIdCardData();
      if (data != null) {
        _addDebugOutput('✅ Found existing ID card data');
        _addDebugOutput('Foto Path: ${data.fotoPath}');
        _addDebugOutput('Is Uploaded: ${data.isUploaded}');
        _addDebugOutput('Created At: ${data.createdAt}');
        _addDebugOutput('Updated At: ${data.updatedAt}');
        
        // Check if file exists
        if (data.fotoPath.isNotEmpty) {
          final file = File(data.fotoPath);
          _addDebugOutput('File exists: ${file.existsSync()}');
          if (file.existsSync()) {
            final fileSize = await file.length();
            _addDebugOutput('File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
          }
        }
      } else {
        _addDebugOutput('ℹ️ No existing ID card data found');
      }
      
      final hasData = await _profileService.hasIdCardData();
      _addDebugOutput('Has ID card data: $hasData');
    } catch (e) {
      _addDebugOutput('❌ Error retrieving data: $e');
    }
  }

  Future<void> _testIdCardSave() async {
    _addDebugOutput('=== Testing ID Card Save ===');
    
    try {
      // Test with no photo (valid case)
      final successNoPhoto = await _profileService.saveIdCardData(
        fotoPath: '',
        isUploaded: false,
      );
      
      _addDebugOutput('Save without photo result: $successNoPhoto');
      
      if (successNoPhoto) {
        _addDebugOutput('✅ Data saved successfully (no photo)');
        
        // Try to retrieve the data
        final data = await _profileService.getCurrentIdCardData();
        if (data != null) {
          _addDebugOutput('✅ Data retrieved successfully');
          _addDebugOutput('Foto Path: "${data.fotoPath}"');
          _addDebugOutput('Is Uploaded: ${data.isUploaded}');
        } else {
          _addDebugOutput('❌ Failed to retrieve saved data');
        }
      } else {
        _addDebugOutput('❌ Failed to save data (no photo)');
      }

      // Test with dummy photo path (simulation)
      final successWithPhoto = await _profileService.saveIdCardData(
        fotoPath: '/dummy/path/test_photo.jpg',
        isUploaded: true,
      );
      
      _addDebugOutput('Save with dummy photo result: $successWithPhoto');
      
      if (successWithPhoto) {
        _addDebugOutput('✅ Data saved successfully (with dummy photo)');
      } else {
        _addDebugOutput('❌ Failed to save data (with dummy photo)');
      }
    } catch (e) {
      _addDebugOutput('❌ Save error: $e');
    }
  }

  Future<void> _testIdCardValidation() async {
    _addDebugOutput('=== Testing ID Card Validation ===');
    
    // Test with valid data (no photo)
    final validNoPhotoErrors = _profileService.getIdCardDataValidationErrors(
      fotoPath: '',
      isUploaded: false,
    );
    
    _addDebugOutput('Valid data (no photo) validation errors: ${validNoPhotoErrors.length}');
    for (final error in validNoPhotoErrors) {
      _addDebugOutput('  - $error');
    }
    
    // Test with valid data (with photo path)
    final validWithPhotoErrors = _profileService.getIdCardDataValidationErrors(
      fotoPath: '/dummy/path/test_photo.jpg',
      isUploaded: true,
    );
    
    _addDebugOutput('Valid data (with photo) validation errors: ${validWithPhotoErrors.length}');
    for (final error in validWithPhotoErrors) {
      _addDebugOutput('  - $error');
    }
    
    // Test with invalid data (uploaded but no path)
    final invalidErrors = _profileService.getIdCardDataValidationErrors(
      fotoPath: '',
      isUploaded: true,
    );
    
    _addDebugOutput('Invalid data validation errors: ${invalidErrors.length}');
    for (final error in invalidErrors) {
      _addDebugOutput('  - $error');
    }
    
    if (validNoPhotoErrors.isEmpty) {
      _addDebugOutput('✅ Valid data (no photo) validation passed');
    }
    
    if (invalidErrors.isNotEmpty) {
      _addDebugOutput('✅ Invalid data validation working correctly');
    }
  }

  Future<void> _testIdCardDelete() async {
    _addDebugOutput('=== Testing ID Card Delete ===');
    
    try {
      // First save some test data
      await _profileService.saveIdCardData(
        fotoPath: '/test/delete/path.jpg',
        isUploaded: false,
      );
      
      _addDebugOutput('Test data saved for deletion test');
      
      // Check if data exists before deletion
      final existsBefore = await _profileService.hasIdCardData();
      _addDebugOutput('Data exists before deletion: $existsBefore');
      
      // Note: We don't have a direct delete method in ProfileService
      // This would require adding one or accessing repository directly
      _addDebugOutput('ℹ️ Delete method not implemented in ProfileService');
      _addDebugOutput('ℹ️ Would need to add deleteIdCardData() method to service');
    } catch (e) {
      _addDebugOutput('❌ Delete test error: $e');
    }
  }

  void _clearDebug() {
    setState(() {
      _debugOutput = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Card Debug'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _clearDebug,
            icon: const Icon(Icons.clear),
            tooltip: 'Clear Debug Output',
          ),
        ],
      ),
      body: Column(
        children: [
          // Test Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _testIdCardRetrieval,
                        child: const Text('Test Retrieval'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _testIdCardValidation,
                        child: const Text('Test Validation'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _testIdCardSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Test Save'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _testIdCardDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Test Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Debug Output
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _debugOutput.isEmpty 
                      ? 'ID Card debug output will appear here...\n\nUse the buttons above to test various operations.'
                      : _debugOutput,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}