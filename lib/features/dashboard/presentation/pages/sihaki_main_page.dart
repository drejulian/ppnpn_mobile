import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/sihaki_submenu_modal.dart';

class SihakiMainPage extends ConsumerStatefulWidget {
  const SihakiMainPage({super.key});

  @override
  ConsumerState<SihakiMainPage> createState() => _SihakiMainPageState();
}

class _SihakiMainPageState extends ConsumerState<SihakiMainPage> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeTablet = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern App Bar with gradient
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isLargeTablet ? 32 : (isTablet ? 24 : 16),
                  vertical: isTablet ? 24 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Header Card with glassmorphism effect
                    HeaderCardComponent(
                      title: 'SIHAKI',
                      subtitle: 'Sistem Informasi Harta Kekayaan',
                      description:
                          'Kelola data pajak, agenda pribadi, database anggota, dan informasi harta kekayaan DPR RI dengan mudah dan efisien',
                      icon: Icons.analytics_outlined,
                      isTablet: isTablet,
                      isLargeTablet: isLargeTablet,
                      theme: theme,
                    ),

                    SizedBox(height: isTablet ? 40 : 32),

                    // Enhanced Section Header
                    SectionHeaderComponent(
                      title: 'Menu SIHAKI',
                      counter: '9 Menu',
                      icon: Icons.dashboard_outlined,
                      isTablet: isTablet,
                      theme: theme,
                    ),

                    SizedBox(height: isTablet ? 24 : 20),
                  ],
                ),
              ),
            ),

            // Enhanced Grid View
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeTablet ? 32 : (isTablet ? 24 : 16),
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(screenWidth),
                  childAspectRatio: _getChildAspectRatio(screenWidth),
                  crossAxisSpacing: isTablet ? 20 : 16,
                  mainAxisSpacing: isTablet ? 20 : 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final items = _getSihakiMenuItems(context);
                  if (index >= items.length) return null;

                  return CardMenuComponent(
                    title: items[index].title,
                    icon: items[index].icon,
                    gradientColors: _getModernGradient(index),
                    onTap: items[index].onTap,
                    animationDelay: index * 80,
                    isTablet: isTablet,
                    theme: theme,
                  );
                }, childCount: _getSihakiMenuItems(context).length),
              ),
            ),

            // Bottom spacing
            SliverToBoxAdapter(child: SizedBox(height: isTablet ? 40 : 32)),
          ],
        ),
      ),
    );
  }

  // Helper methods for responsive grid
  int _getCrossAxisCount(double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;

    if (screenWidth > 1200) return 4; // Large desktop
    if (screenWidth > 900) {
      return isLandscape ? 4 : 3; // Tablet landscape/portrait
    }
    if (screenWidth > 600) return isLandscape ? 3 : 3; // Tablet
    return isLandscape ? 3 : 2; // Phone landscape/portrait
  }

  double _getChildAspectRatio(double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;

    if (screenWidth > 1200) return 1.1; // Large desktop
    if (screenWidth > 900) {
      return isLandscape ? 0.95 : 1.0; // Tablet landscape/portrait
    }
    if (screenWidth > 600) return isLandscape ? 0.9 : 0.95; // Tablet
    return isLandscape ? 0.8 : 1.0; // Phone landscape/portrait
  }

  // Get modern gradient colors for each menu item
  List<Color> _getModernGradient(int index) {
    final gradients = [
      [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)], // Red gradient
      [const Color(0xFF4ECDC4), const Color(0xFF44D7C9)], // Teal gradient
      [const Color(0xFF45B7D1), const Color(0xFF5AC8E3)], // Blue gradient
      [const Color(0xFF96CEB4), const Color(0xFFA8E6B2)], // Green gradient
      [const Color(0xFFFECA57), const Color(0xFFFDD835)], // Yellow gradient
      [const Color(0xFF6C5CE7), const Color(0xFF8B7ED8)], // Purple gradient
      [const Color(0xFFE17055), const Color(0xFFE95A3E)], // Orange gradient
      [const Color(0xFFFF7675), const Color(0xFFFF9A9A)], // Pink gradient
      [const Color(0xFF00B894), const Color(0xFF26E0A5)], // Green-blue gradient
    ];

    return gradients[index % gradients.length];
  }

  List<MenuItemData> _getSihakiMenuItems(BuildContext context) {
    return [
      MenuItemData(
        'Data Pajak PPNPN',
        Icons.receipt_long,
        Colors.deepOrange,
        onTap: () {
          debugPrint('💰 Opening submenu for Data Pajak PPNPN');
          _showSihakiSubMenu(context, 'Data Pajak PPNPN', [
            SubMenuItemData(
              'Surat Keterangan Penghasilan (SKP)',
              Icons.description,
              Colors.blue,
              onTap: () {
                // Navigate to SKP PPNPM page
                debugPrint('Navigating to PPNPN SKP'); //
                Navigator.pop(context);
                // context.pushNamed(Routes.ppnpmSkp.name);
                context.pushNamed(Routes.skp.name);
              },
            ),
            SubMenuItemData(
              'Bukti Potong Pajak Final',
              Icons.attach_money,
              Colors.green,
              onTap: () {
                // Navigate to Final Tax Withholding Slip PPNPM page
                debugPrint('Navigating to PPNPN Bukti Potong Pajak Final'); //
                Navigator.pop(context);
                context.pushNamed(Routes.ppf.name);
              },
            ),
            SubMenuItemData(
              'Bukti Potong Pajak A1',
              Icons.format_list_numbered,
              Colors.purple,
              onTap: () {
                // Navigate to Tax Withholding Slip A1 PPNPM page
                debugPrint('Navigating to PPNPN Bukti Potong Pajak A1');
                Navigator.pop(context);
                context.pushNamed(Routes.ppa.name);
              },
            ),
          ]);
        },
      ),
      MenuItemData(
        'Agenda Pribadi',
        Icons.calendar_today,
        Colors.pink,
        onTap: () {
          debugPrint('🗓️ Opening submenu for Agenda Pribadi');
          _showSihakiSubMenu(context, 'Agenda Pribadi', [
            SubMenuItemData(
              'Daftar Agenda',
              Icons.list_alt,
              Colors.orange,
              onTap: () {
                // Navigate to Agenda List page
                debugPrint('Navigating to Daftar Agenda'); //
                Navigator.pop(context);
                context.pushNamed(Routes.daftarAgenda.name);
              },
            ),
            SubMenuItemData(
              'Media Sosial',
              Icons.share,
              Colors.teal,
              onTap: () {
                // Navigate to Member's Social Media page
                debugPrint('Navigating to Media Sosial Anggota');
                Navigator.pop(context);
                context.pushNamed(Routes.mediaSosialAnggota.name);
              },
            ),
          ]);
        },
      ),
      MenuItemData(
        'Data Pajak Anggota',
        Icons.account_balance_wallet,
        Colors.brown,
        onTap: () {
          debugPrint('💲 Opening submenu for Data Pajak Anggota');
          _showSihakiSubMenu(context, 'Data Pajak Anggota', [
            SubMenuItemData(
              'Surat Keterangan Penghasilan (SKP)',
              Icons.description,
              Colors.blue,
              onTap: () {
                // Navigate to SKP Anggota page
                debugPrint('Navigating to Anggota SKP'); //
                Navigator.pop(context);
                context.pushNamed(Routes.skpAnggota.name);
              },
            ),
            SubMenuItemData(
              'Bukti Potong Pajak Final',
              Icons.attach_money,
              Colors.green,
              onTap: () {
                // Navigate to Final Tax Withholding Slip Anggota page
                debugPrint('Navigating to Anggota Bukti Potong Pajak Final'); //
                Navigator.pop(context);
                context.pushNamed(Routes.ppfAnggota.name);
              },
            ),
            SubMenuItemData(
              'Bukti Potong Pajak A2',
              Icons.format_list_numbered_rtl,
              Colors.red,
              onTap: () {
                // Navigate to Tax Withholding Slip A2 Anggota page
                debugPrint('Navigating to Anggota Bukti Potong Pajak A2'); //
                Navigator.pop(context);
                context.pushNamed(Routes.ppaAnggota.name);
              },
            ),
          ]);
        },
      ),
      MenuItemData(
        'Database Anggota',
        Icons.storage,
        Colors.cyan,
        onTap: () {
          debugPrint('Navigating directly to Data Komisi');
          context.pushNamed('dataKomisi');
        },
      ),
      MenuItemData(
        'Data Kunjungan Kerja',
        Icons.flight,
        Colors.lime,
        onTap: () {
          debugPrint('✈️ Navigating to Data Kunjungan Kerja Perorangan'); //
          context.pushNamed(Routes.kunkerPerorangan.name);
        },
      ),
      MenuItemData(
        'Data SIGOTA',
        Icons.fingerprint,
        Colors.grey,
        onTap: () {
          debugPrint('👍 Navigating to Data SIGOTA - KANJENK'); //
          // context.pushNamed(Routes.dataSigotaKanjek.name);
        },
      ),
      MenuItemData(
        'Dokumen Anggota',
        Icons.article,
        Colors.purpleAccent,
        onTap: () {
          debugPrint('📄 Navigating to Dokumen Anggota'); //
          context.pushNamed(Routes.dataDokumenAnggota.name);
        },
      ),
      MenuItemData(
        'Rumah Aspirasi',
        Icons.home,
        Colors.tealAccent,
        onTap: () {
          debugPrint('🏡 Navigating to Kegiatan Rumah Aspirasi'); //
          context.pushNamed(Routes.daftarPengajuanRumahAspirasi.name);
        },
      ),
      MenuItemData(
        'BPJS',
        Icons.local_hospital,
        Colors.lightGreen,
        onTap: () {
          debugPrint('🏥 Navigating to BPJS'); //
          context.pushNamed(Routes.dataBPJS.name);
        },
      ),
    ];
  }

  void _showSihakiSubMenu(
    BuildContext context,
    String title,
    List<SubMenuItemData> subMenuItems,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return SihakiSubMenuModal(title: title, subMenuItems: subMenuItems);
      },
    );
  }
}

class MenuItemData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  MenuItemData(this.title, this.icon, this.color, {this.onTap});
}
