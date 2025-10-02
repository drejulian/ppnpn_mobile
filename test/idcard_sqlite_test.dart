import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ppnpm_dpr/common/data/models/profile_models.dart';
import 'package:ppnpm_dpr/common/data/repositories/profile_repository.dart';
import 'package:ppnpm_dpr/common/services/profile_service.dart';

void main() {
  group('ID Card SQLite Tests', () {
    late ProfileRepository repository;

    setUpAll(() async {
      // Initialize the database factory for testing
      databaseFactory = databaseFactoryFfi;
      
      repository = ProfileRepository();
      
      // Initialize database tables
      await repository.initializeProfileTables();
    });

    test('should create ID card model correctly', () {
      final now = DateTime.now();
      final idCard = IdCardModel(
        userId: 'test_user',
        fotoPath: '/path/to/photo.jpg',
        isUploaded: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(idCard.userId, 'test_user');
      expect(idCard.fotoPath, '/path/to/photo.jpg');
      expect(idCard.isUploaded, true);
      expect(idCard.createdAt, now);
      expect(idCard.updatedAt, now);
    });

    test('should convert ID card model to map correctly', () {
      final now = DateTime.now();
      final idCard = IdCardModel(
        id: 1,
        userId: 'test_user',
        fotoPath: '/path/to/photo.jpg',
        isUploaded: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = idCard.toMap();

      expect(map['id'], 1);
      expect(map['user_id'], 'test_user');
      expect(map['foto_path'], '/path/to/photo.jpg');
      expect(map['is_uploaded'], 1);
      expect(map['created_at'], now.toIso8601String());
      expect(map['updated_at'], now.toIso8601String());
    });

    test('should create ID card model from map correctly', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'user_id': 'test_user',
        'foto_path': '/path/to/photo.jpg',
        'is_uploaded': 1,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final idCard = IdCardModel.fromMap(map);

      expect(idCard.id, 1);
      expect(idCard.userId, 'test_user');
      expect(idCard.fotoPath, '/path/to/photo.jpg');
      expect(idCard.isUploaded, true);
      expect(idCard.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(idCard.updatedAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('should handle boolean conversion correctly', () {
      // Test true case
      final mapTrue = {
        'id': 1,
        'user_id': 'test_user',
        'foto_path': '/path/to/photo.jpg',
        'is_uploaded': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final idCardTrue = IdCardModel.fromMap(mapTrue);
      expect(idCardTrue.isUploaded, true);

      // Test false case
      final mapFalse = {
        'id': 2,
        'user_id': 'test_user2',
        'foto_path': '',
        'is_uploaded': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final idCardFalse = IdCardModel.fromMap(mapFalse);
      expect(idCardFalse.isUploaded, false);
    });

    test('should validate ID card data correctly', () {
      final service = ProfileService();

      // Test with valid data (no photo)
      final noPhotoErrors = service.getIdCardDataValidationErrors(
        fotoPath: '',
        isUploaded: false,
      );
      expect(noPhotoErrors.length, 0);

      // Test with valid data (with photo)
      final withPhotoErrors = service.getIdCardDataValidationErrors(
        fotoPath: '/valid/path/photo.jpg',
        isUploaded: true,
      );
      expect(withPhotoErrors.length, greaterThan(0)); // Will fail because file doesn't exist

      // Test with invalid data (uploaded but no path)
      final invalidErrors = service.getIdCardDataValidationErrors(
        fotoPath: '',
        isUploaded: true,
      );
      expect(invalidErrors.length, 1);
      expect(invalidErrors.first, contains('Foto path tidak boleh kosong'));
    });

    test('should save and retrieve ID card data', () async {
      final now = DateTime.now();
      
      final idCard = IdCardModel(
        userId: 'test_user_save',
        fotoPath: '/test/path/photo.jpg',
        isUploaded: true,
        createdAt: now,
        updatedAt: now,
      );

      // Save data
      final saveResult = await repository.saveIdCardData(idCard);
      expect(saveResult, true);

      // Retrieve data
      final retrievedData = await repository.getIdCardData('test_user_save');
      expect(retrievedData, isNotNull);
      expect(retrievedData!.fotoPath, '/test/path/photo.jpg');
      expect(retrievedData.isUploaded, true);
      expect(retrievedData.userId, 'test_user_save');

      // Check if data exists
      final hasData = await repository.hasIdCardData('test_user_save');
      expect(hasData, true);

      // Clean up
      await repository.deleteIdCardData('test_user_save');
    });

    test('should update existing ID card data', () async {
      final now = DateTime.now();
      
      // Create initial data
      final initialIdCard = IdCardModel(
        userId: 'test_user_update',
        fotoPath: '/initial/path/photo.jpg',
        isUploaded: false,
        createdAt: now,
        updatedAt: now,
      );

      // Save initial data
      await repository.saveIdCardData(initialIdCard);

      // Update data
      final updatedIdCard = initialIdCard.copyWith(
        fotoPath: '/updated/path/photo.jpg',
        isUploaded: true,
        updatedAt: now.add(Duration(hours: 1)),
      );

      final updateResult = await repository.saveIdCardData(updatedIdCard);
      expect(updateResult, true);

      // Retrieve updated data
      final retrievedData = await repository.getIdCardData('test_user_update');
      expect(retrievedData, isNotNull);
      expect(retrievedData!.fotoPath, '/updated/path/photo.jpg');
      expect(retrievedData.isUploaded, true);

      // Clean up
      await repository.deleteIdCardData('test_user_update');
    });

    test('should delete ID card data', () async {
      final now = DateTime.now();
      
      final idCard = IdCardModel(
        userId: 'test_user_delete',
        fotoPath: '/delete/test/photo.jpg',
        isUploaded: true,
        createdAt: now,
        updatedAt: now,
      );

      // Save data
      await repository.saveIdCardData(idCard);

      // Verify data exists
      final existsBefore = await repository.hasIdCardData('test_user_delete');
      expect(existsBefore, true);

      // Delete data
      final deleteResult = await repository.deleteIdCardData('test_user_delete');
      expect(deleteResult, true);

      // Verify data is deleted
      final existsAfter = await repository.hasIdCardData('test_user_delete');
      expect(existsAfter, false);

      final retrievedData = await repository.getIdCardData('test_user_delete');
      expect(retrievedData, isNull);
    });

    test('should handle empty photo path correctly', () async {
      final now = DateTime.now();
      
      final idCard = IdCardModel(
        userId: 'test_user_empty',
        fotoPath: '',
        isUploaded: false,
        createdAt: now,
        updatedAt: now,
      );

      // Save data with empty path
      final saveResult = await repository.saveIdCardData(idCard);
      expect(saveResult, true);

      // Retrieve data
      final retrievedData = await repository.getIdCardData('test_user_empty');
      expect(retrievedData, isNotNull);
      expect(retrievedData!.fotoPath, '');
      expect(retrievedData.isUploaded, false);

      // Clean up
      await repository.deleteIdCardData('test_user_empty');
    });
  });
}