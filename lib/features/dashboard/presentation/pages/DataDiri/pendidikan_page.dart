import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
// import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
// No shared education file; this page manages its own local state.

class PendidikanPage extends ConsumerStatefulWidget {
  const PendidikanPage({super.key});

  @override
  ConsumerState<PendidikanPage> createState() => _PendidikanPageState();
}

class _PendidikanPageState extends ConsumerState<PendidikanPage> {
  final TextEditingController _searchController = TextEditingController();
  // Local in-memory list of pendidikan entries
  final List<Map<String, String>> _educationData = [
    {
      'id': 'edu-1',
      'jenjang': 'Sarjana/S1',
      'jurusan': 'ILMU KOMPUTER',
      'institusi': 'UNIVERSITAS CONTOH INDONESIA',
      'kota': 'JAKARTA',
      'tahun': '2016 - 2020',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final educationData = _educationData;

    // Real-time Indonesian time (UTC+7)
    // final currentTime = DateTime.now().toUtc().add(const Duration(hours: 7));

    // Filter education data based on search
    final filteredData =
        educationData.where((e) {
          final searchTerm = _searchController.text.toLowerCase();
          if (searchTerm.isEmpty) return true;

          return (e['jenjang'] ?? '').toLowerCase().contains(searchTerm) ||
              (e['jurusan'] ?? '').toLowerCase().contains(searchTerm) ||
              (e['institusi'] ?? '').toLowerCase().contains(searchTerm) ||
              (e['kota'] ?? '').toLowerCase().contains(searchTerm);
        }).toList();

    // Check if there are active filters
    final hasActiveFilters = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Data Pendidikan',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        // --- Tambahkan ini untuk tombol panah kembali ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go("/home");
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 16.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search + Filter using AppFilterBar
            AppFilterBar(
              controller: _searchController,
              labelText: 'Pencarian Data Pendidikan',
              hintText:
                  'Cari berdasarkan jenjang, jurusan, institusi, atau kota...',
              onChanged: (value) => setState(() {}),
              onClear: () => setState(() {}),
              headerTitle: 'Pencarian',
              hasActiveFilters: hasActiveFilters,
              onReset:
                  hasActiveFilters
                      ? () {
                        _searchController.clear();
                        setState(() {});
                      }
                      : null,
            ),
            const SizedBox(height: 20),

            // Note Section
            _buildNoteSection(theme),
            const SizedBox(height: 20),

            // Add Education Button
            _buildAddEducationButton(theme),
            const SizedBox(height: 20),

            // Education Data Cards (replaces table)
            _buildEducationCards(theme, filteredData, isTablet),

            const SizedBox(height: 20), // Bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keterangan',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Wajib menambahkan Riwayat Pendidikan Terakhir',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEducationButton(dynamic theme) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primarySwatch, theme.secondarySwatch],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tambah Riwayat Pendidikan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addEducation,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primarySwatch,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.add_circle, size: 20),
              label: Text(
                'TAMBAH RIWAYAT PENDIDIKAN',
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
  }

  Widget _buildEducationCards(
    dynamic theme,
    List<Map<String, String>> educationData,
    bool isTablet,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primarySwatch, theme.secondarySwatch],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Riwayat Pendidikan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: theme.primarySwatch.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: theme.primarySwatch,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${educationData.length} data',
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: theme.primarySwatch,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (educationData.isEmpty)
            _buildEmptyState(theme)
          else
            Column(
              children:
                  educationData
                      .map((e) => _buildEducationCard(theme, e))
                      .toList(),
            ),
        ],
      ),
    );
  }

  // Helper for pill chips like in WorkHistory
  Widget _pillChip({
    required IconData icon,
    required String label,
    required dynamic theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.primarySwatch),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: theme.typographyRegular.bodyExtraSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // New card UI matching WorkHistory style
  Widget _buildEducationCard(dynamic theme, Map<String, String> e) {
    final jenjang = (e['jenjang'] ?? '').trim();
    final jurusan = (e['jurusan'] ?? '').trim();
    final institusi = (e['institusi'] ?? '').trim();
    final kota = (e['kota'] ?? '').trim();

    // Use the formatted tahun field if available, or format the individual years
    String tahun;
    if (e['tahun'] != null && e['tahun']!.isNotEmpty) {
      tahun = e['tahun']!;
    } else if (e['tahun_mulai'] != null && e['tahun_selesai'] != null) {
      tahun = '${e['tahun_mulai']} - ${e['tahun_selesai']}';
    } else {
      tahun = '-';
    }

    final jenjangColor = _getJenjangColor(jenjang);

    return AppCard(
      leftAccentColor: jenjangColor,
      gradient: LinearGradient(
        colors: [Colors.white, Colors.grey[50]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with jenjang icon and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: jenjangColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.school, color: jenjangColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jurusan.isEmpty ? '-' : jurusan,
                      style: theme.typographyBold.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      institusi.isEmpty ? '-' : institusi,
                      style: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Jenjang chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: jenjangColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  jenjang.isEmpty ? '-' : jenjang,
                  style: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: jenjangColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Information pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pillChip(
                icon: Icons.location_on,
                label: kota.isEmpty ? '-' : kota,
                theme: theme,
              ),
              _pillChip(icon: Icons.calendar_today, label: tahun, theme: theme),
            ],
          ),

          const SizedBox(height: 12),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Edit',
                icon: Icon(Icons.edit, color: theme.primarySwatch),
                onPressed: () => _editEducation(e),
              ),
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteEducation(e),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(dynamic theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada data pendidikan',
              style: theme.typographyRegular.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan riwayat pendidikan dengan menekan tombol di atas',
              style: theme.typographyRegular.bodySmall.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getJenjangColor(String jenjang) {
    switch (jenjang.toLowerCase()) {
      case 'sd':
        return Colors.green;
      case 'smp':
        return Colors.blue;
      case 'sma':
      case 'smk':
        return Colors.orange;
      case 'diploma':
      case 'd1':
      case 'd2':
      case 'd3':
      case 'd4':
        return Colors.purple;
      case 's1':
      case 'sarjana':
      case 'sarjana/s1':
        return Colors.indigo;
      case 's2':
      case 'magister':
        return Colors.red;
      case 's3':
      case 'doktor':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Future<void> _addEducation() async {
    final result = await context.pushNamed(Routes.addDataPendidikan.name);
    if (!mounted) return;
    if (result is Map && result['action'] == 'add' && result['data'] is Map) {
      setState(() {
        _educationData.add(Map<String, String>.from(result['data'] as Map));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pendidikan berhasil disimpan'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _editEducation(Map<String, String> education) async {
    final result = await context.pushNamed(
      Routes.editDataPendidikan.name,
      extra: education,
    );
    if (!mounted) return;
    if (result is Map && result['action'] == 'edit' && result['data'] is Map) {
      final updated = Map<String, String>.from(result['data'] as Map);
      setState(() {
        final idx = _educationData.indexWhere((e) => e['id'] == updated['id']);
        if (idx != -1) _educationData[idx] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pendidikan berhasil diperbarui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteEducation(Map<String, String> education) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Data Pendidikan'),
            content: Text(
              'Apakah Anda yakin ingin menghapus data ${education['jenjang']} - ${education['jurusan']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _educationData.removeWhere(
                        (e) => e['id'] == education['id'],
                      );
                    });
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Data ${education['jenjang']} berhasil dihapus',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
