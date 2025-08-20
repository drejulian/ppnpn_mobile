import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/features/auth/presentation/pages/login_page.dart';
import 'package:ppnpm_dpr/features/auth/presentation/pages/lupa_password_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/data_lamaran_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/dokumen_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/edit_profile.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/honorarium_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/idcard_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/keluarga/detail_data_keluarga_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/keluarga/edit_data_keluarga_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/keluarga/tambah_data_kelurga_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/keluarga_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/pendidikan/tambah_data_pendidikan_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/pendidikan/edit_data_pendidikan_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/pendidikan_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/pribadi_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/riwayatPekerjaan/add_data_pekerjaan_pages.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/riwayatPekerjaan/edit_data_pekerjaan_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/riwayat_pekerjaan_page.dart';
<<<<<<< HEAD
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Data%20Pajak%20PPNPN/ppf_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Data%20Pajak%20PPNPN/skp_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/Tambah%20Database/data_feedback_komisi.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/Tambah%20Database/data_keanggotaan.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/Tambah%20Database/data_kendaraan.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/Tambah%20Database/data_kesehatan.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/Tambah%20Database/data_komisi.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/Tambah%20Database/data_kontak.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/Tambah%20Database/data_penerbangan.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/Tambah%20Database/data_pribadi.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/Tambah%20Database/data_tata_naskah.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Dokumen%20Anggota/edit_dokumen.dart';
=======
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakAnggota/ppa_anggota_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakAnggota/ppf_anggota_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakAnggota/skp_anggota_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/ppa_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/ppf_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/skp_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/KunkerPerorangan/daftar_pengajuan_kunker_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/MenuUtama/Cuti/daftar_cuti_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/MenuUtama/Cuti/tambah_cuti_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/MenuUtama/Cuti/edit_cuti_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/MenuUtama/Lembur/daftar_lembur_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/MenuUtama/Lembur/tambah_lembur_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/MenuUtama/Lembur/edit_lembur_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/KunkerPerorangan/edit_kunker_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/KunkerPerorangan/tambah_kunker_page.dart';
>>>>>>> b007e4e4afb68d259d9d269b91dfb06dd5132062
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/absensi_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/profile_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import 'package:ppnpm_dpr/common/widgets/nav_bar.dart';
import 'routes.dart';

part 'router.g.dart';

@riverpod
class InitialRoute extends _$InitialRoute {
  @override
  Future<String> build() async {
    return '/';
  }
}

