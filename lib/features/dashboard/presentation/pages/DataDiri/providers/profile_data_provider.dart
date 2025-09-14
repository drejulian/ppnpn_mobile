import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

// Models for different sections
class HonorariumData {
  final String kartuKeluarga;
  final String ktp;
  final String namaKtp;
  final String bpjsKesehatan;
  final String npwp;
  final String namaIbu;
  final String rekening;
  final String namaPemilikRek;
  final String jumlahAnak;
  final String statusPTKP;

  HonorariumData({
    this.kartuKeluarga = '',
    this.ktp = '',
    this.namaKtp = '',
    this.bpjsKesehatan = '',
    this.npwp = '',
    this.namaIbu = '',
    this.rekening = '',
    this.namaPemilikRek = '',
    this.jumlahAnak = '',
    this.statusPTKP = 'Kawin (K)',
  });

  HonorariumData copyWith({
    String? kartuKeluarga,
    String? ktp,
    String? namaKtp,
    String? bpjsKesehatan,
    String? npwp,
    String? namaIbu,
    String? rekening,
    String? namaPemilikRek,
    String? jumlahAnak,
    String? statusPTKP,
  }) {
    return HonorariumData(
      kartuKeluarga: kartuKeluarga ?? this.kartuKeluarga,
      ktp: ktp ?? this.ktp,
      namaKtp: namaKtp ?? this.namaKtp,
      bpjsKesehatan: bpjsKesehatan ?? this.bpjsKesehatan,
      npwp: npwp ?? this.npwp,
      namaIbu: namaIbu ?? this.namaIbu,
      rekening: rekening ?? this.rekening,
      namaPemilikRek: namaPemilikRek ?? this.namaPemilikRek,
      jumlahAnak: jumlahAnak ?? this.jumlahAnak,
      statusPTKP: statusPTKP ?? this.statusPTKP,
    );
  }
}

class EditProfileData {
  final String nik;
  final String nama;
  final String bidangKeahlian;
  final String toefl;
  final String pendidikan;

  EditProfileData({
    this.nik = '',
    this.nama = '',
    this.bidangKeahlian = '',
    this.toefl = '',
    this.pendidikan = '',
  });

  EditProfileData copyWith({
    String? nik,
    String? nama,
    String? bidangKeahlian,
    String? toefl,
    String? pendidikan,
  }) {
    return EditProfileData(
      nik: nik ?? this.nik,
      nama: nama ?? this.nama,
      bidangKeahlian: bidangKeahlian ?? this.bidangKeahlian,
      toefl: toefl ?? this.toefl,
      pendidikan: pendidikan ?? this.pendidikan,
    );
  }
}

class PribadiData {
  final String tempatLahir;
  final String tanggalLahir;
  final String address;
  final String propinsi;
  final String kota;
  final String kecamatan;
  final String kelurahan;
  final String rt;
  final String rw;
  final String kodePos;
  final String teleponRumah;
  final String teleponKantor;
  final String handphone;
  final String email;
  final String statusPerkawinan;
  final String agama;
  final String golonganDarah;
  final String jenisKelamin;
  final String statusDomisili;

  PribadiData({
    this.tempatLahir = '',
    this.tanggalLahir = '',
    this.address = '',
    this.propinsi = '',
    this.kota = '',
    this.kecamatan = '',
    this.kelurahan = '',
    this.rt = '',
    this.rw = '',
    this.kodePos = '',
    this.teleponRumah = '',
    this.teleponKantor = '',
    this.handphone = '',
    this.email = '',
    this.statusPerkawinan = '',
    this.agama = '',
    this.golonganDarah = '',
    this.jenisKelamin = '',
    this.statusDomisili = '',
  });

