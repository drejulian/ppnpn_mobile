import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/pendidikan_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/pribadi_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/riwayatPekerjaan/add_data_pekerjaan_pages.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/riwayat_pekerjaan_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataAgendaPribadiAnggota/daftar_agenda.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataAgendaPribadiAnggota/detail_agenda_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataMediaSosialAnggota/daftar_medsos.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataMediaSosialAnggota/edit_medsos.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataMediaSosialAnggota/tambah_medsos.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/ppf_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/skp_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/absensi_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/profile_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataAgendaPribadiAnggota/tambah_agenda_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataAgendaPribadiAnggota/edit_agenda_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataAgendaPribadiAnggota/agenda_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/dashboard/presentation/widgets/nav_bar.dart';
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
      // Route for adding new family member (without ID)
      GoRoute(
        path: '/edit-data-keluarga',
        name: Routes.editDataKeluarga.name,
        builder: (context, state) => const EditDataKeluargaPage(),
      ),
      // Route for editing existing family member (with ID)
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
        builder: (context, state) => const EditDataKeluargaPage(),
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
        path: '/daftar-agenda',
        name: Routes.daftarAgenda.name,
        builder: (context, state) => const DaftarAgendaPage(),
      ),
      GoRoute(
        path: '/tambah-agenda',
        name: Routes.tambahAgenda.name,
        builder: (context, state) => const TambahAgendaPage(),
      ),
      GoRoute(
      path: '/edit-agenda',
      name: Routes.editAgenda.name,
      builder: (context, state) {
        final agendaItem = state.extra as AgendaItem;
        return EditAgendaPage(agendaItem: agendaItem);
      },
      ),
      GoRoute(
      path: '/detail-agenda',
      name: Routes.detailAgenda.name,
      builder: (context, state)  {
        final agendaItem = state.extra as AgendaItem;
        return DetailAgendaPage(agenda: agendaItem);
      },
      ),
      GoRoute(
        path: '/media-sosial-anggota',
        name: Routes.mediaSosialAnggota.name,
        builder: (context, state) => const MediaSosialAnggota(),
      ),
      GoRoute(
        path: '/tambah-media-sosial-anggota',
        name: Routes.tambahMediaSosialAnggota.name,
        builder: (context, state) => const TambahMediaSosialAnggotaPage(),
      ),
      GoRoute(
        path: '/edit-media-sosial-anggota',
        name: Routes.editMediaSosialAnggota.name,
        builder: (context, state) {
          final medsos = state.extra as Map<String, String>? ?? {};
          final namaPlatform = medsos['platform'] ?? '';
          final username = medsos['username'] ?? '';
          return EditSosialMediaAnggotaPage(
            namaPlatform: namaPlatform,
            username: username,
          );
        },
      )
    ],
  );
}
