import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/absensi_page.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/profile_page.dart';

import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/home_page.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  final List<Widget> _pages = const [
    HomePage(), // Index 0 - Beranda
    AbsensiPage(), // Index 1 - Absensi
    HomePage(), // Index 2 - Menu 2 (placeholder)
    ProfilePage(), // Index 3 - Profile
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    // Validation
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            gap: 8,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundGradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.primarySwatch, theme.secondarySwatch],
            ),
            color: Colors.grey,
            tabs: [
              GButton(
                icon: Icons.home_outlined,
                text: 'Beranda',
                textStyle: theme.typographyRegular.bodyExtraSmall.copyWith(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              GButton(
                icon: Icons.schedule,
                text: 'Absensi',
                textStyle: theme.typographyRegular.bodyExtraSmall.copyWith(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              GButton(
                icon: Icons.chat,
                text: 'Menu 2',
                textStyle: theme.typographyRegular.bodyExtraSmall.copyWith(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
                textStyle: theme.typographyRegular.bodyExtraSmall.copyWith(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ],
            selectedIndex: currentIndex,
            onTabChange: (index) {
              // Validate index
              if (index >= 0 && index < 4) {
                ref.read(bottomNavIndexProvider.notifier).state = index;
              }
            },
          ),
        ),
      ),
    );
  }
}