@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) {
  final initialRoute = ref.watch(initialRouteProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: !kReleaseMode,
    redirect: (context, state) {
      if (initialRoute.isLoading) {
        return null;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: Routes.splash.name,
        builder: (context, state) {
          return SplashPage();
        },
      ),
      GoRoute(
        path: '/login',
        name: Routes.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/lupa-password',
        name: Routes.lupaPassword.name,
        builder: (context, state) => const LupaPasswordPage(),
      ),
      GoRoute(
        path: '/home',
        name: Routes.home.name,
        builder: (_, __) => const MainLayout(),
      ),
      GoRoute(
        path: '/absensi',
        name: Routes.absensi.name,
        builder: (context, state) => const AbsensiPage(),
      ),
      GoRoute(
        path: '/profile',
        name: Routes.profile.name,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: Routes.editProfile.name,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/pribadi',
        name: Routes.pribadi.name,
        builder: (context, state) => const PribadiPage(),
      ),
      GoRoute(
        path: '/honorarium',
        name: Routes.honorarium.name,
        builder: (context, state) => const HonorariumPage(),
      ),
      GoRoute(
        path: '/keluarga',
        name: Routes.keluarga.name,
        builder: (context, state) => const KeluargaPage(),
      ),
      GoRoute(
        path: '/detail-data-keluarga/:memberId',
        name: Routes.detailKeluarga.name,
        builder: (context, state) {
          final memberId = state.pathParameters['memberId']!;
          return DetailDataKeluargaPage(memberId: memberId);
        },
      ),
      GoRoute(
        path: '/add-data-keluarga',
        name: Routes.addDataKeluarga.name,
        builder: (context, state) => const TambahAnggotaKeluargaPage(),
      ),
      
      GoRoute(
        path: '/edit-data-keluarga',
        name: Routes.editDataKeluarga.name,
        builder: (context, state) => const EditDataKeluargaPage(),
      ),
      
      GoRoute(
        path: '/edit-data-keluarga/:memberId',
        name: Routes.editDataKeluargaWithId.name,
        builder: (context, state) {
          final memberId = state.pathParameters['memberId']!;
          return EditDataKeluargaPage(memberId: memberId);
        },
      ),
      GoRoute(
        path: '/id-card',
        name: Routes.idCard.name,
        builder: (context, state) => const IdCardPage(),
      ),
      GoRoute(
        path: '/dokumen',
        name: Routes.dokumen.name,
        builder: (context, state) => const DokumenPage(),
      ),
      GoRoute(
        path: '/pendidikan',
        name: Routes.pendidikan.name,
        builder: (context, state) => const PendidikanPage(),
      ),
      GoRoute(
        path: '/add-data-pendidikan',
        name: Routes.addDataPendidikan.name,
        builder: (context, state) => const TambahDataPendidikanPage(),
      ),
      GoRoute(
        path: '/edit-data-pendidikan',
        name: Routes.editDataPendidikan.name,
        builder: (context, state) {
          final data = state.extra; // Expect Map<String, String> or null
          return EditDataPendidikanPage(
            educationToEdit:
                (data is Map) ? Map<String, String>.from(data) : null,
          );
        },
      ),
      GoRoute(
        path: '/riwayat-pekerjaan',
        name: Routes.riwayatPekerjaan.name,
        builder: (context, state) => const WorkHistoryPage(),
      ),
      GoRoute(
        path: '/add-riwayat-pekerjaan',
        name: Routes.addRiwayatPekerjaan.name,
        builder: (context, state) => const AddWorkHistoryPage(),
      ),
      GoRoute(
        path: '/edit-riwayat-pekerjaan',
        name: Routes.editRiwayatPekerjaan.name,
        builder: (context, state) {
          final data = state.extra as WorkHistoryData;
          return EditDataPekerjaanPage(data: data);
        },
      ),
      GoRoute(
        path: '/data-lamaran',
        name: Routes.dataLamaran.name,
        builder: (context, state) => const ApplicationDataPage(),
      ),
      GoRoute(
        path: '/skp',
        name: Routes.skp.name,
        builder: (context, state) => const SuratKeteranganPenghasilanPage(),
      ),
      GoRoute(
        path: '/ppf',
        name: Routes.ppf.name,
        builder: (context, state) => const BuktiPotongPajakFinalPage(),
      ),
      GoRoute(
<<<<<<< HEAD
        path: '/dataKomisi',
        name: Routes.dataKomisi.name,
        builder: (context, state) => const DataKomisiPage(),
      ),
      GoRoute(
        path: '/data-keanggotaan',
        name: Routes.dataKeanggotaan.name,
        builder: (context, state) => const DataKeanggotaanPage(),
      ),
      GoRoute(
        path: '/data-kendaraan',
        name: Routes.dataKendaraan.name,
        builder: (context, state) => const DataKendaraanPage(),
      ),
      GoRoute(
        path: '/data-pribadi',
        name: Routes.dataPribadi.name,
        builder: (context, state) => const DataPribadiPage(),
      ),
      GoRoute(
        path: '/data-penerbangan',
        name: Routes.dataPenerbangan.name,
        builder: (context, state) => const DataPenerbanganPage(),
      ),
      GoRoute(
        path: '/data-kesehatan',
        name: Routes.dataKesehatan.name,
        builder: (context, state) => const DataKesehatanPage(),
      ),
      GoRoute(
        path: '/data-kontak',
        name: Routes.dataKontak.name,
        builder: (context, state) => const DataKontakPage(),
      ),
      GoRoute(
        path: '/data-tata-naskah',
        name: Routes.dataTataNaskah.name,
        builder: (context, state) => const DataTataNaskahPage(),
      ),
      GoRoute(
        path: '/data-feedback-komisi',
        name: Routes.dataFeedbackKomisi.name,
        builder: (context, state) => const DataFeedbackKomisiPage(),
      ),
      GoRoute(
        path: '/data-dokumen-anggota',
        name: Routes.dataDokumenAnggota.name,
        builder: (context, state) => const DataDokumenAnggotaPage(),
=======
        path: '/ppa',
        name: Routes.ppa.name,
        builder: (context, state) => const BuktiPotongPajakA1Page(),
      ),
      GoRoute(
        path: '/skpAnggota',
        name: Routes.skpAnggota.name,
        builder:
            (context, state) => const SuratKeteranganPenghasilanAnggotaPage(),
      ),
      GoRoute(
        path: '/ppfAnggota',
        name: Routes.ppfAnggota.name,
        builder: (context, state) => const BuktiPotongPajakFinalAnggotaPage(),
      ),
      GoRoute(
        path: '/ppaAnggota',
        name: Routes.ppaAnggota.name,
        builder: (context, state) => const BuktiPotongPajakA2Page(),
      ),
      GoRoute(
        path: '/kunkerPerorangan',
        name: Routes.kunkerPerorangan.name,
        builder: (context, state) => const DaftarPengajuanKunkerPage(),
      ),
      GoRoute(
        path: '/tambahKunkerPerorangan',
        name: Routes.tambahKunkerPerorangan.name,
        builder: (context, state) => const TambahKunkerPeroranganPage(),
      ),
      GoRoute(
        path: '/editKunkerPerorangan',
        name: Routes.editKunkerPerorangan.name,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return EditKunkerPeroranganPage(kunkerData: data);
        },
      ),
      // Cuti
      GoRoute(
        path: '/cuti',
        name: Routes.cuti.name,
        builder: (context, state) => const DaftarCutiPage(),
      ),
      GoRoute(
        path: '/tambahCuti',
        name: Routes.tambahCuti.name,
        builder: (context, state) => const TambahCutiPage(),
      ),
      GoRoute(
        path: '/editCuti',
        name: Routes.editCuti.name,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return EditCutiPage(data: data);
        },
      ),
      // Lembur
      GoRoute(
        path: '/lembur',
        name: Routes.lembur.name,
        builder: (context, state) => const DaftarLemburPage(),
      ),
      GoRoute(
        path: '/tambahLembur',
        name: Routes.tambahLembur.name,
        builder: (context, state) => const TambahLemburPage(),
      ),
      GoRoute(
        path: '/editLembur',
        name: Routes.editLembur.name,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return EditLemburPage(data: data);
        },
>>>>>>> b007e4e4afb68d259d9d269b91dfb06dd5132062
      ),
    ],
  );
}