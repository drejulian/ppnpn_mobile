import 'dart:io';
import '../data/repositories/profile_repository.dart';
import '../data/models/profile_models.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final ProfileRepository _repository = ProfileRepository();

  /// Get current user ID (in a real app, this would come from authentication)
  String getCurrentUserId() {
    // For now, using a default user ID
    // In a real app, this would come from authentication service
    return 'current_user';
  }

  // ========================================
  // EDIT PROFILE OPERATIONS
  // ========================================

  /// Initialize profile service
  Future<void> initialize() async {
    try {
      await _repository.initializeProfileTables();
      print('ProfileService: Initialized successfully');
    } catch (e) {
      print('ProfileService: Error initializing: $e');
      rethrow;
    }
  }

  /// Get current user's edit profile data
  Future<EditProfileModel?> getCurrentEditProfile() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.getEditProfile(userId);
    } catch (e) {
      print('ProfileService: Error getting current edit profile: $e');
      return null;
    }
  }

  /// Save edit profile data for current user
  Future<bool> saveEditProfile({
    required String nik,
    required String nama,
    required String pendidikan,
    required String bidangKeahlian,
    required String toefl,
  }) async {
    try {
      final userId = getCurrentUserId();
      final now = DateTime.now();

      final profile = EditProfileModel(
        userId: userId,
        nik: nik,
        nama: nama,
        pendidikan: pendidikan,
        bidangKeahlian: bidangKeahlian,
        toefl: toefl,
        createdAt: now,
        updatedAt: now,
      );

      final success = await _repository.saveEditProfile(profile);
      
      if (success) {
        print('ProfileService: Edit profile saved successfully');
      } else {
        print('ProfileService: Failed to save edit profile');
      }
      
      return success;
    } catch (e) {
      print('ProfileService: Error saving edit profile: $e');
      return false;
    }
  }

  /// Update existing edit profile data
  Future<bool> updateEditProfile({
    required String nik,
    required String nama,
    required String pendidikan,
    required String bidangKeahlian,
    required String toefl,
  }) async {
    try {
      final userId = getCurrentUserId();
      
      // Get existing profile to keep created_at
      final existing = await _repository.getEditProfile(userId);
      final createdAt = existing?.createdAt ?? DateTime.now();
      
      final profile = EditProfileModel(
        userId: userId,
        nik: nik,
        nama: nama,
        pendidikan: pendidikan,
        bidangKeahlian: bidangKeahlian,
        toefl: toefl,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await _repository.saveEditProfile(profile);
      
      if (success) {
        print('ProfileService: Edit profile updated successfully');
      } else {
        print('ProfileService: Failed to update edit profile');
      }
      
      return success;
    } catch (e) {
      print('ProfileService: Error updating edit profile: $e');
      return false;
    }
  }

  /// Check if current user has edit profile data
  Future<bool> hasEditProfileData() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.hasEditProfileData(userId);
    } catch (e) {
      print('ProfileService: Error checking edit profile data: $e');
      return false;
    }
  }

  /// Delete current user's edit profile data
  Future<bool> deleteEditProfile() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.deleteEditProfile(userId);
    } catch (e) {
      print('ProfileService: Error deleting edit profile: $e');
      return false;
    }
  }

  // ========================================
  // PRIBADI DATA OPERATIONS
  // ========================================

  /// Get current user's pribadi data
  Future<PribadiModel?> getCurrentPribadiData() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.getPribadiData(userId);
    } catch (e) {
      print('ProfileService: Error getting current pribadi data: $e');
      return null;
    }
  }

  /// Save pribadi data for current user
  Future<bool> savePribadiData({
    String tempatLahir = '',
    String tanggalLahir = '',
    String jenisKelamin = '',
    String agama = '',
    String statusPerkawinan = '',
    String golonganDarah = '',
    String statusDomisili = '',
    String address = '',
    String propinsi = '',
    String kota = '',
    String kecamatan = '',
    String kelurahan = '',
    String rt = '',
    String rw = '',
    String kodePos = '',
    String teleponRumah = '',
    String teleponKantor = '',
    String handphone = '',
    String email = '',
  }) async {
    try {
      // Validate required fields
      final validationErrors = getPribadiDataValidationErrors(
        tempatLahir: tempatLahir,
        tanggalLahir: tanggalLahir,
        jenisKelamin: jenisKelamin,
        agama: agama,
        statusPerkawinan: statusPerkawinan,
        golonganDarah: golonganDarah,
        statusDomisili: statusDomisili,
        address: address,
        propinsi: propinsi,
        kota: kota,
        kecamatan: kecamatan,
        kelurahan: kelurahan,
        rt: rt,
        rw: rw,
        kodePos: kodePos,
        teleponRumah: teleponRumah,
        teleponKantor: teleponKantor,
        handphone: handphone,
        email: email,
      );

      if (validationErrors.isNotEmpty) {
        print('ProfileService: ❌ Validation failed with ${validationErrors.length} errors');
        print('ProfileService: Error details: ${validationErrors.join(", ")}');
        return false;
      }

      print('ProfileService: ✅ Validation passed, creating PribadiModel...');
      
      final userId = getCurrentUserId();
      print('ProfileService: Using userId: $userId');
      
      final now = DateTime.now();
      print('ProfileService: Timestamp: $now');

      final pribadi = PribadiModel(
        userId: userId,
        tempatLahir: tempatLahir,
        tanggalLahir: tanggalLahir,
        jenisKelamin: jenisKelamin,
        agama: agama,
        statusPerkawinan: statusPerkawinan,
        golonganDarah: golonganDarah,
        statusDomisili: statusDomisili,
        address: address,
        propinsi: propinsi,
        kota: kota,
        kecamatan: kecamatan,
        kelurahan: kelurahan,
        rt: rt,
        rw: rw,
        kodePos: kodePos,
        teleponRumah: teleponRumah,
        teleponKantor: teleponKantor,
        handphone: handphone,
        email: email,
        createdAt: now,
        updatedAt: now,
      );

      print('ProfileService: 🔄 Calling repository.savePribadiData()...');
      print('ProfileService: Model data preview:');
      print('  - userId: $userId');
      print('  - tempatLahir: "$tempatLahir"');
      print('  - tanggalLahir: "$tanggalLahir"');
      print('  - jenisKelamin: "$jenisKelamin"');
      print('  - email: "$email"');
      print('  - handphone: "$handphone"');
      print('  - address: "${address.length > 50 ? address.substring(0, 50) + "..." : address}"');
      
      final success = await _repository.savePribadiData(pribadi);
      
      print('ProfileService: 📋 Repository save result: $success');
      
      if (success) {
        print('ProfileService: ✅ Pribadi data saved to database successfully!');
      } else {
        print('ProfileService: ❌ Failed to save pribadi data to database');
      }
      
      return success;
    } catch (e) {
      print('ProfileService: Error saving pribadi data: $e');
      return false;
    }
  }

  /// Check if current user has pribadi data
  Future<bool> hasPribadiData() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.hasPribadiData(userId);
    } catch (e) {
      print('ProfileService: Error checking pribadi data: $e');
      return false;
    }
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Get profile completion status for current user
  Future<Map<String, bool>> getProfileCompletionStatus() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.getProfileCompletionStatus(userId);
    } catch (e) {
      print('ProfileService: Error getting completion status: $e');
      return {
        'editProfile': false,
        'pribadiData': false,
      };
    }
  }

  /// Get profile summary for current user
  Future<Map<String, dynamic>> getProfileSummary() async {
    try {
      final editProfile = await getCurrentEditProfile();
      final pribadiData = await getCurrentPribadiData();
      final completionStatus = await getProfileCompletionStatus();

      return {
        'editProfile': editProfile?.toMap(),
        'pribadiData': pribadiData?.toMap(),
        'completionStatus': completionStatus,
        'hasData': completionStatus['editProfile'] == true || completionStatus['pribadiData'] == true,
      };
    } catch (e) {
      print('ProfileService: Error getting profile summary: $e');
      return {
        'editProfile': null,
        'pribadiData': null,
        'completionStatus': {'editProfile': false, 'pribadiData': false},
        'hasData': false,
      };
    }
  }

  /// Clear all profile data for current user
  Future<bool> clearAllProfileData() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.clearAllProfileData(userId);
    } catch (e) {
      print('ProfileService: Error clearing profile data: $e');
      return false;
    }
  }

  /// Validate edit profile data
  bool validateEditProfile({
    required String nik,
    required String nama,
    required String pendidikan,
    required String bidangKeahlian,
    required String toefl,
  }) {
    if (nama.trim().isEmpty) return false;
    if (nik.trim().isEmpty) return false;
    if (pendidikan.trim().isEmpty) return false;
    if (bidangKeahlian.trim().isEmpty) return false;
    if (toefl.trim().isEmpty) return false;
    
    // Validate TOEFL score (should be numeric and within reasonable range)
    final toeflScore = int.tryParse(toefl);
    if (toeflScore == null || toeflScore < 0 || toeflScore > 990) {
      return false;
    }
    
    return true;
  }

  /// Get validation errors for edit profile
  List<String> getEditProfileValidationErrors({
    required String nik,
    required String nama,
    required String pendidikan,
    required String bidangKeahlian,
    required String toefl,
  }) {
    final errors = <String>[];
    
    if (nama.trim().isEmpty) {
      errors.add('Nama harus diisi');
    }
    
    if (nik.trim().isEmpty) {
      errors.add('NIK harus diisi');
    }
    
    if (pendidikan.trim().isEmpty) {
      errors.add('Pendidikan Terakhir harus dipilih');
    }
    
    if (bidangKeahlian.trim().isEmpty) {
      errors.add('Bidang Keahlian harus diisi');
    }
    
    if (toefl.trim().isEmpty) {
      errors.add('TOEFL harus diisi');
    } else {
      final toeflScore = int.tryParse(toefl);
      if (toeflScore == null) {
        errors.add('Skor TOEFL harus berupa angka');
      } else if (toeflScore < 0 || toeflScore > 990) {
        errors.add('Skor TOEFL harus antara 0-990');
      }
    }
    
    return errors;
  }

  /// Validate pribadi data
  bool validatePribadiData({
    required String tempatLahir,
    required String tanggalLahir,
    required String jenisKelamin,
    required String agama,
    required String statusPerkawinan,
    required String golonganDarah,
    required String statusDomisili,
    required String address,
    required String propinsi,
    required String kota,
    required String kecamatan,
    required String kelurahan,
    required String rt,
    required String rw,
    required String kodePos,
    required String teleponRumah,
    required String teleponKantor,
    required String handphone,
    required String email,
  }) {
    if (tempatLahir.trim().isEmpty) return false;
    if (tanggalLahir.trim().isEmpty) return false;
    if (jenisKelamin.trim().isEmpty) return false;
    if (agama.trim().isEmpty) return false;
    if (statusPerkawinan.trim().isEmpty) return false;
    if (golonganDarah.trim().isEmpty) return false;
    if (statusDomisili.trim().isEmpty) return false;
    if (address.trim().isEmpty) return false;
    if (propinsi.trim().isEmpty) return false;
    if (kota.trim().isEmpty) return false;
    if (kecamatan.trim().isEmpty) return false;
    if (kelurahan.trim().isEmpty) return false;
    if (rt.trim().isEmpty) return false;
    if (rw.trim().isEmpty) return false;
    if (kodePos.trim().isEmpty) return false;
    if (teleponRumah.trim().isEmpty) return false;
    if (teleponKantor.trim().isEmpty) return false;
    if (handphone.trim().isEmpty) return false;
    if (email.trim().isEmpty) return false;
    
    // Validate email format
    if (!email.contains('@') || !email.contains('.')) {
      return false;
    }
    
    return true;
  }

  /// Get validation errors for pribadi data (DEBUG VERSION)
  List<String> getPribadiDataValidationErrors({
    required String tempatLahir,
    required String tanggalLahir,
    required String jenisKelamin,
    required String agama,
    required String statusPerkawinan,
    required String golonganDarah,
    required String statusDomisili,
    required String address,
    required String propinsi,
    required String kota,
    required String kecamatan,
    required String kelurahan,
    required String rt,
    required String rw,
    required String kodePos,
    required String teleponRumah,
    required String teleponKantor,
    required String handphone,
    required String email,
  }) {
    final errors = <String>[];
    
    print('=== PROFILE SERVICE VALIDATION (DEBUG) ===');
    print('Input validation for pribadi data:');
    print('  Tempat Lahir: "$tempatLahir" (empty: ${tempatLahir.trim().isEmpty})');
    print('  Tanggal Lahir: "$tanggalLahir" (empty: ${tanggalLahir.trim().isEmpty})');
    print('  Jenis Kelamin: "$jenisKelamin" (empty: ${jenisKelamin.trim().isEmpty})');
    print('  Agama: "$agama" (empty: ${agama.trim().isEmpty})');
    print('  Status Perkawinan: "$statusPerkawinan" (empty: ${statusPerkawinan.trim().isEmpty})');
    print('  Golongan Darah: "$golonganDarah" (empty: ${golonganDarah.trim().isEmpty})');
    print('  Email: "$email" (empty: ${email.trim().isEmpty})');
    print('  Handphone: "$handphone" (empty: ${handphone.trim().isEmpty})');
    print('  Address: "$address" (empty: ${address.trim().isEmpty})');
    
    // Core required fields
    if (tempatLahir.trim().isEmpty) {
      errors.add('Tempat Lahir harus diisi');
    }
    
    if (tanggalLahir.trim().isEmpty) {
      errors.add('Tanggal Lahir harus diisi');
    }
    
    if (jenisKelamin.trim().isEmpty) {
      errors.add('Jenis Kelamin harus dipilih');
    }
    
    if (agama.trim().isEmpty) {
      errors.add('Agama harus dipilih');
    }
    
    if (statusPerkawinan.trim().isEmpty) {
      errors.add('Status Perkawinan harus dipilih');
    }
    
    if (golonganDarah.trim().isEmpty) {
      errors.add('Golongan Darah harus dipilih');
    }
    
    if (statusDomisili.trim().isEmpty) {
      errors.add('Status Domisili harus dipilih');
    }
    
    if (address.trim().isEmpty) {
      errors.add('Alamat harus diisi');
    }
    
    // Address components - allow some flexibility
    if (propinsi.trim().isEmpty) {
      errors.add('Propinsi harus diisi');
    }
    
    if (kota.trim().isEmpty) {
      errors.add('Kota harus diisi');
    }
    
    if (kecamatan.trim().isEmpty) {
      errors.add('Kecamatan harus diisi');
    }
    
    if (kelurahan.trim().isEmpty) {
      errors.add('Kelurahan harus diisi');
    }
    
    // RT/RW can be default values
    if (rt.trim().isEmpty || rt.trim() == '') {
      // Allow default '000' value, don't add error
    }
    
    if (rw.trim().isEmpty || rw.trim() == '') {
      // Allow default '000' value, don't add error  
    }
    
    if (kodePos.trim().isEmpty) {
      errors.add('Kode Pos harus diisi');
    }
    
    // Contact info - make phone optional but require at least handphone or email
    bool hasContact = false;
    
    if (handphone.trim().isNotEmpty) {
      hasContact = true;
    }
    
    if (email.trim().isNotEmpty) {
      hasContact = true;
      // Validate email format if provided
      if (!email.contains('@') || !email.contains('.')) {
        errors.add('Format email tidak valid');
      }
    }
    
    if (!hasContact) {
      errors.add('Minimal satu kontak (handphone atau email) harus diisi');
    }
    
    print('Validation completed:');
    print('  Total errors: ${errors.length}');
    if (errors.isNotEmpty) {
      print('  Error details:');
      for (int i = 0; i < errors.length; i++) {
        print('    ${i + 1}. ${errors[i]}');
      }
    } else {
      print('  ✅ All validations passed!');
    }
    print('==========================================');
    
    return errors;
  }

  /// Update pribadi data for current user
  Future<bool> updatePribadiData({
    required String tempatLahir,
    required String tanggalLahir,
    required String jenisKelamin,
    required String agama,
    required String statusPerkawinan,
    required String golonganDarah,
    required String statusDomisili,
    required String address,
    required String propinsi,
    required String kota,
    required String kecamatan,
    required String kelurahan,
    required String rt,
    required String rw,
    required String kodePos,
    required String teleponRumah,
    required String teleponKantor,
    required String handphone,
    required String email,
  }) async {
    return await savePribadiData(
      tempatLahir: tempatLahir,
      tanggalLahir: tanggalLahir,
      jenisKelamin: jenisKelamin,
      agama: agama,
      statusPerkawinan: statusPerkawinan,
      golonganDarah: golonganDarah,
      statusDomisili: statusDomisili,
      address: address,
      propinsi: propinsi,
      kota: kota,
      kecamatan: kecamatan,
      kelurahan: kelurahan,
      rt: rt,
      rw: rw,
      kodePos: kodePos,
      teleponRumah: teleponRumah,
      teleponKantor: teleponKantor,
      handphone: handphone,
      email: email,
    );
  }

  // ========================================
  // HONORARIUM DATA OPERATIONS
  // ========================================

  /// Get current user's honorarium data
  Future<HonorariumModel?> getCurrentHonorariumData() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.getHonorariumData(userId);
    } catch (e) {
      print('ProfileService: Error getting current honorarium data: $e');
      return null;
    }
  }

  /// Save honorarium data for current user
  Future<bool> saveHonorariumData({
    String kartuKeluarga = '',
    String ktp = '',
    String namaKtp = '',
    String bpjsKesehatan = '',
    String npwp = '',
    String namaIbu = '',
    String rekening = '',
    String namaPemilikRek = '',
    String statusPTKP = '',
    String jumlahAnak = '',
  }) async {
    try {
      print('ProfileService: === SAVING HONORARIUM DATA ===');
      print('ProfileService: Input data:');
      print('  - Kartu Keluarga: "$kartuKeluarga"');
      print('  - KTP: "$ktp"');
      print('  - Nama KTP: "$namaKtp"');
      print('  - BPJS Kesehatan: "$bpjsKesehatan"');
      print('  - NPWP: "$npwp"');
      print('  - Nama Ibu: "$namaIbu"');
      print('  - Rekening: "$rekening"');
      print('  - Nama Pemilik Rek: "$namaPemilikRek"');
      print('  - Status PTKP: "$statusPTKP"');
      print('  - Jumlah Anak: "$jumlahAnak"');

      // Validate required fields
      final validationErrors = getHonorariumDataValidationErrors(
        kartuKeluarga: kartuKeluarga,
        ktp: ktp,
        namaKtp: namaKtp,
        bpjsKesehatan: bpjsKesehatan,
        npwp: npwp,
        namaIbu: namaIbu,
        rekening: rekening,
        namaPemilikRek: namaPemilikRek,
        statusPTKP: statusPTKP,
        jumlahAnak: jumlahAnak,
      );

      if (validationErrors.isNotEmpty) {
        print('ProfileService: ❌ Validation failed with ${validationErrors.length} errors');
        print('ProfileService: Error details: ${validationErrors.join(", ")}');
        return false;
      }

      print('ProfileService: ✅ Validation passed, creating HonorariumModel...');
      
      final userId = getCurrentUserId();
      print('ProfileService: Using userId: $userId');
      
      final now = DateTime.now();
      print('ProfileService: Timestamp: $now');

      final honorarium = HonorariumModel(
        userId: userId,
        kartuKeluarga: kartuKeluarga,
        ktp: ktp,
        namaKtp: namaKtp,
        bpjsKesehatan: bpjsKesehatan,
        npwp: npwp,
        namaIbu: namaIbu,
        rekening: rekening,
        namaPemilikRek: namaPemilikRek,
        statusPTKP: statusPTKP,
        jumlahAnak: jumlahAnak,
        createdAt: now,
        updatedAt: now,
      );

      print('ProfileService: 🔄 Calling repository.saveHonorariumData()...');
      print('ProfileService: Model data preview:');
      print('  - userId: $userId');
      print('  - kartuKeluarga: "$kartuKeluarga"');
      print('  - ktp: "$ktp"');
      print('  - namaKtp: "$namaKtp"');
      print('  - npwp: "$npwp"');
      print('  - rekening: "$rekening"');
      
      final success = await _repository.saveHonorariumData(honorarium);
      
      print('ProfileService: 📋 Repository save result: $success');
      
      if (success) {
        print('ProfileService: ✅ Honorarium data saved to database successfully!');
      } else {
        print('ProfileService: ❌ Failed to save honorarium data to database');
      }
      
      return success;
    } catch (e) {
      print('ProfileService: ❌ Error saving honorarium data: $e');
      return false;
    }
  }

  /// Check if current user has honorarium data
  Future<bool> hasHonorariumData() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.hasHonorariumData(userId);
    } catch (e) {
      print('ProfileService: Error checking honorarium data: $e');
      return false;
    }
  }

  /// Get validation errors for honorarium data
  List<String> getHonorariumDataValidationErrors({
    required String kartuKeluarga,
    required String ktp,
    required String namaKtp,
    required String bpjsKesehatan,
    required String npwp,
    required String namaIbu,
    required String rekening,
    required String namaPemilikRek,
    required String statusPTKP,
    required String jumlahAnak,
  }) {
    final errors = <String>[];
    
    print('=== PROFILE SERVICE HONORARIUM VALIDATION ===');
    print('Validating honorarium data...');
    print('Kartu Keluarga: "$kartuKeluarga" (length: ${kartuKeluarga.length})');
    print('KTP: "$ktp" (length: ${ktp.length})');
    print('Nama KTP: "$namaKtp" (length: ${namaKtp.length})');
    print('BPJS Kesehatan: "$bpjsKesehatan" (length: ${bpjsKesehatan.length})');
    print('NPWP: "$npwp" (length: ${npwp.length})');
    print('Nama Ibu: "$namaIbu" (length: ${namaIbu.length})');
    print('Rekening: "$rekening" (length: ${rekening.length})');
    print('Nama Pemilik Rek: "$namaPemilikRek" (length: ${namaPemilikRek.length})');
    print('Status PTKP: "$statusPTKP" (length: ${statusPTKP.length})');
    print('Jumlah Anak: "$jumlahAnak" (length: ${jumlahAnak.length})');
    
    // Required field validation
    if (kartuKeluarga.trim().isEmpty) {
      errors.add('No. Kartu Keluarga harus diisi');
      print('❌ Kartu Keluarga empty');
    } else {
      print('✅ Kartu Keluarga: OK');
    }
    
    if (ktp.trim().isEmpty) {
      errors.add('No. KTP harus diisi');
      print('❌ KTP empty');
    } else {
      print('✅ KTP: OK');
    }
    
    if (namaKtp.trim().isEmpty) {
      errors.add('Nama Sesuai KTP harus diisi');
      print('❌ Nama KTP empty');
    } else {
      print('✅ Nama KTP: OK');
    }
    
    if (bpjsKesehatan.trim().isEmpty) {
      errors.add('No. BPJS Kesehatan harus diisi');
      print('❌ BPJS Kesehatan empty');
    } else {
      print('✅ BPJS Kesehatan: OK');
    }
    
    if (npwp.trim().isEmpty) {
      errors.add('NPWP harus diisi');
      print('❌ NPWP empty');
    } else {
      print('✅ NPWP: OK');
    }
    
    if (namaIbu.trim().isEmpty) {
      errors.add('Nama Ibu Kandung harus diisi');
      print('❌ Nama Ibu empty');
    } else {
      print('✅ Nama Ibu: OK');
    }
    
    if (rekening.trim().isEmpty) {
      errors.add('No. Rekening harus diisi');
      print('❌ Rekening empty');
    } else {
      print('✅ Rekening: OK');
    }
    
    if (namaPemilikRek.trim().isEmpty) {
      errors.add('Nama Pemilik Rekening harus diisi');
      print('❌ Nama Pemilik Rek empty');
    } else {
      print('✅ Nama Pemilik Rek: OK');
    }
    
    if (statusPTKP.trim().isEmpty) {
      errors.add('Status PTKP harus dipilih');
      print('❌ Status PTKP empty');
    } else {
      print('✅ Status PTKP: OK');
    }
    
    if (jumlahAnak.trim().isEmpty) {
      errors.add('Jumlah Anak harus diisi');
      print('❌ Jumlah Anak empty');
    } else {
      print('✅ Jumlah Anak: OK');
    }
    
    print('Validation completed:');
    print('  Total errors: ${errors.length}');
    if (errors.isNotEmpty) {
      print('  Error details:');
      for (int i = 0; i < errors.length; i++) {
        print('    ${i + 1}. ${errors[i]}');
      }
    } else {
      print('  ✅ All validations passed!');
    }
    print('==========================================');
    
    return errors;
  }

  /// Update honorarium data for current user
  Future<bool> updateHonorariumData({
    required String kartuKeluarga,
    required String ktp,
    required String namaKtp,
    required String bpjsKesehatan,
    required String npwp,
    required String namaIbu,
    required String rekening,
    required String namaPemilikRek,
    required String statusPTKP,
    required String jumlahAnak,
  }) async {
    return await saveHonorariumData(
      kartuKeluarga: kartuKeluarga,
      ktp: ktp,
      namaKtp: namaKtp,
      bpjsKesehatan: bpjsKesehatan,
      npwp: npwp,
      namaIbu: namaIbu,
      rekening: rekening,
      namaPemilikRek: namaPemilikRek,
      statusPTKP: statusPTKP,
      jumlahAnak: jumlahAnak,
    );
  }

  // ========================================
  // ID CARD DATA OPERATIONS
  // ========================================

  /// Get current user's ID card data
  Future<IdCardModel?> getCurrentIdCardData() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.getIdCardData(userId);
    } catch (e) {
      print('ProfileService: Error getting current ID card data: $e');
      return null;
    }
  }

  /// Save ID card data for current user
  Future<bool> saveIdCardData({
    String fotoPath = '',
    bool isUploaded = false,
  }) async {
    try {
      print('ProfileService: === SAVING ID CARD DATA ===');
      print('ProfileService: Input data:');
      print('  - Foto Path: "$fotoPath"');
      print('  - Is Uploaded: $isUploaded');

      // Validate required fields
      final validationErrors = getIdCardDataValidationErrors(
        fotoPath: fotoPath,
        isUploaded: isUploaded,
      );

      if (validationErrors.isNotEmpty) {
        print('ProfileService: ❌ Validation failed with ${validationErrors.length} errors');
        print('ProfileService: Error details: ${validationErrors.join(", ")}');
        return false;
      }

      print('ProfileService: ✅ Validation passed, creating IdCardModel...');
      
      final userId = getCurrentUserId();
      print('ProfileService: Using userId: $userId');
      
      final now = DateTime.now();
      print('ProfileService: Timestamp: $now');

      final idCard = IdCardModel(
        userId: userId,
        fotoPath: fotoPath,
        isUploaded: isUploaded,
        createdAt: now,
        updatedAt: now,
      );

      print('ProfileService: 🔄 Calling repository.saveIdCardData()...');
      print('ProfileService: Model data preview:');
      print('  - userId: $userId');
      print('  - fotoPath: "$fotoPath"');
      print('  - isUploaded: $isUploaded');
      
      final success = await _repository.saveIdCardData(idCard);
      
      print('ProfileService: 📋 Repository save result: $success');
      
      if (success) {
        print('ProfileService: ✅ ID card data saved to database successfully!');
      } else {
        print('ProfileService: ❌ Failed to save ID card data to database');
      }
      
      return success;
    } catch (e) {
      print('ProfileService: ❌ Error saving ID card data: $e');
      return false;
    }
  }

  /// Check if current user has ID card data
  Future<bool> hasIdCardData() async {
    try {
      final userId = getCurrentUserId();
      return await _repository.hasIdCardData(userId);
    } catch (e) {
      print('ProfileService: Error checking ID card data: $e');
      return false;
    }
  }

  /// Get validation errors for ID card data
  List<String> getIdCardDataValidationErrors({
    required String fotoPath,
    required bool isUploaded,
  }) {
    final errors = <String>[];
    
    print('=== PROFILE SERVICE ID CARD VALIDATION ===');
    print('Validating ID card data...');
    print('Foto Path: "$fotoPath" (length: ${fotoPath.length})');
    print('Is Uploaded: $isUploaded');
    
    // Basic validation - foto path can be empty if not uploaded
    if (isUploaded && fotoPath.trim().isEmpty) {
      errors.add('Foto path tidak boleh kosong jika status uploaded = true');
      print('❌ Foto path empty but marked as uploaded');
    } else if (isUploaded) {
      print('✅ Foto path and upload status: OK');
    } else {
      print('ℹ️ No photo uploaded yet');
    }
    
    // Validate file existence if path is provided
    if (fotoPath.trim().isNotEmpty) {
      try {
        final file = File(fotoPath);
        if (!file.existsSync()) {
          errors.add('File foto tidak ditemukan di path: $fotoPath');
          print('❌ File does not exist at path');
        } else {
          print('✅ File exists at path');
        }
      } catch (e) {
        errors.add('Error mengakses file foto: $e');
        print('❌ Error accessing file: $e');
      }
    }
    
    print('Validation completed:');
    print('  Total errors: ${errors.length}');
    if (errors.isNotEmpty) {
      print('  Error details:');
      for (int i = 0; i < errors.length; i++) {
        print('    ${i + 1}. ${errors[i]}');
      }
    } else {
      print('  ✅ All validations passed!');
    }
    print('==========================================');
    
    return errors;
  }

  /// Update ID card data for current user
  Future<bool> updateIdCardData({
    required String fotoPath,
    required bool isUploaded,
  }) async {
    return await saveIdCardData(
      fotoPath: fotoPath,
      isUploaded: isUploaded,
    );
  }

  // ========================================
  // KELUARGA OPERATIONS
  // ========================================

  /// Save keluarga data for current user
  Future<bool> saveKeluargaData({
    required String namaAyah,
    required String namaIbu,
    required String namaPasangan,
    required String namaAnak,
    required String pekerjaanAyah,
    required String pekerjaanIbu,
    required String pekerjaanPasangan,
  }) async {
    try {
      print('=== PROFILE SERVICE KELUARGA SAVE ===');
      print('Saving keluarga data...');
      print('Nama Ayah: "$namaAyah"');
      print('Nama Ibu: "$namaIbu"');
      print('Nama Pasangan: "$namaPasangan"');
      print('Nama Anak: "$namaAnak"');
      print('Pekerjaan Ayah: "$pekerjaanAyah"');
      print('Pekerjaan Ibu: "$pekerjaanIbu"');
      print('Pekerjaan Pasangan: "$pekerjaanPasangan"');

      // Validate data
      final errors = getKeluargaDataValidationErrors(
        namaAyah: namaAyah,
        namaIbu: namaIbu,
        namaPasangan: namaPasangan,
        namaAnak: namaAnak,
        pekerjaanAyah: pekerjaanAyah,
        pekerjaanIbu: pekerjaanIbu,
        pekerjaanPasangan: pekerjaanPasangan,
      );

      if (errors.isNotEmpty) {
        print('❌ Validation failed:');
        for (final error in errors) {
          print('  - $error');
        }
        return false;
      }

      print('✅ Validation passed');
      
      final userId = _repository.getCurrentUserId();
      final now = DateTime.now();
      
      final keluarga = KeluargaModel(
        userId: userId,
        namaAyah: namaAyah.trim(),
        namaIbu: namaIbu.trim(),
        namaPasangan: namaPasangan.trim(),
        namaAnak: namaAnak.trim(),
        pekerjaanAyah: pekerjaanAyah.trim(),
        pekerjaanIbu: pekerjaanIbu.trim(),
        pekerjaanPasangan: pekerjaanPasangan.trim(),
        createdAt: now,
        updatedAt: now,
      );

      print('ProfileService: 🔄 Calling repository.saveKeluargaData()...');
      print('ProfileService: User ID: $userId');
      print('ProfileService: Created at: ${now.toIso8601String()}');
      print('ProfileService: Updated at: ${now.toIso8601String()}');
      
      final success = await _repository.saveKeluargaData(keluarga);
      
      if (success) {
        print('ProfileService: ✅ Keluarga data saved successfully!');
      } else {
        print('ProfileService: ❌ Failed to save keluarga data');
      }
      
      print('======================================');
      return success;
    } catch (e) {
      print('ProfileService: ❌ Error saving keluarga data: $e');
      print('======================================');
      return false;
    }
  }

  /// Get keluarga data for current user
  Future<KeluargaModel?> getKeluargaData([String? userId]) async {
    try {
      final id = userId ?? _repository.getCurrentUserId();
      return await _repository.getKeluargaData(id);
    } catch (e) {
      print('ProfileService: Error getting keluarga data: $e');
      return null;
    }
  }

  /// Check if current user has keluarga data
  Future<bool> hasKeluargaData([String? userId]) async {
    try {
      final id = userId ?? _repository.getCurrentUserId();
      return await _repository.hasKeluargaData(id);
    } catch (e) {
      print('ProfileService: Error checking keluarga data: $e');
      return false;
    }
  }

  /// Validate keluarga data input
  List<String> getKeluargaDataValidationErrors({
    required String namaAyah,
    required String namaIbu,
    required String namaPasangan,
    required String namaAnak,
    required String pekerjaanAyah,
    required String pekerjaanIbu,
    required String pekerjaanPasangan,
  }) {
    print('=== PROFILE SERVICE KELUARGA VALIDATION ===');
    print('Validating keluarga data...');
    print('Nama Ayah: "$namaAyah" (length: ${namaAyah.length})');
    print('Nama Ibu: "$namaIbu" (length: ${namaIbu.length})');
    print('Nama Pasangan: "$namaPasangan" (length: ${namaPasangan.length})');
    print('Nama Anak: "$namaAnak" (length: ${namaAnak.length})');

    final errors = <String>[];

    // Basic validation - at least one family member should be filled
    final hasAnyData = namaAyah.trim().isNotEmpty ||
                       namaIbu.trim().isNotEmpty ||
                       namaPasangan.trim().isNotEmpty ||
                       namaAnak.trim().isNotEmpty;

    if (!hasAnyData) {
      print('❌ No family member data provided');
      errors.add('Minimal satu anggota keluarga harus diisi');
    } else {
      print('✅ At least one family member provided');
    }

    // Validate nama format if provided
    if (namaAyah.trim().isNotEmpty && namaAyah.trim().length < 2) {
      print('❌ Nama ayah too short');
      errors.add('Nama ayah minimal 2 karakter');
    }

    if (namaIbu.trim().isNotEmpty && namaIbu.trim().length < 2) {
      print('❌ Nama ibu too short');
      errors.add('Nama ibu minimal 2 karakter');
    }

    if (namaPasangan.trim().isNotEmpty && namaPasangan.trim().length < 2) {
      print('❌ Nama pasangan too short');
      errors.add('Nama pasangan minimal 2 karakter');
    }

    if (namaAnak.trim().isNotEmpty && namaAnak.trim().length < 2) {
      print('❌ Nama anak too short');
      errors.add('Nama anak minimal 2 karakter');
    }

    print('Validation completed:');
    print('  Total errors: ${errors.length}');
    if (errors.isNotEmpty) {
      print('  Error details:');
      for (int i = 0; i < errors.length; i++) {
        print('    ${i + 1}. ${errors[i]}');
      }
    } else {
      print('  ✅ All validations passed!');
    }
    print('==========================================');
    
    return errors;
  }

  /// Update keluarga data for current user
  Future<bool> updateKeluargaData({
    required String namaAyah,
    required String namaIbu,
    required String namaPasangan,
    required String namaAnak,
    required String pekerjaanAyah,
    required String pekerjaanIbu,
    required String pekerjaanPasangan,
  }) async {
    return await saveKeluargaData(
      namaAyah: namaAyah,
      namaIbu: namaIbu,
      namaPasangan: namaPasangan,
      namaAnak: namaAnak,
      pekerjaanAyah: pekerjaanAyah,
      pekerjaanIbu: pekerjaanIbu,
      pekerjaanPasangan: pekerjaanPasangan,
    );
  }

  // ========================================
  // PENDIDIKAN OPERATIONS
  // ========================================

  /// Save pendidikan data to SQLite database
  Future<bool> savePendidikanData({
    required String jenjang,
    required String jurusan,
    required String institusi,
    required String kota,
    required String tahunMulai,
    required String tahunSelesai,
    required String ipk,
  }) async {
    print('==========================================');
    print('ProfileService: Saving pendidikan data...');
    print('  Jenjang: $jenjang');
    print('  Jurusan: $jurusan');
    print('  Institusi: $institusi');
    print('  Kota: $kota');
    print('  Tahun: $tahunMulai - $tahunSelesai');
    print('  IPK: $ipk');
    print('==========================================');

    try {
      await initialize();
      
      final userId = getCurrentUserId();
      if (userId.isEmpty) {
        print('ProfileService: ❌ User ID is empty!');
        return false;
      }

      final pendidikanModel = PendidikanModel(
        userId: userId,
        jenjang: jenjang.trim(),
        jurusan: jurusan.trim(),
        institusi: institusi.trim(),
        kota: kota.trim(),
        tahunMulai: tahunMulai.trim(),
        tahunSelesai: tahunSelesai.trim(),
        ipk: ipk.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _repository.savePendidikanData(pendidikanModel);
      
      if (success) {
        print('ProfileService: ✅ Pendidikan data saved successfully!');
      } else {
        print('ProfileService: ❌ Failed to save pendidikan data');
      }
      
      return success;
    } catch (e) {
      print('ProfileService: ❌ Error saving pendidikan data: $e');
      return false;
    }
  }

  /// Get all pendidikan data for current user
  Future<List<PendidikanModel>> getAllPendidikanData() async {
    try {
      await initialize();
      
      final userId = getCurrentUserId();
      if (userId.isEmpty) {
        print('ProfileService: ❌ User ID is empty!');
        return [];
      }

      return await _repository.getPendidikanData(userId);
    } catch (e) {
      print('ProfileService: ❌ Error getting all pendidikan data: $e');
      return [];
    }
  }

  /// Get latest/highest pendidikan data for current user
  Future<PendidikanModel?> getCurrentPendidikanData() async {
    try {
      await initialize();
      
      final userId = getCurrentUserId();
      if (userId.isEmpty) {
        print('ProfileService: ❌ User ID is empty!');
        return null;
      }

      return await _repository.getLatestPendidikanData(userId);
    } catch (e) {
      print('ProfileService: ❌ Error getting current pendidikan data: $e');
      return null;
    }
  }

  /// Check if user has pendidikan data
  Future<bool> hasPendidikanData() async {
    try {
      await initialize();
      
      final userId = getCurrentUserId();
      if (userId.isEmpty) {
        print('ProfileService: ❌ User ID is empty!');
        return false;
      }

      return await _repository.hasPendidikanData(userId);
    } catch (e) {
      print('ProfileService: ❌ Error checking pendidikan data: $e');
      return false;
    }
  }

  /// Delete pendidikan data by ID
  Future<bool> deletePendidikanData(int id) async {
    try {
      await initialize();
      
      return await _repository.deletePendidikanData(id);
    } catch (e) {
      print('ProfileService: ❌ Error deleting pendidikan data: $e');
      return false;
    }
  }

  /// Delete all pendidikan data for current user
  Future<bool> deleteAllPendidikanData() async {
    try {
      await initialize();
      
      final userId = getCurrentUserId();
      if (userId.isEmpty) {
        print('ProfileService: ❌ User ID is empty!');
        return false;
      }

      return await _repository.deleteAllPendidikanData(userId);
    } catch (e) {
      print('ProfileService: ❌ Error deleting all pendidikan data: $e');
      return false;
    }
  }

  /// Update pendidikan data
  Future<bool> updatePendidikanData(PendidikanModel pendidikan) async {
    try {
      await initialize();
      
      return await _repository.updatePendidikanData(pendidikan);
    } catch (e) {
      print('ProfileService: ❌ Error updating pendidikan data: $e');
      return false;
    }
  }

  /// Validate pendidikan data
  List<String> getPendidikanDataValidationErrors({
    required String jenjang,
    required String jurusan,
    required String institusi,
    required String kota,
    required String tahunMulai,
    required String tahunSelesai,
    required String ipk,
  }) {
    print('==========================================');
    print('ProfileService: Validating pendidikan data...');
    print('  Jenjang: "$jenjang"');
    print('  Jurusan: "$jurusan"');
    print('  Institusi: "$institusi"');
    print('  Kota: "$kota"');
    print('  Tahun Mulai: "$tahunMulai"');
    print('  Tahun Selesai: "$tahunSelesai"');
    print('  IPK: "$ipk"');
    print('==========================================');

    List<String> errors = [];

    // Validasi required fields
    if (jenjang.trim().isEmpty) {
      errors.add('Jenjang pendidikan wajib diisi');
    }

    if (jurusan.trim().isEmpty) {
      errors.add('Jurusan wajib diisi');
    }

    if (institusi.trim().isEmpty) {
      errors.add('Nama institusi wajib diisi');
    }

    if (kota.trim().isEmpty) {
      errors.add('Kota wajib diisi');
    }

    if (tahunMulai.trim().isEmpty) {
      errors.add('Tahun mulai wajib diisi');
    }

    if (tahunSelesai.trim().isEmpty) {
      errors.add('Tahun selesai wajib diisi');
    }

    // Validasi format tahun
    if (tahunMulai.trim().isNotEmpty) {
      final tahunMulaiInt = int.tryParse(tahunMulai.trim());
      if (tahunMulaiInt == null || tahunMulaiInt < 1900 || tahunMulaiInt > DateTime.now().year) {
        errors.add('Tahun mulai tidak valid');
      }
    }

    if (tahunSelesai.trim().isNotEmpty) {
      final tahunSelesaiInt = int.tryParse(tahunSelesai.trim());
      if (tahunSelesaiInt == null || tahunSelesaiInt < 1900 || tahunSelesaiInt > DateTime.now().year + 10) {
        errors.add('Tahun selesai tidak valid');
      }
    }

    // Validasi tahun mulai < tahun selesai
    if (tahunMulai.trim().isNotEmpty && tahunSelesai.trim().isNotEmpty) {
      final tahunMulaiInt = int.tryParse(tahunMulai.trim());
      final tahunSelesaiInt = int.tryParse(tahunSelesai.trim());
      
      if (tahunMulaiInt != null && tahunSelesaiInt != null && tahunMulaiInt >= tahunSelesaiInt) {
        errors.add('Tahun mulai harus lebih kecil dari tahun selesai');
      }
    }

    // Validasi IPK (optional)
    if (ipk.trim().isNotEmpty) {
      final ipkDouble = double.tryParse(ipk.trim());
      if (ipkDouble == null || ipkDouble < 0 || ipkDouble > 4.0) {
        errors.add('IPK harus berupa angka antara 0.00 - 4.00');
      }
    }

    // Validasi minimal karakter
    if (jurusan.trim().isNotEmpty && jurusan.trim().length < 2) {
      errors.add('Jurusan minimal 2 karakter');
    }

    if (institusi.trim().isNotEmpty && institusi.trim().length < 2) {
      errors.add('Nama institusi minimal 2 karakter');
    }

    if (kota.trim().isNotEmpty && kota.trim().length < 2) {
      errors.add('Kota minimal 2 karakter');
    }

    print('Validation completed:');
    print('  Total errors: ${errors.length}');
    if (errors.isNotEmpty) {
      print('  Error details:');
      for (int i = 0; i < errors.length; i++) {
        print('    ${i + 1}. ${errors[i]}');
      }
    } else {
      print('  ✅ All validations passed!');
    }
    print('==========================================');
    
    return errors;
  }
}