  PribadiData copyWith({
    String? tempatLahir,
    String? tanggalLahir,
    String? address,
    String? propinsi,
    String? kota,
    String? kecamatan,
    String? kelurahan,
    String? rt,
    String? rw,
    String? kodePos,
    String? teleponRumah,
    String? teleponKantor,
    String? handphone,
    String? email,
    String? statusPerkawinan,
    String? agama,
    String? golonganDarah,
    String? jenisKelamin,
    String? statusDomisili,
  }) {
    return PribadiData(
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      address: address ?? this.address,
      propinsi: propinsi ?? this.propinsi,
      kota: kota ?? this.kota,
      kecamatan: kecamatan ?? this.kecamatan,
      kelurahan: kelurahan ?? this.kelurahan,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      kodePos: kodePos ?? this.kodePos,
      teleponRumah: teleponRumah ?? this.teleponRumah,
      teleponKantor: teleponKantor ?? this.teleponKantor,
      handphone: handphone ?? this.handphone,
      email: email ?? this.email,
      statusPerkawinan: statusPerkawinan ?? this.statusPerkawinan,
      agama: agama ?? this.agama,
      golonganDarah: golonganDarah ?? this.golonganDarah,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      statusDomisili: statusDomisili ?? this.statusDomisili,
    );
  }
}

// Data Lamaran model
class DataLamaranData {
  final String position;
  final String placement;
  final String subPlacement;
  final String otherPosition;
  final DateTime? startDate;
  final DateTime? letterDate;
  final DateTime? placementDate;

  DataLamaranData({
    this.position = '',
    this.placement = '',
    this.subPlacement = '',
    this.otherPosition = '',
    this.startDate,
    this.letterDate,
    this.placementDate,
  });

  DataLamaranData copyWith({
    String? position,
    String? placement,
    String? subPlacement,
    String? otherPosition,
    DateTime? startDate,
    DateTime? letterDate,
    DateTime? placementDate,
  }) {
    return DataLamaranData(
      position: position ?? this.position,
      placement: placement ?? this.placement,
      subPlacement: subPlacement ?? this.subPlacement,
      otherPosition: otherPosition ?? this.otherPosition,
      startDate: startDate ?? this.startDate,
      letterDate: letterDate ?? this.letterDate,
      placementDate: placementDate ?? this.placementDate,
    );
  }
}

// Dokumen data model  
class DokumenData {
  final bool cvUploaded;
  final bool ijazahUploaded;
  final bool transkripUploaded;
  final bool suratLamaranUploaded;
  final bool fotoUploaded;
  final bool ktpUploaded;
  final bool kkUploaded;
  final bool sertifikatUploaded;

  DokumenData({
    this.cvUploaded = false,
    this.ijazahUploaded = false,
    this.transkripUploaded = false,
    this.suratLamaranUploaded = false,
    this.fotoUploaded = false,
    this.ktpUploaded = false,
    this.kkUploaded = false,
    this.sertifikatUploaded = false,
  });

  DokumenData copyWith({
    bool? cvUploaded,
    bool? ijazahUploaded,
    bool? transkripUploaded,
    bool? suratLamaranUploaded,
    bool? fotoUploaded,
    bool? ktpUploaded,
    bool? kkUploaded,
    bool? sertifikatUploaded,
  }) {
    return DokumenData(
      cvUploaded: cvUploaded ?? this.cvUploaded,
      ijazahUploaded: ijazahUploaded ?? this.ijazahUploaded,
      transkripUploaded: transkripUploaded ?? this.transkripUploaded,
      suratLamaranUploaded: suratLamaranUploaded ?? this.suratLamaranUploaded,
      fotoUploaded: fotoUploaded ?? this.fotoUploaded,
      ktpUploaded: ktpUploaded ?? this.ktpUploaded,
      kkUploaded: kkUploaded ?? this.kkUploaded,
      sertifikatUploaded: sertifikatUploaded ?? this.sertifikatUploaded,
    );
  }
}

// Keluarga data model
class KeluargaData {
  final String namaAyah;
  final String namaIbu;
  final String namaPasangan;
  final String namaAnak;
  final String pekerjaanAyah;
  final String pekerjaanIbu;
  final String pekerjaanPasangan;

  KeluargaData({
    this.namaAyah = '',
    this.namaIbu = '',
    this.namaPasangan = '',
    this.namaAnak = '',
    this.pekerjaanAyah = '',
    this.pekerjaanIbu = '',
    this.pekerjaanPasangan = '',
  });

