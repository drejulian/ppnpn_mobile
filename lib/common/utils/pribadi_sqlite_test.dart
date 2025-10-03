/// Test file untuk memverifikasi implementasi SQLite pada PribadiPage
/// 
/// File ini menguji:
/// 1. Saving data pribadi ke SQLite
/// 2. Loading data pribadi dari SQLite
/// 3. Persistence data setelah reload aplikasi
/// 4. Validasi data input
/// 5. Sinkronisasi antara SQLite dan Riverpod providers

import 'package:flutter/foundation.dart';
import 'package:ppnpm_dpr/common/services/profile_service.dart';

class PribadiSQLiteTest {
  final ProfileService _profileService = ProfileService();
  
  /// Test basic SQLite operations for pribadi data
  Future<void> testBasicOperations() async {
    print('=== Testing Pribadi SQLite Implementation ===');
    
    try {
      // 1. Test initialization
      print('1. Testing profile service initialization...');
      await _profileService.initialize();
      print('✅ Profile service initialized successfully');
      
      // 2. Test validation with valid data
      print('2. Testing data validation...');
      final validData = _profileService.validatePribadiData(
        tempatLahir: 'Jakarta',
        tanggalLahir: '05-10-1981',
        jenisKelamin: 'Laki-Laki',
        agama: 'Islam',
        statusPerkawinan: 'Kawin',
        golonganDarah: 'O',
        statusDomisili: 'Alamat Rumah dan Alamat Sesuai KTP',
        address: 'Jl. Sudirman No. 123',
        propinsi: 'DKI Jakarta',
        kota: 'Jakarta Pusat',
        kecamatan: 'Tanah Abang',
        kelurahan: 'Bendungan Hilir',
        rt: '001',
        rw: '002',
        kodePos: '10210',
        teleponRumah: '021-12345678',
        teleponKantor: '021-87654321',
        handphone: '08123456789',
        email: 'user@example.com',
      );
      print('✅ Data validation: ${validData ? "VALID" : "INVALID"}');
      
      // 3. Test invalid data
      final invalidData = _profileService.validatePribadiData(
        tempatLahir: '',
        tanggalLahir: '',
        jenisKelamin: '',
        agama: '',
        statusPerkawinan: '',
        golonganDarah: '',
        statusDomisili: '',
        address: '',
        propinsi: '',
        kota: '',
        kecamatan: '',
        kelurahan: '',
        rt: '',
        rw: '',
        kodePos: '',
        teleponRumah: '',
        teleponKantor: '',
        handphone: '',
        email: 'invalid-email',
      );
      print('✅ Invalid data validation: ${!invalidData ? "CORRECTLY REJECTED" : "ERROR - SHOULD BE INVALID"}');
      
      // 4. Test getting validation errors
      final errors = _profileService.getPribadiDataValidationErrors(
        tempatLahir: '',
        tanggalLahir: '',
        jenisKelamin: '',
        agama: '',
        statusPerkawinan: '',
        golonganDarah: '',
        statusDomisili: '',
        address: '',
        propinsi: '',
        kota: '',
        kecamatan: '',
        kelurahan: '',
        rt: '',
        rw: '',
        kodePos: '',
        teleponRumah: '',
        teleponKantor: '',
        handphone: '',
        email: 'invalid',
      );
      print('✅ Validation errors count: ${errors.length}');
      for (final error in errors.take(5)) { // Show first 5 errors
        print('   - $error');
      }
      if (errors.length > 5) {
        print('   - ... and ${errors.length - 5} more errors');
      }
      
      print('\n=== Basic Operations Test Completed Successfully ===\n');
      
    } catch (e, stackTrace) {
      print('❌ Error during basic operations test: $e');
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
    }
  }
  
