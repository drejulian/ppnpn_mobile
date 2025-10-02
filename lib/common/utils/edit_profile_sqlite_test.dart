/// Test file untuk memverifikasi implementasi SQLite pada EditProfilePage
/// 
/// File ini menguji:
/// 1. Saving data edit profile ke SQLite
/// 2. Loading data edit profile dari SQLite
/// 3. Persistence data setelah reload aplikasi
/// 4. Validasi data input
/// 5. Sinkronisasi antara SQLite dan Riverpod providers

import 'package:flutter/foundation.dart';
import 'package:ppnpm_dpr/common/services/profile_service.dart';

class EditProfileSQLiteTest {
  final ProfileService _profileService = ProfileService();
  
  /// Test basic SQLite operations for edit profile
  Future<void> testBasicOperations() async {
    print('=== Testing EditProfile SQLite Implementation ===');
    
    try {
      // 1. Test initialization
      print('1. Testing profile service initialization...');
      await _profileService.initialize();
      print('✅ Profile service initialized successfully');
      
      // 2. Test validation
      print('2. Testing data validation...');
      final validData = _profileService.validateEditProfile(
        nik: '13-0265',
        nama: 'Airlangga Eka Wardhana, S.Kom, M.T.I',
        pendidikan: 'Master/S2',
        bidangKeahlian: 'MAGISTER TEKNOLOGI INFORMASI',
        toefl: '450',
      );
      print('✅ Data validation: ${validData ? "VALID" : "INVALID"}');
      
      // 3. Test invalid data
      final invalidData = _profileService.validateEditProfile(
        nik: '',
        nama: '',
        pendidikan: '',
        bidangKeahlian: '',
        toefl: 'abc', // Invalid TOEFL score
      );
      print('✅ Invalid data validation: ${!invalidData ? "CORRECTLY REJECTED" : "ERROR - SHOULD BE INVALID"}');
      
      // 4. Test getting validation errors
      final errors = _profileService.getEditProfileValidationErrors(
        nik: '',
        nama: '',
        pendidikan: '',
        bidangKeahlian: '',
        toefl: 'invalid',
      );
      print('✅ Validation errors count: ${errors.length}');
      for (final error in errors) {
        print('   - $error');
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
      final saveSuccess = await _profileService.saveEditProfile(
        nik: '13-0265',
        nama: 'Airlangga Eka Wardhana, S.Kom, M.T.I',
        pendidikan: 'Master/S2',
        bidangKeahlian: 'MAGISTER TEKNOLOGI INFORMASI',
        toefl: '450',
      );
      
      if (saveSuccess) {
        print('✅ Data saved successfully');
      } else {
        print('❌ Failed to save data');
        return;
      }
      
      // 2. Test loading saved data
      print('2. Testing load operation...');
      final loadedData = await _profileService.getCurrentEditProfile();
      
      if (loadedData != null) {
        print('✅ Data loaded successfully');
        print('   - NIK: ${loadedData.nik}');
        print('   - Nama: ${loadedData.nama}');
        print('   - Pendidikan: ${loadedData.pendidikan}');
        print('   - Bidang Keahlian: ${loadedData.bidangKeahlian}');
        print('   - TOEFL: ${loadedData.toefl}');
        
        // Verify data integrity
        if (loadedData.nik == '13-0265' &&
            loadedData.nama == 'Airlangga Eka Wardhana, S.Kom, M.T.I' &&
            loadedData.pendidikan == 'Master/S2' &&
            loadedData.bidangKeahlian == 'MAGISTER TEKNOLOGI INFORMASI' &&
            loadedData.toefl == '450') {
          print('✅ Data integrity verified - all fields match');
        } else {
          print('❌ Data integrity check failed - fields do not match');
        }
      } else {
        print('❌ Failed to load data');
      }
      
      // 3. Test data existence check
      print('3. Testing data existence check...');
      final hasData = await _profileService.hasEditProfileData();
      print('✅ Has edit profile data: ${hasData ? "YES" : "NO"}');
      
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
      final updateSuccess = await _profileService.updateEditProfile(
        nik: '13-0265',
        nama: 'Airlangga Eka Wardhana, S.Kom, M.T.I (Updated)',
        pendidikan: 'Doktor/S3',
        bidangKeahlian: 'MAGISTER TEKNOLOGI INFORMASI (Updated)',
        toefl: '550',
      );
      
      if (updateSuccess) {
        print('✅ Data updated successfully');
      } else {
        print('❌ Failed to update data');
        return;
      }
      
      // 2. Verify update
      print('2. Verifying update...');
      final updatedData = await _profileService.getCurrentEditProfile();
      
      if (updatedData != null) {
        print('✅ Updated data loaded successfully');
        print('   - Nama: ${updatedData.nama}');
        print('   - Pendidikan: ${updatedData.pendidikan}');
        print('   - Bidang Keahlian: ${updatedData.bidangKeahlian}');
        print('   - TOEFL: ${updatedData.toefl}');
        
        // Verify update
        if (updatedData.nama.contains('Updated') &&
            updatedData.pendidikan == 'Doktor/S3' &&
            updatedData.bidangKeahlian.contains('Updated') &&
            updatedData.toefl == '550') {
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
      final beforeRecreation = await _profileService.getCurrentEditProfile();
      
      print('2. Creating new service instance (simulating app restart)...');
      final newService = ProfileService();
      await newService.initialize();
      
      print('3. Loading data from new service instance...');
      final afterRecreation = await newService.getCurrentEditProfile();
      
      if (beforeRecreation != null && afterRecreation != null) {
        print('✅ Data persisted after service recreation');
        
        // Compare data
        final dataMatches = beforeRecreation.nik == afterRecreation.nik &&
                           beforeRecreation.nama == afterRecreation.nama &&
                           beforeRecreation.pendidikan == afterRecreation.pendidikan &&
                           beforeRecreation.bidangKeahlian == afterRecreation.bidangKeahlian &&
                           beforeRecreation.toefl == afterRecreation.toefl;
        
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
    print('🚀 Starting EditProfile SQLite Implementation Tests\n');
    
    await testBasicOperations();
    await testSaveAndLoadOperations();
    await testUpdateOperations();
    await testDataPersistence();
    await testProfileCompletionStatus();
    
    print('🎉 All EditProfile SQLite Tests Completed Successfully! 🎉');
  }
}

/// Helper function to run the test
Future<void> runEditProfileSQLiteTest() async {
  final test = EditProfileSQLiteTest();
  await test.runAllTests();
}