  KeluargaData copyWith({
    String? namaAyah,
    String? namaIbu,
    String? namaPasangan,
    String? namaAnak,
    String? pekerjaanAyah,
    String? pekerjaanIbu,
    String? pekerjaanPasangan,
  }) {
    return KeluargaData(
      namaAyah: namaAyah ?? this.namaAyah,
      namaIbu: namaIbu ?? this.namaIbu,
      namaPasangan: namaPasangan ?? this.namaPasangan,
      namaAnak: namaAnak ?? this.namaAnak,
      pekerjaanAyah: pekerjaanAyah ?? this.pekerjaanAyah,
      pekerjaanIbu: pekerjaanIbu ?? this.pekerjaanIbu,
      pekerjaanPasangan: pekerjaanPasangan ?? this.pekerjaanPasangan,
    );
  }
}

// Pendidikan data model
class PendidikanData {
  final String tingkatPendidikan;
  final String namaInstitusi;
  final String jurusan;
  final String tahunLulus;
  final String ipk;

  PendidikanData({
    this.tingkatPendidikan = '',
    this.namaInstitusi = '',
    this.jurusan = '',
    this.tahunLulus = '',
    this.ipk = '',
  });

  PendidikanData copyWith({
    String? tingkatPendidikan,
    String? namaInstitusi,
    String? jurusan,
    String? tahunLulus,
    String? ipk,
  }) {
    return PendidikanData(
      tingkatPendidikan: tingkatPendidikan ?? this.tingkatPendidikan,
      namaInstitusi: namaInstitusi ?? this.namaInstitusi,
      jurusan: jurusan ?? this.jurusan,
      tahunLulus: tahunLulus ?? this.tahunLulus,
      ipk: ipk ?? this.ipk,
    );
  }
}

// Riwayat Pekerjaan data model
class RiwayatPekerjaanData {
  final String namaPerusahaan;
  final String posisi;
  final String tahunMulai;
  final String tahunSelesai;
  final String deskripsiTugas;

  RiwayatPekerjaanData({
    this.namaPerusahaan = '',
    this.posisi = '',
    this.tahunMulai = '',
    this.tahunSelesai = '',
    this.deskripsiTugas = '',
  });

  RiwayatPekerjaanData copyWith({
    String? namaPerusahaan,
    String? posisi,
    String? tahunMulai,
    String? tahunSelesai,
    String? deskripsiTugas,
  }) {
    return RiwayatPekerjaanData(
      namaPerusahaan: namaPerusahaan ?? this.namaPerusahaan,
      posisi: posisi ?? this.posisi,
      tahunMulai: tahunMulai ?? this.tahunMulai,
      tahunSelesai: tahunSelesai ?? this.tahunSelesai,
      deskripsiTugas: deskripsiTugas ?? this.deskripsiTugas,
    );
  }
}

// ID Card data model
class IdCardData {
  final String fotoPath;
  final bool isUploaded;

  IdCardData({
    this.fotoPath = '',
    this.isUploaded = false,
  });

  IdCardData copyWith({
    String? fotoPath,
    bool? isUploaded,
  }) {
    return IdCardData(
      fotoPath: fotoPath ?? this.fotoPath,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }
}

// Notifiers for each section
class HonorariumNotifier extends StateNotifier<HonorariumData> {
  HonorariumNotifier() : super(HonorariumData());

  void updateData(HonorariumData newData) {
    state = newData;
  }