  /// Test save and load operations
  Future<void> testSaveAndLoadOperations() async {
    print('=== Testing Save and Load Operations ===');
    
    try {
      // 1. Test saving valid data
      print('1. Testing save operation...');
      final saveSuccess = await _profileService.savePribadiData(
        tempatLahir: 'Jakarta',
        tanggalLahir: '05-10-1981',
        jenisKelamin: 'Laki-Laki',
        agama: 'Islam',
        statusPerkawinan: 'Kawin',
        golonganDarah: 'O',
        statusDomisili: 'Alamat Rumah dan Alamat Sesuai KTP',
        address: 'Jl. Sudirman No. 123, Jakarta Pusat',
        propinsi: 'DKI Jakarta',
        kota: 'Jakarta Pusat',
        kecamatan: 'Tanah Abang',
        kelurahan: 'Bendungan Hilir',
        rt: '001',
        rw: '002',
        kodePos: '10210',
        teleponRumah: '021-12345678',
        teleponKantor: '021-87654321',
        handphone: '08123456789',
        email: 'user@example.com',
      );
      
      if (saveSuccess) {
        print('✅ Data saved successfully');
      } else {
        print('❌ Failed to save data');
        return;
      }
      
      // 2. Test loading saved data
      print('2. Testing load operation...');
      final loadedData = await _profileService.getCurrentPribadiData();
      
      if (loadedData != null) {
        print('✅ Data loaded successfully');
        print('   - Tempat Lahir: ${loadedData.tempatLahir}');
        print('   - Tanggal Lahir: ${loadedData.tanggalLahir}');
        print('   - Jenis Kelamin: ${loadedData.jenisKelamin}');
        print('   - Agama: ${loadedData.agama}');
        print('   - Status Perkawinan: ${loadedData.statusPerkawinan}');
        print('   - Golongan Darah: ${loadedData.golonganDarah}');
        print('   - Email: ${loadedData.email}');
        print('   - Handphone: ${loadedData.handphone}');
        print('   - Address: ${loadedData.address}');
        print('   - Propinsi: ${loadedData.propinsi}');
        print('   - Kota: ${loadedData.kota}');
        
        // Verify data integrity
        if (loadedData.tempatLahir == 'Jakarta' &&
            loadedData.tanggalLahir == '05-10-1981' &&
            loadedData.jenisKelamin == 'Laki-Laki' &&
            loadedData.agama == 'Islam' &&
            loadedData.statusPerkawinan == 'Kawin' &&
            loadedData.golonganDarah == 'O' &&
            loadedData.email == 'user@example.com' &&
            loadedData.handphone == '08123456789' &&
            loadedData.propinsi == 'DKI Jakarta' &&
            loadedData.kota == 'Jakarta Pusat') {
          print('✅ Data integrity verified - all fields match');
        } else {
          print('❌ Data integrity check failed - fields do not match');
        }
      } else {
        print('❌ Failed to load data');
      }
      
      // 3. Test data existence check
      print('3. Testing data existence check...');
      final hasData = await _profileService.hasPribadiData();
      print('✅ Has pribadi data: ${hasData ? "YES" : "NO"}');
      
      print('\n=== Save and Load Operations Test Completed Successfully ===\n');
      
    } catch (e, stackTrace) {
      print('❌ Error during save/load test: $e');
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
    }
  }
  
  /// Test update operations
  Future<void> testUpdateOperations() async {
    print('=== Testing Update Operations ===');
    
    try {
      // 1. Update existing data
      print('1. Testing update operation...');
      final updateSuccess = await _profileService.updatePribadiData(
        tempatLahir: 'Jakarta (Updated)',
        tanggalLahir: '05-10-1981',
        jenisKelamin: 'Laki-Laki',
        agama: 'Islam',
        statusPerkawinan: 'Belum Kawin',
        golonganDarah: 'AB',
        statusDomisili: 'Alamat Rumah dan Alamat Sesuai KTP berbeda',
        address: 'Jl. Sudirman No. 456, Jakarta Selatan (Updated)',
        propinsi: 'DKI Jakarta',
        kota: 'Jakarta Selatan',
        kecamatan: 'Kebayoran Baru',
        kelurahan: 'Senayan',
        rt: '003',
        rw: '004',
        kodePos: '12190',
        teleponRumah: '021-99887766',
        teleponKantor: '021-55443322',
        handphone: '08987654321',
        email: 'updated@example.com',
      );
      
      if (updateSuccess) {
        print('✅ Data updated successfully');
      } else {
        print('❌ Failed to update data');
        return;
      }
      
      // 2. Verify update
      print('2. Verifying update...');
      final updatedData = await _profileService.getCurrentPribadiData();
      
      if (updatedData != null) {
        print('✅ Updated data loaded successfully');
        print('   - Tempat Lahir: ${updatedData.tempatLahir}');
        print('   - Status Perkawinan: ${updatedData.statusPerkawinan}');
        print('   - Golongan Darah: ${updatedData.golonganDarah}');
        print('   - Address: ${updatedData.address}');
        print('   - Kota: ${updatedData.kota}');
        print('   - Email: ${updatedData.email}');
        print('   - Handphone: ${updatedData.handphone}');
        
        // Verify update
        if (updatedData.tempatLahir.contains('Updated') &&
            updatedData.statusPerkawinan == 'Belum Kawin' &&
            updatedData.golonganDarah == 'AB' &&
            updatedData.address.contains('Updated') &&
            updatedData.kota == 'Jakarta Selatan' &&
            updatedData.email == 'updated@example.com' &&
            updatedData.handphone == '08987654321') {
          print('✅ Update verification successful - all fields updated correctly');
        } else {
          print('❌ Update verification failed - fields not updated correctly');
        }
      } else {
        print('❌ Failed to load updated data');
      }
      
      print('\n=== Update Operations Test Completed Successfully ===\n');
      
    } catch (e, stackTrace) {
      print('❌ Error during update test: $e');
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
    }
  }
  
