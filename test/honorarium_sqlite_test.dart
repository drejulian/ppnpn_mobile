import 'package:flutter_test/flutter_test.dart';
import 'package:ppnpm_dpr/common/data/models/profile_models.dart';
import 'package:ppnpm_dpr/common/data/repositories/profile_repository.dart';
import 'package:ppnpm_dpr/common/services/profile_service.dart';

void main() {
  group('Honorarium SQLite Tests', () {
    late ProfileRepository repository;
    late ProfileService service;

    setUpAll(() async {
      repository = ProfileRepository();
      service = ProfileService();
      
      // Initialize database tables
      await repository.initializeProfileTables();
    });

    test('should create honorarium model correctly', () {
      final now = DateTime.now();
      final honorarium = HonorariumModel(
        userId: 'test_user',
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
        createdAt: now,
        updatedAt: now,
      );

      expect(honorarium.userId, 'test_user');
      expect(honorarium.kartuKeluarga, '1234567890123456');
      expect(honorarium.ktp, '0987654321098765');
      expect(honorarium.namaKtp, 'TEST USER');
      expect(honorarium.npwp, '12.345.678.9-012.345');
      expect(honorarium.statusPTKP, 'Kawin (K)');
      expect(honorarium.jumlahAnak, '2');
    });

    test('should convert honorarium model to map correctly', () {
      final now = DateTime.now();
      final honorarium = HonorariumModel(
        id: 1,
        userId: 'test_user',
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
        createdAt: now,
        updatedAt: now,
      );

      final map = honorarium.toMap();

      expect(map['id'], 1);
      expect(map['user_id'], 'test_user');
      expect(map['kartu_keluarga'], '1234567890123456');
      expect(map['ktp'], '0987654321098765');
      expect(map['nama_ktp'], 'TEST USER');
      expect(map['bpjs_kesehatan'], '123456789012');
      expect(map['npwp'], '12.345.678.9-012.345');
      expect(map['nama_ibu'], 'IBU TEST');
      expect(map['rekening'], '1234567890');
      expect(map['nama_pemilik_rek'], 'TEST USER');
      expect(map['status_ptkp'], 'Kawin (K)');
      expect(map['jumlah_anak'], '2');
      expect(map['created_at'], now.toIso8601String());
      expect(map['updated_at'], now.toIso8601String());
    });

    test('should create honorarium model from map correctly', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'user_id': 'test_user',
        'kartu_keluarga': '1234567890123456',
        'ktp': '0987654321098765',
        'nama_ktp': 'TEST USER',
        'bpjs_kesehatan': '123456789012',
        'npwp': '12.345.678.9-012.345',
        'nama_ibu': 'IBU TEST',
        'rekening': '1234567890',
        'nama_pemilik_rek': 'TEST USER',
        'status_ptkp': 'Kawin (K)',
        'jumlah_anak': '2',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final honorarium = HonorariumModel.fromMap(map);

      expect(honorarium.id, 1);
      expect(honorarium.userId, 'test_user');
      expect(honorarium.kartuKeluarga, '1234567890123456');
      expect(honorarium.ktp, '0987654321098765');
      expect(honorarium.namaKtp, 'TEST USER');
      expect(honorarium.bpjsKesehatan, '123456789012');
      expect(honorarium.npwp, '12.345.678.9-012.345');
      expect(honorarium.namaIbu, 'IBU TEST');
      expect(honorarium.rekening, '1234567890');
      expect(honorarium.namaPemilikRek, 'TEST USER');
      expect(honorarium.statusPTKP, 'Kawin (K)');
      expect(honorarium.jumlahAnak, '2');
    });

    test('should validate required fields correctly', () {
      final service = ProfileService();

      // Test with empty data
      final emptyErrors = service.getHonorariumDataValidationErrors(
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

      expect(emptyErrors.length, 10); // All fields are required

      // Test with valid data
      final validErrors = service.getHonorariumDataValidationErrors(
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

      expect(validErrors.length, 0); // No validation errors
    });

    test('should save and retrieve honorarium data', () async {
      final now = DateTime.now();
      
      final honorarium = HonorariumModel(
        userId: 'test_user_save',
        kartuKeluarga: '1111222233334444',
        ktp: '1111222233334444',
        namaKtp: 'SAVE TEST USER',
        bpjsKesehatan: '111122223333',
        npwp: '11.111.222.3-333.444',
        namaIbu: 'IBU SAVE TEST',
        rekening: '1111222233',
        namaPemilikRek: 'SAVE TEST USER',
        statusPTKP: 'Tidak Kawin (TK)',
        jumlahAnak: '1',
        createdAt: now,
        updatedAt: now,
      );

      // Save data
      final saveResult = await repository.saveHonorariumData(honorarium);
      expect(saveResult, true);

      // Retrieve data
      final retrievedData = await repository.getHonorariumData('test_user_save');
      expect(retrievedData, isNotNull);
      expect(retrievedData!.kartuKeluarga, '1111222233334444');
      expect(retrievedData.ktp, '1111222233334444');
      expect(retrievedData.namaKtp, 'SAVE TEST USER');
      expect(retrievedData.npwp, '11.111.222.3-333.444');
      expect(retrievedData.statusPTKP, 'Tidak Kawin (TK)');

      // Check if data exists
      final hasData = await repository.hasHonorariumData('test_user_save');
      expect(hasData, true);

      // Clean up
      await repository.deleteHonorariumData('test_user_save');
    });

    test('should update existing honorarium data', () async {
      final now = DateTime.now();
      
      // Create initial data
      final initialHonorarium = HonorariumModel(
        userId: 'test_user_update',
        kartuKeluarga: '5555666677778888',
        ktp: '5555666677778888',
        namaKtp: 'UPDATE TEST USER',
        bpjsKesehatan: '555566667777',
        npwp: '55.555.666.7-777.888',
        namaIbu: 'IBU UPDATE TEST',
        rekening: '5555666677',
        namaPemilikRek: 'UPDATE TEST USER',
        statusPTKP: 'Kawin (K)',
        jumlahAnak: '3',
        createdAt: now,
        updatedAt: now,
      );

      // Save initial data
      await repository.saveHonorariumData(initialHonorarium);

      // Update data
      final updatedHonorarium = initialHonorarium.copyWith(
        namaKtp: 'UPDATED TEST USER',
        jumlahAnak: '4',
        updatedAt: now.add(Duration(hours: 1)),
      );

      final updateResult = await repository.saveHonorariumData(updatedHonorarium);
      expect(updateResult, true);

      // Retrieve updated data
      final retrievedData = await repository.getHonorariumData('test_user_update');
      expect(retrievedData, isNotNull);
      expect(retrievedData!.namaKtp, 'UPDATED TEST USER');
      expect(retrievedData.jumlahAnak, '4');

      // Clean up
      await repository.deleteHonorariumData('test_user_update');
    });

    test('should delete honorarium data', () async {
      final now = DateTime.now();
      
      final honorarium = HonorariumModel(
        userId: 'test_user_delete',
        kartuKeluarga: '9999888877776666',
        ktp: '9999888877776666',
        namaKtp: 'DELETE TEST USER',
        bpjsKesehatan: '999988887777',
        npwp: '99.999.888.8-777.666',
        namaIbu: 'IBU DELETE TEST',
        rekening: '9999888877',
        namaPemilikRek: 'DELETE TEST USER',
        statusPTKP: 'Kawin (K)',
        jumlahAnak: '0',
        createdAt: now,
        updatedAt: now,
      );

      // Save data
      await repository.saveHonorariumData(honorarium);

      // Verify data exists
      final existsBefore = await repository.hasHonorariumData('test_user_delete');
      expect(existsBefore, true);

      // Delete data
      final deleteResult = await repository.deleteHonorariumData('test_user_delete');
      expect(deleteResult, true);

      // Verify data is deleted
      final existsAfter = await repository.hasHonorariumData('test_user_delete');
      expect(existsAfter, false);

      final retrievedData = await repository.getHonorariumData('test_user_delete');
      expect(retrievedData, isNull);
    });
  });
}