  void updateField(String field, String value) {
    switch (field) {
      case 'kartuKeluarga':
        state = state.copyWith(kartuKeluarga: value);
        break;
      case 'ktp':
        state = state.copyWith(ktp: value);
        break;
      case 'namaKtp':
        state = state.copyWith(namaKtp: value);
        break;
      case 'bpjsKesehatan':
        state = state.copyWith(bpjsKesehatan: value);
        break;
      case 'npwp':
        state = state.copyWith(npwp: value);
        break;
      case 'namaIbu':
        state = state.copyWith(namaIbu: value);
        break;
      case 'rekening':
        state = state.copyWith(rekening: value);
        break;
      case 'namaPemilikRek':
        state = state.copyWith(namaPemilikRek: value);
        break;
      case 'jumlahAnak':
        state = state.copyWith(jumlahAnak: value);
        break;
      case 'statusPTKP':
        state = state.copyWith(statusPTKP: value);
        break;
    }
  }
}

class EditProfileNotifier extends StateNotifier<EditProfileData> {
  EditProfileNotifier() : super(EditProfileData());

  void updateData(EditProfileData newData) {
    state = newData;
  }

  void updateField(String field, String value) {
    switch (field) {
      case 'nik':
        state = state.copyWith(nik: value);
        break;
      case 'nama':
        state = state.copyWith(nama: value);
        break;
      case 'bidangKeahlian':
        state = state.copyWith(bidangKeahlian: value);
        break;
      case 'toefl':
        state = state.copyWith(toefl: value);
        break;
      case 'pendidikan':
        state = state.copyWith(pendidikan: value);
        break;
    }
  }
}

class PribadiNotifier extends StateNotifier<PribadiData> {
  PribadiNotifier() : super(PribadiData());

  void updateData(PribadiData newData) {
    state = newData;
  }

  void updateField(String field, String value) {
    switch (field) {
      case 'tempatLahir':
        state = state.copyWith(tempatLahir: value);
        break;
      case 'tanggalLahir':
        state = state.copyWith(tanggalLahir: value);
        break;
      case 'address':
        state = state.copyWith(address: value);
        break;
      case 'propinsi':
        state = state.copyWith(propinsi: value);
        break;
      case 'kota':
        state = state.copyWith(kota: value);
        break;
      case 'kecamatan':
        state = state.copyWith(kecamatan: value);
        break;
      case 'kelurahan':
        state = state.copyWith(kelurahan: value);
        break;
      case 'rt':
        state = state.copyWith(rt: value);
        break;
      case 'rw':
        state = state.copyWith(rw: value);
        break;
      case 'kodePos':
        state = state.copyWith(kodePos: value);
        break;
      case 'teleponRumah':
        state = state.copyWith(teleponRumah: value);
        break;
      case 'teleponKantor':
        state = state.copyWith(teleponKantor: value);
        break;
      case 'handphone':
        state = state.copyWith(handphone: value);
        break;
      case 'email':
        state = state.copyWith(email: value);
        break;
      case 'statusPerkawinan':
        state = state.copyWith(statusPerkawinan: value);
        break;
      case 'agama':
        state = state.copyWith(agama: value);
        break;
      case 'golonganDarah':
        state = state.copyWith(golonganDarah: value);
        break;
      case 'jenisKelamin':
        state = state.copyWith(jenisKelamin: value);
        break;
      case 'statusDomisili':
        state = state.copyWith(statusDomisili: value);
        break;
    }
  }
}

// Data Lamaran Notifier
class DataLamaranNotifier extends StateNotifier<DataLamaranData> {
  DataLamaranNotifier() : super(DataLamaranData());

  void updateData(DataLamaranData newData) {
    state = newData;
  }

  void updateField(String field, dynamic value) {
    switch (field) {
      case 'position':
        state = state.copyWith(position: value as String);
        break;
      case 'placement':
        state = state.copyWith(placement: value as String);
        break;
      case 'subPlacement':
        state = state.copyWith(subPlacement: value as String);
        break;
      case 'otherPosition':
        state = state.copyWith(otherPosition: value as String);
        break;
      case 'startDate':
        state = state.copyWith(startDate: value as DateTime?);
        break;
      case 'letterDate':
        state = state.copyWith(letterDate: value as DateTime?);
        break;
      case 'placementDate':
        state = state.copyWith(placementDate: value as DateTime?);
        break;
    }
  }
}

// Dokumen Notifier
class DokumenNotifier extends StateNotifier<DokumenData> {
  DokumenNotifier() : super(DokumenData());

