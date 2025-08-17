import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/providers.dart';

class DataKomisiPage extends ConsumerStatefulWidget {
  const DataKomisiPage({super.key});

  @override
  ConsumerState<DataKomisiPage> createState() => _DataKomisiPageState();
}

class _DataKomisiPageState extends ConsumerState<DataKomisiPage> {
  Map<String, bool> _showSavedMessage = {};

  @override
  void initState() {
    super.initState();
    _resetSavedMessage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    print('didChangeDependencies - Extra received: $extra');
    if (extra is Map<String, dynamic> && extra['justSaved'] == true) {
      final sourcePage = extra['sourcePage'] as String? ?? '';
      print('Processing sourcePage: $sourcePage');

      if (!_showSavedMessage.containsKey(sourcePage)) {
        setState(() {
          _showSavedMessage[sourcePage] = true;
          print('Showing saved message for $sourcePage');
        });
        Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showSavedMessage.remove(sourcePage);
              print('Removed saved message for $sourcePage');
            });
          }
        });
      } else {
        print('Message already shown for $sourcePage');
      }
    } else {
      print('No valid extra data or justSaved is false');
    }
    // Memastikan state provider diperbarui
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void _resetSavedMessage() {
    if (_showSavedMessage.isNotEmpty) {
      setState(() {
        _showSavedMessage.clear();
        print('Reset saved messages');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'DATA KOMISI',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final dataPribadiFilled = ref.watch(dataPribadiFilledProvider);
          final dataFeedbackKomisiFilled = ref.watch(dataFeedbackKomisiFilledProvider);
          final dataKeanggotaanFilled = ref.watch(dataKeanggotaanFilledProvider);
          final dataKendaraanFilled = ref.watch(dataKendaraanFilledProvider);
          final dataPenerbanganFilled = ref.watch(dataPenerbanganFilledProvider);
          final dataKesehatanFilled = ref.watch(dataKesehatanFilledProvider);
          final dataKontakFilled = ref.watch(dataKontakFilledProvider);
          final dataTataNaskahFilled = ref.watch(dataTataNaskahFilledProvider);

          print('Building DataKomisiPage - dataPribadiFilled: $dataPribadiFilled, dataKeanggotaanFilled: $dataKeanggotaanFilled, Show Saved Message: $_showSavedMessage');

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24.0 : 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Database Anggota DPR RI (DASI)',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildNavigationCard(
                  context,
                  theme,
                  'Data Keanggotaan',
                  Icons.group,
                  () => context.go('/data-keanggotaan'),
                  isFilled: dataKeanggotaanFilled,
                  sourcePage: '/data-keanggotaan',
                ),
                const SizedBox(height: 16),
                _buildNavigationCard(
                  context,
                  theme,
                  'Data Kendaraan',
                  Icons.directions_car,
                  () => context.go('/data-kendaraan'),
                  isFilled: dataKendaraanFilled,
                  sourcePage: '/data-kendaraan',
                ),
                const SizedBox(height: 16),
                _buildNavigationCard(
                  context,
                  theme,
                  'Data Pribadi',
                  Icons.person_outline,
                  () => context.go('/data-pribadi'),
                  isFilled: dataPribadiFilled,
                  sourcePage: '/data-pribadi',
                ),
                const SizedBox(height: 16),
                _buildNavigationCard(
                  context,
                  theme,
                  'Data Penerbangan',
                  Icons.flight,
                  () => context.go('/data-penerbangan'),
                  isFilled: dataPenerbanganFilled,
                  sourcePage: '/data-penerbangan',
                ),
                const SizedBox(height: 16),
                _buildNavigationCard(
                  context,
                  theme,
                  'Data Kesehatan',
                  Icons.health_and_safety,
                  () => context.go('/data-kesehatan'),
                  isFilled: dataKesehatanFilled,
                  sourcePage: '/data-kesehatan',
                ),
                const SizedBox(height: 16),
                _buildNavigationCard(
                  context,
                  theme,
                  'Data Kontak',
                  Icons.contact_phone,
                  () => context.go('/data-kontak'),
                  isFilled: dataKontakFilled,
                  sourcePage: '/data-kontak',
                ),
                const SizedBox(height: 16),
                _buildNavigationCard(
                  context,
                  theme,
                  'Data Tata Naskah',
                  Icons.description,
                  () => context.go('/data-tata-naskah'),
                  isFilled: dataTataNaskahFilled,
                  sourcePage: '/data-tata-naskah',
                ),
                const SizedBox(height: 16),
                _buildNavigationCard(
                  context,
                  theme,
                  'Data Feedback Komisi',
                  Icons.feedback,
                  () => context.go('/data-feedback-komisi'),
                  isFilled: dataFeedbackKomisiFilled,
                  sourcePage: '/data-feedback-komisi',
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final allFilled = dataPribadiFilled &&
                            dataFeedbackKomisiFilled &&
                            dataKeanggotaanFilled &&
                            dataKendaraanFilled &&
                            dataPenerbanganFilled &&
                            dataKesehatanFilled &&
                            dataKontakFilled &&
                            dataTataNaskahFilled;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(allFilled ? 'Semua data berhasil disimpan!' : 'Harap lengkapi semua data terlebih dahulu!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primarySwatch,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    dynamic theme,
    String title,
    IconData icon,
    VoidCallback onTap, {
    required bool isFilled,
    required String sourcePage,
  }) {
    print('Building NavigationCard for $title - isFilled: $isFilled, dataPribadiFilled: ${ref.read(dataPribadiFilledProvider)}');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primarySwatch, theme.secondarySwatch],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (_showSavedMessage[sourcePage] == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Data Tersimpan',
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isFilled)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}