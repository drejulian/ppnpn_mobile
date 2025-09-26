import 'dart:ui';
import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30), // Sudut lebih membulat
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Efek blur
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                0.21,
              ), // Semi-transparan untuk glassmorphism
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3), // Border halus
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: GNav(
                backgroundColor: Colors.transparent,
                gap: 10,
                activeColor: Colors.white,
                iconSize: 26, // Ikon sedikit lebih besar
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                duration: const Duration(milliseconds: 400),
                tabBackgroundGradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.primarySwatch.withOpacity(0.9),
                    theme.secondarySwatch.withOpacity(0.9),
                  ],
                ),
                color: theme.primarySwatch,
                tabs: [
                  GButton(
                    icon: Icons.home_outlined,
                    text: 'Beranda',
                    textStyle: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  GButton(
                    icon: Icons.schedule,
                    text: 'Absensi',
                    textStyle: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  GButton(
                    icon: Icons.analytics_outlined,
                    text: 'SIHAKI',
                    textStyle: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  GButton(
                    icon: Icons.person,
                    text: 'Profile',
                    textStyle: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
                selectedIndex: currentIndex,
                onTabChange: (index) {
                  if (index >= 0 && index < 4) {
                    ref.read(bottomNavIndexProvider.notifier).state = index;
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