  void updateData(DokumenData newData) {
    state = newData;
  }

  void updateField(String field, bool value) {
    switch (field) {
      case 'cvUploaded':
        state = state.copyWith(cvUploaded: value);
        break;
      case 'ijazahUploaded':
        state = state.copyWith(ijazahUploaded: value);
        break;
      case 'transkripUploaded':
        state = state.copyWith(transkripUploaded: value);
        break;
      case 'suratLamaranUploaded':
        state = state.copyWith(suratLamaranUploaded: value);
        break;
      case 'fotoUploaded':
        state = state.copyWith(fotoUploaded: value);
        break;
      case 'ktpUploaded':
        state = state.copyWith(ktpUploaded: value);
        break;
      case 'kkUploaded':
        state = state.copyWith(kkUploaded: value);
        break;
      case 'sertifikatUploaded':
        state = state.copyWith(sertifikatUploaded: value);
        break;
    }
  }
}

// Keluarga Notifier
class KeluargaNotifier extends StateNotifier<KeluargaData> {
  KeluargaNotifier() : super(KeluargaData());

  void updateData(KeluargaData newData) {
    state = newData;
  }

  void updateField(String field, String value) {
    switch (field) {
      case 'namaAyah':
        state = state.copyWith(namaAyah: value);
        break;
      case 'namaIbu':
        state = state.copyWith(namaIbu: value);
        break;
      case 'namaPasangan':
        state = state.copyWith(namaPasangan: value);
        break;
      case 'namaAnak':
        state = state.copyWith(namaAnak: value);
        break;
      case 'pekerjaanAyah':
        state = state.copyWith(pekerjaanAyah: value);
        break;
      case 'pekerjaanIbu':
        state = state.copyWith(pekerjaanIbu: value);
        break;
      case 'pekerjaanPasangan':
        state = state.copyWith(pekerjaanPasangan: value);
        break;
    }
  }
}

// Pendidikan Notifier
class PendidikanNotifier extends StateNotifier<PendidikanData> {
  PendidikanNotifier() : super(PendidikanData());

  void updateData(PendidikanData newData) {
    state = newData;
  }

  void updateField(String field, String value) {
    switch (field) {
      case 'tingkatPendidikan':
        state = state.copyWith(tingkatPendidikan: value);
        break;
      case 'namaInstitusi':
        state = state.copyWith(namaInstitusi: value);
        break;
      case 'jurusan':
        state = state.copyWith(jurusan: value);
        break;
      case 'tahunLulus':
        state = state.copyWith(tahunLulus: value);
        break;
      case 'ipk':
        state = state.copyWith(ipk: value);
        break;
    }
  }
}

// Riwayat Pekerjaan Notifier
class RiwayatPekerjaanNotifier extends StateNotifier<RiwayatPekerjaanData> {
  RiwayatPekerjaanNotifier() : super(RiwayatPekerjaanData());

  void updateData(RiwayatPekerjaanData newData) {
    state = newData;
  }

  void updateField(String field, String value) {
    switch (field) {
      case 'namaPerusahaan':
        state = state.copyWith(namaPerusahaan: value);
        break;
      case 'posisi':
        state = state.copyWith(posisi: value);
        break;
      case 'tahunMulai':
        state = state.copyWith(tahunMulai: value);
        break;
      case 'tahunSelesai':
        state = state.copyWith(tahunSelesai: value);
        break;
      case 'deskripsiTugas':
        state = state.copyWith(deskripsiTugas: value);
        break;
    }
  }
}

// ID Card Notifier
class IdCardNotifier extends StateNotifier<IdCardData> {
  IdCardNotifier() : super(IdCardData());

  void updateData(IdCardData newData) {
    // Validate image path before saving
    if (newData.fotoPath.isNotEmpty) {
      try {
        final file = File(newData.fotoPath);
        if (!file.existsSync()) {
          print('IdCard: Invalid file path, clearing data: ${newData.fotoPath}');
          state = IdCardData(fotoPath: '', isUploaded: false);
          return;
        }
      } catch (e) {
        print('IdCard: Error validating file, clearing data: $e');
        state = IdCardData(fotoPath: '', isUploaded: false);
        return;
      }
    }
    
    state = newData;
  }

