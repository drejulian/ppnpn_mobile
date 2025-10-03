import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ppnpm_dpr/common/data/models/profile_models.dart';
import 'package:ppnpm_dpr/common/data/repositories/profile_repository.dart';
import 'package:ppnpm_dpr/common/services/profile_service.dart';

void main() {
  group('Keluarga SQLite Tests', () {
    late ProfileRepository repository;
    late ProfileService service;

    setUpAll(() async {
      // Initialize the database factory for testing
      databaseFactory = databaseFactoryFfi;
      
      repository = ProfileRepository();
      service = ProfileService();
      
      // Initialize database tables
      await repository.initializeProfileTables();
    });

    test('should create keluarga model correctly', () {
      final now = DateTime.now();
      final keluarga = KeluargaModel(
        userId: 'test_user',
        namaAyah: 'Bapak Test',
        namaIbu: 'Ibu Test',
        namaPasangan: 'Istri Test',
        namaAnak: 'Anak 1, Anak 2',
        pekerjaanAyah: 'PNS',
        pekerjaanIbu: 'Guru',
        pekerjaanPasangan: 'Dokter',
        createdAt: now,
        updatedAt: now,
      );

      expect(keluarga.userId, 'test_user');
      expect(keluarga.namaAyah, 'Bapak Test');
      expect(keluarga.namaIbu, 'Ibu Test');
      expect(keluarga.namaPasangan, 'Istri Test');
      expect(keluarga.namaAnak, 'Anak 1, Anak 2');
      expect(keluarga.pekerjaanAyah, 'PNS');
      expect(keluarga.pekerjaanIbu, 'Guru');
      expect(keluarga.pekerjaanPasangan, 'Dokter');
      expect(keluarga.createdAt, now);
      expect(keluarga.updatedAt, now);
    });

    test('should convert keluarga model to map correctly', () {
      final now = DateTime.now();
      final keluarga = KeluargaModel(
        id: 1,
        userId: 'test_user',
        namaAyah: 'Bapak Test',
        namaIbu: 'Ibu Test',
        namaPasangan: 'Istri Test',
        namaAnak: 'Anak 1, Anak 2',
        pekerjaanAyah: 'PNS',
        pekerjaanIbu: 'Guru',
        pekerjaanPasangan: 'Dokter',
        createdAt: now,
        updatedAt: now,
      );

      final map = keluarga.toMap();

      expect(map['id'], 1);
      expect(map['user_id'], 'test_user');
      expect(map['nama_ayah'], 'Bapak Test');
      expect(map['nama_ibu'], 'Ibu Test');
      expect(map['nama_pasangan'], 'Istri Test');
      expect(map['nama_anak'], 'Anak 1, Anak 2');
      expect(map['pekerjaan_ayah'], 'PNS');
      expect(map['pekerjaan_ibu'], 'Guru');
      expect(map['pekerjaan_pasangan'], 'Dokter');
      expect(map['created_at'], now.toIso8601String());
      expect(map['updated_at'], now.toIso8601String());
    });

    test('should create keluarga model from map correctly', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'user_id': 'test_user',
        'nama_ayah': 'Bapak Test',
        'nama_ibu': 'Ibu Test',
        'nama_pasangan': 'Istri Test',
        'nama_anak': 'Anak 1, Anak 2',
        'pekerjaan_ayah': 'PNS',
        'pekerjaan_ibu': 'Guru',
        'pekerjaan_pasangan': 'Dokter',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final keluarga = KeluargaModel.fromMap(map);

      expect(keluarga.id, 1);
      expect(keluarga.userId, 'test_user');
      expect(keluarga.namaAyah, 'Bapak Test');
      expect(keluarga.namaIbu, 'Ibu Test');
      expect(keluarga.namaPasangan, 'Istri Test');
      expect(keluarga.namaAnak, 'Anak 1, Anak 2');
      expect(keluarga.pekerjaanAyah, 'PNS');
      expect(keluarga.pekerjaanIbu, 'Guru');
      expect(keluarga.pekerjaanPasangan, 'Dokter');
      expect(keluarga.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(keluarga.updatedAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('should handle empty fields correctly', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'user_id': 'test_user',
        'nama_ayah': '',
        'nama_ibu': '',
        'nama_pasangan': 'Istri Test',
        'nama_anak': 'Anak Test',
        'pekerjaan_ayah': '',
        'pekerjaan_ibu': '',
        'pekerjaan_pasangan': 'Dokter',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final keluarga = KeluargaModel.fromMap(map);

      expect(keluarga.namaAyah, '');
      expect(keluarga.namaIbu, '');
      expect(keluarga.namaPasangan, 'Istri Test');
      expect(keluarga.namaAnak, 'Anak Test');
      expect(keluarga.pekerjaanAyah, '');
      expect(keluarga.pekerjaanIbu, '');
      expect(keluarga.pekerjaanPasangan, 'Dokter');
    });

    test('should validate keluarga data correctly', () {
      // Test with valid data
      var errors = service.getKeluargaDataValidationErrors(
        namaAyah: 'Bapak Valid',
        namaIbu: 'Ibu Valid',
        namaPasangan: 'Istri Valid',
        namaAnak: 'Anak Valid',
        pekerjaanAyah: 'PNS',
        pekerjaanIbu: 'Guru',
        pekerjaanPasangan: 'Dokter',
      );
      expect(errors.length, 0);

      // Test with empty data
      errors = service.getKeluargaDataValidationErrors(
        namaAyah: '',
        namaIbu: '',
        namaPasangan: '',
        namaAnak: '',
        pekerjaanAyah: '',
        pekerjaanIbu: '',
        pekerjaanPasangan: '',
      );
      expect(errors.length, 1);
      expect(errors.first, contains('Minimal satu anggota keluarga harus diisi'));

      // Test with short names
      errors = service.getKeluargaDataValidationErrors(
        namaAyah: 'A',
        namaIbu: 'B',
        namaPasangan: '',
        namaAnak: '',
        pekerjaanAyah: '',
        pekerjaanIbu: '',
        pekerjaanPasangan: '',
      );
      expect(errors.length, 2);
      expect(errors.any((e) => e.contains('Nama ayah minimal 2 karakter')), true);
      expect(errors.any((e) => e.contains('Nama ibu minimal 2 karakter')), true);

      // Test with partial valid data
      errors = service.getKeluargaDataValidationErrors(
        namaAyah: '',
        namaIbu: '',
        namaPasangan: 'Istri Valid',
        namaAnak: '',
        pekerjaanAyah: '',
        pekerjaanIbu: '',
        pekerjaanPasangan: 'Dokter',
      );
      expect(errors.length, 0); // Should be valid as at least one member is provided
    });

    test('should save and retrieve keluarga data', () async {
      final now = DateTime.now();
      
      final keluarga = KeluargaModel(
        userId: 'test_user_save',
        namaAyah: 'Bapak Save Test',
        namaIbu: 'Ibu Save Test',
        namaPasangan: 'Istri Save Test',
        namaAnak: 'Anak 1 Save, Anak 2 Save',
        pekerjaanAyah: 'PNS',
        pekerjaanIbu: 'Guru',
        pekerjaanPasangan: 'Dokter',
        createdAt: now,
        updatedAt: now,
      );

      // Save data
      final saveResult = await repository.saveKeluargaData(keluarga);
      expect(saveResult, true);

      // Retrieve data
      final retrievedData = await repository.getKeluargaData('test_user_save');
      expect(retrievedData, isNotNull);
      expect(retrievedData!.namaAyah, 'Bapak Save Test');
      expect(retrievedData.namaIbu, 'Ibu Save Test');
      expect(retrievedData.namaPasangan, 'Istri Save Test');
      expect(retrievedData.namaAnak, 'Anak 1 Save, Anak 2 Save');
      expect(retrievedData.pekerjaanAyah, 'PNS');
      expect(retrievedData.pekerjaanIbu, 'Guru');
      expect(retrievedData.pekerjaanPasangan, 'Dokter');
      expect(retrievedData.userId, 'test_user_save');

      // Check if data exists
      final hasData = await repository.hasKeluargaData('test_user_save');
      expect(hasData, true);

      // Clean up
      await repository.deleteKeluargaData('test_user_save');
    });

    test('should update existing keluarga data', () async {
      final now = DateTime.now();
      
      // Create initial data
      final initialKeluarga = KeluargaModel(
        userId: 'test_user_update',
        namaAyah: 'Bapak Initial',
        namaIbu: 'Ibu Initial',
        namaPasangan: '',
        namaAnak: 'Anak Initial',
        pekerjaanAyah: 'PNS',
        pekerjaanIbu: 'Guru',
        pekerjaanPasangan: '',
        createdAt: now,
        updatedAt: now,
      );

      // Save initial data
      await repository.saveKeluargaData(initialKeluarga);

      // Update data
      final updatedKeluarga = initialKeluarga.copyWith(
        namaAyah: 'Bapak Updated',
        namaPasangan: 'Istri Updated',
        pekerjaanPasangan: 'Dokter',
        updatedAt: now.add(Duration(hours: 1)),
      );

      final updateResult = await repository.saveKeluargaData(updatedKeluarga);
      expect(updateResult, true);

      // Retrieve updated data
      final retrievedData = await repository.getKeluargaData('test_user_update');
      expect(retrievedData, isNotNull);
      expect(retrievedData!.namaAyah, 'Bapak Updated');
      expect(retrievedData.namaIbu, 'Ibu Initial');
      expect(retrievedData.namaPasangan, 'Istri Updated');
      expect(retrievedData.pekerjaanPasangan, 'Dokter');

      // Clean up
      await repository.deleteKeluargaData('test_user_update');
    });

    test('should delete keluarga data', () async {
      final now = DateTime.now();
      
      final keluarga = KeluargaModel(
        userId: 'test_user_delete',
        namaAyah: 'Bapak Delete Test',
        namaIbu: 'Ibu Delete Test',
        namaPasangan: 'Istri Delete Test',
        namaAnak: 'Anak Delete Test',
        pekerjaanAyah: 'PNS',
        pekerjaanIbu: 'Guru',
        pekerjaanPasangan: 'Dokter',
        createdAt: now,
        updatedAt: now,
      );

      // Save data
      await repository.saveKeluargaData(keluarga);

      // Verify data exists
      final existsBefore = await repository.hasKeluargaData('test_user_delete');
      expect(existsBefore, true);

      // Delete data
      final deleteResult = await repository.deleteKeluargaData('test_user_delete');
      expect(deleteResult, true);

      // Verify data is deleted
      final existsAfter = await repository.hasKeluargaData('test_user_delete');
      expect(existsAfter, false);

      final retrievedData = await repository.getKeluargaData('test_user_delete');
      expect(retrievedData, isNull);
    });

    test('should save keluarga data using service', () async {
      // Test valid save
      final success = await service.saveKeluargaData(
        namaAyah: 'Bapak Service Test',
        namaIbu: 'Ibu Service Test',
        namaPasangan: 'Istri Service Test',
        namaAnak: 'Anak Service Test',
        pekerjaanAyah: 'PNS',
        pekerjaanIbu: 'Guru',
        pekerjaanPasangan: 'Dokter',
      );
      expect(success, true);

      // Verify data was saved
      final hasData = await service.hasKeluargaData();
      expect(hasData, true);

      // Retrieve and verify data
      final data = await service.getKeluargaData();
      expect(data, isNotNull);
      expect(data!.namaAyah, 'Bapak Service Test');
      expect(data.namaIbu, 'Ibu Service Test');
      expect(data.namaPasangan, 'Istri Service Test');
      expect(data.namaAnak, 'Anak Service Test');
      expect(data.pekerjaanAyah, 'PNS');
      expect(data.pekerjaanIbu, 'Guru');
      expect(data.pekerjaanPasangan, 'Dokter');
    });

    test('should handle empty family data gracefully', () async {
      // Test saving partially empty data (should pass validation)
      final success = await service.saveKeluargaData(
        namaAyah: '',
        namaIbu: '',
        namaPasangan: 'Istri Only',
        namaAnak: '',
        pekerjaanAyah: '',
        pekerjaanIbu: '',
        pekerjaanPasangan: 'Dokter',
      );
      expect(success, true);

      // Retrieve and verify
      final data = await service.getKeluargaData();
      expect(data, isNotNull);
      expect(data!.namaAyah, '');
      expect(data.namaIbu, '');
      expect(data.namaPasangan, 'Istri Only');
      expect(data.namaAnak, '');
      expect(data.pekerjaanPasangan, 'Dokter');
    });
  });
}