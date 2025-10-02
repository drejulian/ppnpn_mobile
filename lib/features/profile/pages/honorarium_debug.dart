import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/services/profile_service.dart';

/// Debug page to test Honorarium SQLite operations
class HonorariumDebugPage extends ConsumerStatefulWidget {
  const HonorariumDebugPage({super.key});

  @override
  ConsumerState<HonorariumDebugPage> createState() => _HonorariumDebugPageState();
}

class _HonorariumDebugPageState extends ConsumerState<HonorariumDebugPage> {
  final ProfileService _profileService = ProfileService();
  String _debugOutput = '';

  void _addDebugOutput(String message) {
    setState(() {
      _debugOutput += '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
  }

  Future<void> _testHonorariumRetrieval() async {
    _addDebugOutput('=== Testing Honorarium Retrieval ===');
    
    try {
      final data = await _profileService.getCurrentHonorariumData();
      if (data != null) {
        _addDebugOutput('✅ Found existing honorarium data');
        _addDebugOutput('Kartu Keluarga: ${data.kartuKeluarga}');
        _addDebugOutput('KTP: ${data.ktp}');
        _addDebugOutput('Nama KTP: ${data.namaKtp}');
        _addDebugOutput('NPWP: ${data.npwp}');
        _addDebugOutput('Rekening: ${data.rekening}');
      } else {
        _addDebugOutput('ℹ️ No existing honorarium data found');
      }
      
      final hasData = await _profileService.hasHonorariumData();
      _addDebugOutput('Has honorarium data: $hasData');
    } catch (e) {
      _addDebugOutput('❌ Error retrieving data: $e');
    }
  }

  Future<void> _testHonorariumSave() async {
    _addDebugOutput('=== Testing Honorarium Save ===');
    
    try {
      final success = await _profileService.saveHonorariumData(
        kartuKeluarga: '1234567890123456',
        ktp: '0987654321098765',
        namaKtp: 'TEST USER HONORARIUM',
        bpjsKesehatan: '123456789012',
        npwp: '12.345.678.9-012.345',
        namaIbu: 'IBU TEST',
        rekening: '1234567890',
        namaPemilikRek: 'TEST USER',
        statusPTKP: 'Kawin (K)',
        jumlahAnak: '2',
      );
      
      _addDebugOutput('Save result: $success');
      
      if (success) {
        _addDebugOutput('✅ Data saved successfully');
        
        // Try to retrieve the data
        final data = await _profileService.getCurrentHonorariumData();
        if (data != null) {
          _addDebugOutput('✅ Data retrieved successfully');
          _addDebugOutput('Kartu Keluarga: ${data.kartuKeluarga}');
          _addDebugOutput('KTP: ${data.ktp}');
          _addDebugOutput('NPWP: ${data.npwp}');
        } else {
          _addDebugOutput('❌ Failed to retrieve saved data');
        }
      } else {
        _addDebugOutput('❌ Failed to save data');
      }
    } catch (e) {
      _addDebugOutput('❌ Save error: $e');
    }
  }

  Future<void> _testHonorariumValidation() async {
    _addDebugOutput('=== Testing Honorarium Validation ===');
    
    // Test with valid data
    final validErrors = _profileService.getHonorariumDataValidationErrors(
      kartuKeluarga: '1234567890123456',
      ktp: '0987654321098765',
      namaKtp: 'TEST USER',
      bpjsKesehatan: '123456789012',
      npwp: '12.345.678.9-012.345',
      namaIbu: 'IBU TEST',
      rekening: '1234567890',
      namaPemilikRek: 'TEST USER',
      statusPTKP: 'Kawin (K)',
      jumlahAnak: '2',
    );
    
    _addDebugOutput('Valid data validation errors: ${validErrors.length}');
    for (final error in validErrors) {
      _addDebugOutput('  - $error');
    }
    
    // Test with invalid data
    final invalidErrors = _profileService.getHonorariumDataValidationErrors(
      kartuKeluarga: '',
      ktp: '',
      namaKtp: '',
      bpjsKesehatan: '',
      npwp: '',
      namaIbu: '',
      rekening: '',
      namaPemilikRek: '',
      statusPTKP: '',
      jumlahAnak: '',
    );
    
    _addDebugOutput('Invalid data validation errors: ${invalidErrors.length}');
    for (final error in invalidErrors) {
      _addDebugOutput('  - $error');
    }
    
    if (validErrors.isEmpty) {
      _addDebugOutput('✅ Valid data validation passed');
    }
    
    if (invalidErrors.isNotEmpty) {
      _addDebugOutput('✅ Invalid data validation working correctly');
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
        title: const Text('Honorarium Debug'),
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
                        onPressed: _testHonorariumRetrieval,
                        child: const Text('Test Retrieval'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _testHonorariumValidation,
                        child: const Text('Test Validation'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _testHonorariumSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Save Operation'),
                  ),
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
                      ? 'Honorarium debug output will appear here...\n\nUse the buttons above to test various operations.'
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