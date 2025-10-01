import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/absensi_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/Profile%20Page/profile_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/home_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/sihaki_main_page.dart';

// Definisi provider untuk indeks navigasi
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  final List<Widget> _pages = const [
    HomePage(),
    AbsensiPage(),
    SihakiMainPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    // Validasi indeks
    if (currentIndex < 0 || currentIndex >= _pages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(bottomNavIndexProvider.notifier).state = 0;
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBody: true, // Membuat body extend ke belakang navbar
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: const NavBar(),
    );
  }
}

class NavBar extends ConsumerWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Container(
      margin: const EdgeInsets.only(left: 40, right: 40, bottom: 24),
      // Margin lebih besar agar tidak full kanan kiri
      child: Material(
        elevation: 8, // Elevasi ringan agar tetap mengambang
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.10),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: GNav(
              backgroundColor: Colors.transparent,
              gap: 8,
              activeColor: theme.primarySwatch,
              iconSize: 18,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              tabBackgroundColor: theme.primarySwatch.withOpacity(0.12),
              tabBorderRadius: 14,
              color: theme.primarySwatch.withOpacity(0.7),
              tabs: [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'Beranda',
                  textStyle: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: theme.primarySwatch,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                GButton(
                  icon: Icons.access_time_rounded,
                  text: 'Absensi',
                  textStyle: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: theme.primarySwatch,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                GButton(
                  icon: Icons.analytics_rounded,
                  text: 'SIHAKI',
                  textStyle: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: theme.primarySwatch,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                GButton(
                  icon: Icons.person_rounded,
                  text: 'Profile',
                  textStyle: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: theme.primarySwatch,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
              selectedIndex: currentIndex,
              onTabChange: (index) {
                if (index >= 0 && index < 4) {
                  HapticFeedback.lightImpact();
                  ref.read(bottomNavIndexProvider.notifier).state = index;
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