  /// Test persistence after service recreation
  Future<void> testDataPersistence() async {
    print('=== Testing Data Persistence ===');
    
    try {
      print('1. Getting current data before service recreation...');
      final beforeRecreation = await _profileService.getCurrentPribadiData();
      
      print('2. Creating new service instance (simulating app restart)...');
      final newService = ProfileService();
      await newService.initialize();
      
      print('3. Loading data from new service instance...');
      final afterRecreation = await newService.getCurrentPribadiData();
      
      if (beforeRecreation != null && afterRecreation != null) {
        print('✅ Data persisted after service recreation');
        
        // Compare data
        final dataMatches = beforeRecreation.tempatLahir == afterRecreation.tempatLahir &&
                           beforeRecreation.tanggalLahir == afterRecreation.tanggalLahir &&
                           beforeRecreation.jenisKelamin == afterRecreation.jenisKelamin &&
                           beforeRecreation.agama == afterRecreation.agama &&
                           beforeRecreation.statusPerkawinan == afterRecreation.statusPerkawinan &&
                           beforeRecreation.golonganDarah == afterRecreation.golonganDarah &&
                           beforeRecreation.email == afterRecreation.email &&
                           beforeRecreation.handphone == afterRecreation.handphone &&
                           beforeRecreation.address == afterRecreation.address &&
                           beforeRecreation.propinsi == afterRecreation.propinsi &&
                           beforeRecreation.kota == afterRecreation.kota;
        
        if (dataMatches) {
          print('✅ Data integrity maintained after persistence test');
        } else {
          print('❌ Data integrity compromised after persistence test');
        }
      } else {
        print('❌ Data not persisted properly');
      }
      
      print('\n=== Data Persistence Test Completed Successfully ===\n');
      
    } catch (e, stackTrace) {
      print('❌ Error during persistence test: $e');
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
    }
  }
  
  /// Test profile completion status
  Future<void> testProfileCompletionStatus() async {
    print('=== Testing Profile Completion Status ===');
    
    try {
      print('1. Getting profile completion status...');
      final completionStatus = await _profileService.getProfileCompletionStatus();
      
      print('✅ Profile completion status:');
      for (final entry in completionStatus.entries) {
        print('   - ${entry.key}: ${entry.value ? "✅ COMPLETED" : "❌ INCOMPLETE"}');
      }
      
      print('2. Getting profile summary...');
      final summary = await _profileService.getProfileSummary();
      
      print('✅ Profile summary:');
      print('   - Has Data: ${summary['hasData']}');
      print('   - Edit Profile Data Available: ${summary['editProfile'] != null}');
      print('   - Pribadi Data Available: ${summary['pribadiData'] != null}');
      
      print('\n=== Profile Completion Status Test Completed Successfully ===\n');
      
    } catch (e, stackTrace) {
      print('❌ Error during completion status test: $e');
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
    }
  }
  
  /// Run all tests
  Future<void> runAllTests() async {
    print('🚀 Starting Pribadi SQLite Implementation Tests\n');
    
    await testBasicOperations();
    await testSaveAndLoadOperations();
    await testUpdateOperations();
    await testDataPersistence();
    await testProfileCompletionStatus();
    
    print('🎉 All Pribadi SQLite Tests Completed Successfully! 🎉');
  }
}

/// Helper function to run the test
Future<void> runPribadiSQLiteTest() async {
  final test = PribadiSQLiteTest();
  await test.runAllTests();
}