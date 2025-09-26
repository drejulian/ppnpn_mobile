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
      backgroundColor: const Color(0xFFFAFBFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern Hero Header
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isLargeTablet ? 32 : (isTablet ? 24 : 20),
                vertical: isTablet ? 32 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern Hero Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isTablet ? 32 : 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primarySwatch.withOpacity(0.08),
                          theme.primarySwatch.withOpacity(0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.primarySwatch.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.primarySwatch.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.analytics_rounded,
                            size: isTablet ? 32 : 28,
                            color: theme.primarySwatch,
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 20),
                        // Title
                        Text(
                          'Sistem Informasi Harta Kekayaan',
                          style: theme.typographyBold.bodyLarge.copyWith(
                            color: const Color(0xFF1A202C),
                            fontWeight: FontWeight.w700,
                            fontSize: isTablet ? 24 : 20,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),
                        // Description
                        Text(
                          'Platform terpadu untuk mengelola data pajak, agenda pribadi, database anggota, dan informasi harta kekayaan DPR RI secara efisien dan terintegrasi.',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            color: const Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isTablet ? 40 : 32),

                  // Section Header - Modern Design
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primarySwatch.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.apps_rounded,
                          size: 20,
                          color: theme.primarySwatch,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Menu Layanan',
                              style: theme.typographyBold.bodyLarge.copyWith(
                                color: const Color(0xFF1A202C),
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 20 : 18,
                              ),
                            ),
                            Text(
                              '9 layanan tersedia',
                              style: theme.typographyRegular.bodySmall.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isTablet ? 28 : 24),
                ],
              ),
            ),
          ),

          // Modern Professional Grid
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeTablet ? 32 : (isTablet ? 24 : 20),
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(screenWidth),
                childAspectRatio: _getChildAspectRatio(screenWidth),
                crossAxisSpacing: isTablet ? 24 : 20,
                mainAxisSpacing: isTablet ? 24 : 20,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final items = _getSihakiMenuItems(context);
                if (index >= items.length) return null;

                return _buildModernMenuCard(
                  context,
                  items[index],
                  theme,
                  isTablet,
                  index,
                );
              }, childCount: _getSihakiMenuItems(context).length),
            ),
          ),

          // Bottom spacing
          SliverToBoxAdapter(child: SizedBox(height: isTablet ? 50 : 40)),
        ],
      ),
    );
  }

  // Modern responsive grid helpers
  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) return 4; // Desktop
    if (screenWidth > 900) return 3; // Large tablet
    if (screenWidth > 600) return 3; // Tablet
    return 2; // Mobile
  }

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth > 1200)
      return 1.15; // Desktop - slightly taller for better proportion
    if (screenWidth > 900) return 1.1; // Large tablet
    if (screenWidth > 600) return 1.05; // Tablet
    return 1.0; // Mobile - perfect square
  }

  Widget _buildModernMenuCard(
    BuildContext context,
    MenuItemData item,
    dynamic theme,
    bool isTablet,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.04),
            offset: const Offset(0, 1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container with subtle background
                Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: theme.primarySwatch.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    size: isTablet ? 32 : 28,
                    color: theme.primarySwatch,
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 12),
                // Title
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: theme.typographyBold.bodyMedium.copyWith(
                    color: const Color(0xFF1A202C),
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16 : 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<MenuItemData> _getSihakiMenuItems(BuildContext context) {
    return [
      MenuItemData(
        'Data Pajak PPNPN',
        Icons.receipt_long_rounded,
        const Color(0xFF64748B),
        onTap: () {
          debugPrint('Opening submenu for Data Pajak PPNPN');
          _showSihakiSubMenu(context, 'Data Pajak PPNPN', [
            SubMenuItemData(
              'Surat Keterangan Penghasilan (SKP)',
              Icons.description_rounded,
              const Color(0xFF64748B),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(Routes.skp.name);
              },
            ),
            SubMenuItemData(
              'Bukti Potong Pajak Final',
              Icons.attach_money_rounded,
              const Color(0xFF64748B),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(Routes.ppf.name);
              },
            ),
            SubMenuItemData(
              'Bukti Potong Pajak A1',
              Icons.format_list_numbered_rounded,
              const Color(0xFF64748B),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(Routes.ppa.name);
              },
            ),
          ]);
        },
      ),
      MenuItemData(
        'Agenda Pribadi',
        Icons.calendar_today_rounded,
        const Color(0xFF64748B),
        onTap: () {
          debugPrint('Opening submenu for Agenda Pribadi');
          _showSihakiSubMenu(context, 'Agenda Pribadi', [
            SubMenuItemData(
              'Daftar Agenda',
              Icons.list_alt_rounded,
              const Color(0xFF64748B),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(Routes.daftarAgenda.name);
              },
            ),
            SubMenuItemData(
              'Media Sosial',
              Icons.share_rounded,
              const Color(0xFF64748B),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(Routes.mediaSosialAnggota.name);
              },
            ),
          ]);
        },
      ),
      MenuItemData(
        'Data Pajak Anggota',
        Icons.account_balance_wallet_rounded,
        const Color(0xFF64748B),
        onTap: () {
          debugPrint('Opening submenu for Data Pajak Anggota');
          _showSihakiSubMenu(context, 'Data Pajak Anggota', [
            SubMenuItemData(
              'Surat Keterangan Penghasilan (SKP)',
              Icons.description_rounded,
              const Color(0xFF64748B),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(Routes.skpAnggota.name);
              },
            ),
            SubMenuItemData(
              'Bukti Potong Pajak Final',
              Icons.attach_money_rounded,
              const Color(0xFF64748B),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(Routes.ppfAnggota.name);
              },
            ),
            SubMenuItemData(
              'Bukti Potong Pajak A2',
              Icons.format_list_numbered_rtl_rounded,
              const Color(0xFF64748B),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(Routes.ppaAnggota.name);
              },
            ),
          ]);
        },
      ),
      MenuItemData(
        'Database Anggota',
        Icons.storage_rounded,
        const Color(0xFF64748B),
        onTap: () {
          debugPrint('Navigating to Data Komisi');
          context.pushNamed('dataKomisi');
        },
      ),
      MenuItemData(
        'Data Kunjungan Kerja',
        Icons.flight_rounded,
        const Color(0xFF64748B),
        onTap: () {
          debugPrint('Navigating to Data Kunjungan Kerja Perorangan');
          context.pushNamed(Routes.kunkerPerorangan.name);
        },
      ),
      MenuItemData(
        'Data SIGOTA',
        Icons.fingerprint_rounded,
        const Color(0xFF64748B),
        onTap: () {
          debugPrint('Navigating to Data SIGOTA - KANJENK');
          // context.pushNamed(Routes.dataSigotaKanjek.name);
        },
      ),
      MenuItemData(
        'Dokumen Anggota',
        Icons.article_rounded,
        const Color(0xFF64748B),
        onTap: () {
          debugPrint('Navigating to Dokumen Anggota');
          context.pushNamed(Routes.dataDokumenAnggota.name);
        },
      ),
      MenuItemData(
        'Rumah Aspirasi',
        Icons.home_rounded,
        const Color(0xFF64748B),
        onTap: () {
          debugPrint('Navigating to Kegiatan Rumah Aspirasi');
          context.pushNamed(Routes.daftarPengajuanRumahAspirasi.name);
        },
      ),
      MenuItemData(
        'BPJS',
        Icons.local_hospital_rounded,
        const Color(0xFF64748B),
        onTap: () {
          debugPrint('Navigating to BPJS');
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
