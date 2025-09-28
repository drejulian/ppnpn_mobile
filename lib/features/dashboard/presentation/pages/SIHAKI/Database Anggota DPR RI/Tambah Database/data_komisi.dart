import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';

class DataKomisiPage extends ConsumerStatefulWidget {
  const DataKomisiPage({super.key});

  @override
  ConsumerState<DataKomisiPage> createState() => _DataKomisiPageState();
}

class _DataKomisiPageState extends ConsumerState<DataKomisiPage> {
  final Map<String, bool> _showSavedMessage = {};

  @override
  void initState() {
    super.initState();
    _resetSavedMessage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic> && extra['justSaved'] == true) {
      final sourcePage = extra['sourcePage'] as String? ?? '';

      if (!_showSavedMessage.containsKey(sourcePage)) {
        setState(() {
          _showSavedMessage[sourcePage] = true;
        });
        Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showSavedMessage.remove(sourcePage);
            });
          }
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void _resetSavedMessage() {
    if (_showSavedMessage.isNotEmpty) {
      setState(() {
        _showSavedMessage.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'DATA KOMISI',
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
        backTooltip: 'Kembali',
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final dataPribadiFilled = ref.watch(dataPribadiFilledProvider);
          final dataFeedbackKomisiFilled = ref.watch(
            dataFeedbackKomisiFilledProvider,
          );
          final dataKeanggotaanFilled = ref.watch(
            dataKeanggotaanFilledProvider,
          );
          final dataKendaraanFilled = ref.watch(dataKendaraanFilledProvider);
          final dataPenerbanganFilled = ref.watch(
            dataPenerbanganFilledProvider,
          );
          final dataKesehatanFilled = ref.watch(dataKesehatanFilledProvider);
          final dataKontakFilled = ref.watch(dataKontakFilledProvider);
          final dataTataNaskahFilled = ref.watch(dataTataNaskahFilledProvider);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24.0 : 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SIHAKIDataCard(
                  title: 'Database Anggota DPR RI',
                  subtitle: 'Sistem Informasi Anggota (DASI)',
                  leadingIcon: Icons.storage,
                  statusColor: Colors.blue[600],
                  statusText: 'DASI',
                  fields: [
                    SIHAKIDataField(
                      label: 'Total Modul',
                      value: '8 modul data',
                    ),
                    SIHAKIDataField(
                      label: 'Status Pengisian',
                      value:
                          _getFilledCount(
                                    dataPribadiFilled,
                                    dataFeedbackKomisiFilled,
                                    dataKeanggotaanFilled,
                                    dataKendaraanFilled,
                                    dataPenerbanganFilled,
                                    dataKesehatanFilled,
                                    dataKontakFilled,
                                    dataTataNaskahFilled,
                                  ) >
                                  0
                              ? '${_getFilledCount(dataPribadiFilled, dataFeedbackKomisiFilled, dataKeanggotaanFilled, dataKendaraanFilled, dataPenerbanganFilled, dataKesehatanFilled, dataKontakFilled, dataTataNaskahFilled)}/8 modul lengkap'
                              : 'Belum ada data',
                    ),
                    SIHAKIDataField(
                      label: 'Keterangan',
                      value:
                          'Lengkapi semua modul untuk menyelesaikan pendataan',
                      isLast: true,
                    ),
                  ],
                  actions: [],
                  isTablet: isTablet,
                ),
                const SizedBox(height: 20),

                // Navigation Cards
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Keanggotaan',
                  'Informasi lengkap keanggotaan DPR RI',
                  Icons.group,
                  () => context.go('/data-keanggotaan'),
                  isFilled: dataKeanggotaanFilled,
                  sourcePage: '/data-keanggotaan',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Kendaraan',
                  'Data kendaraan dinas dan pribadi',
                  Icons.directions_car,
                  () => context.go('/data-kendaraan'),
                  isFilled: dataKendaraanFilled,
                  sourcePage: '/data-kendaraan',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Pribadi',
                  'Informasi personal anggota',
                  Icons.person_outline,
                  () => context.go('/data-pribadi'),
                  isFilled: dataPribadiFilled,
                  sourcePage: '/data-pribadi',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Penerbangan',
                  'Informasi perjalanan udara',
                  Icons.flight,
                  () => context.go('/data-penerbangan'),
                  isFilled: dataPenerbanganFilled,
                  sourcePage: '/data-penerbangan',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Kesehatan',
                  'Informasi kesehatan dan vaksinasi',
                  Icons.health_and_safety,
                  () => context.go('/data-kesehatan'),
                  isFilled: dataKesehatanFilled,
                  sourcePage: '/data-kesehatan',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Kontak',
                  'Informasi kontak dan komunikasi',
                  Icons.contact_phone,
                  () => context.go('/data-kontak'),
                  isFilled: dataKontakFilled,
                  sourcePage: '/data-kontak',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Tata Naskah',
                  'Pengelolaan dokumen dan arsip',
                  Icons.description,
                  () => context.go('/data-tata-naskah'),
                  isFilled: dataTataNaskahFilled,
                  sourcePage: '/data-tata-naskah',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 12),
                _buildModernNavigationCard(
                  context,
                  theme,
                  'Data Feedback Komisi',
                  'Umpan balik dan evaluasi komisi',
                  Icons.feedback,
                  () => context.go('/data-feedback-komisi'),
                  isFilled: dataFeedbackKomisiFilled,
                  sourcePage: '/data-feedback-komisi',
                  isTablet: isTablet,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final allFilled =
                          dataPribadiFilled &&
                          dataFeedbackKomisiFilled &&
                          dataKeanggotaanFilled &&
                          dataKendaraanFilled &&
                          dataPenerbanganFilled &&
                          dataKesehatanFilled &&
                          dataKontakFilled &&
                          dataTataNaskahFilled;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            allFilled
                                ? 'Semua data berhasil disimpan!'
                                : 'Harap lengkapi semua data terlebih dahulu!',
                          ),
                          backgroundColor:
                              allFilled ? Colors.green : Colors.orange,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primarySwatch,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'SIMPAN',
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _getFilledCount(
    bool dataPribadiFilled,
    bool dataFeedbackKomisiFilled,
    bool dataKeanggotaanFilled,
    bool dataKendaraanFilled,
    bool dataPenerbanganFilled,
    bool dataKesehatanFilled,
    bool dataKontakFilled,
    bool dataTataNaskahFilled,
  ) {
    int count = 0;
    if (dataPribadiFilled) count++;
    if (dataFeedbackKomisiFilled) count++;
    if (dataKeanggotaanFilled) count++;
    if (dataKendaraanFilled) count++;
    if (dataPenerbanganFilled) count++;
    if (dataKesehatanFilled) count++;
    if (dataKontakFilled) count++;
    if (dataTataNaskahFilled) count++;
    return count;
  }

  Widget _buildModernNavigationCard(
    BuildContext context,
    dynamic theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    required bool isFilled,
    required String sourcePage,
    required bool isTablet,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primarySwatch, theme.secondarySwatch],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primarySwatch.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isTablet ? 24.0 : 20.0,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.typographyRegular.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          fontSize: isTablet ? 16.0 : 14.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.grey[600],
                          fontSize: isTablet ? 14.0 : 12.0,
                        ),
                      ),
                      if (_showSavedMessage[sourcePage] == true) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Data Tersimpan',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status and Arrow
                Row(
                  children: [
                    if (isFilled) ...[
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                          size: 16.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 14.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