  void updateField(String field, dynamic value) {
    switch (field) {
      case 'fotoPath':
        // Validate file path before updating
        final String path = value as String;
        if (path.isNotEmpty) {
          try {
            final file = File(path);
            if (file.existsSync()) {
              state = state.copyWith(fotoPath: path);
            } else {
              print('IdCard: File does not exist, not updating: $path');
            }
          } catch (e) {
            print('IdCard: Error validating file path: $e');
          }
        } else {
          state = state.copyWith(fotoPath: path);
        }
        break;
      case 'isUploaded':
        state = state.copyWith(isUploaded: value as bool);
        break;
    }
  }
  
  void validateAndCleanData() {
    if (state.fotoPath.isNotEmpty) {
      try {
        final file = File(state.fotoPath);
        if (!file.existsSync()) {
          print('IdCard: Cleaning invalid file path: ${state.fotoPath}');
          state = IdCardData(fotoPath: '', isUploaded: false);
        }
      } catch (e) {
        print('IdCard: Error during validation, clearing data: $e');
        state = IdCardData(fotoPath: '', isUploaded: false);
      }
    }
  }
}

// Section completion tracking
class ProfileCompletionNotifier extends StateNotifier<Map<String, bool>> {
  ProfileCompletionNotifier() : super({
    'editProfile': false,
    'identitasDiri': false,
    'honorarium': false,
    'keluarga': false,
    'pasFoto': false,
    'dokumen': false,
    'pendidikan': false,
    'riwayatPekerjaan': false,
    'dataLamaran': false,
  });

  void markCompleted(String sectionKey) {
    state = {
      ...state,
      sectionKey: true,
    };
  }

  void markIncomplete(String sectionKey) {
    state = {
      ...state,
      sectionKey: false,
    };
  }

  // Reset all completion status for fresh login
  void resetAll() {
    state = {
      'editProfile': false,
      'identitasDiri': false,
      'honorarium': false,
      'keluarga': false,
      'pasFoto': false,
      'dokumen': false,
      'pendidikan': false,
      'riwayatPekerjaan': false,
      'dataLamaran': false,
    };
  }

  int get completedCount {
    return state.values.where((completed) => completed).length;
  }

  double get completionPercentage {
    return completedCount / state.length;
  }
}

// Providers
final honorariumDataProvider = StateNotifierProvider<HonorariumNotifier, HonorariumData>(
  (ref) => HonorariumNotifier(),
);

final editProfileDataProvider = StateNotifierProvider<EditProfileNotifier, EditProfileData>(
  (ref) => EditProfileNotifier(),
);

final pribadiDataProvider = StateNotifierProvider<PribadiNotifier, PribadiData>(
  (ref) => PribadiNotifier(),
);

final dataLamaranDataProvider = StateNotifierProvider<DataLamaranNotifier, DataLamaranData>(
  (ref) => DataLamaranNotifier(),
);

final dokumenDataProvider = StateNotifierProvider<DokumenNotifier, DokumenData>(
  (ref) => DokumenNotifier(),
);

final keluargaDataProvider = StateNotifierProvider<KeluargaNotifier, KeluargaData>(
  (ref) => KeluargaNotifier(),
);

final pendidikanDataProvider = StateNotifierProvider<PendidikanNotifier, PendidikanData>(
  (ref) => PendidikanNotifier(),
);

final riwayatPekerjaanDataProvider = StateNotifierProvider<RiwayatPekerjaanNotifier, RiwayatPekerjaanData>(
  (ref) => RiwayatPekerjaanNotifier(),
);

final idCardDataProvider = StateNotifierProvider<IdCardNotifier, IdCardData>(
  (ref) => IdCardNotifier(),
);

final profileCompletionProvider = StateNotifierProvider<ProfileCompletionNotifier, Map<String, bool>>(
  (ref) => ProfileCompletionNotifier(),
);
