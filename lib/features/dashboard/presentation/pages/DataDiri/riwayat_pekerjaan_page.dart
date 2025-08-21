import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart'; // Assuming this path is correct
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';

// Work History data model
class WorkHistoryData {
  final String id;
  final String position;
  final String company;
  final String startYear;
  final String endYear;

  WorkHistoryData({
    required this.id,
    required this.position,
    required this.company,
    required this.startYear,
    required this.endYear,
  });

  // Helper to create a copy with new values (useful for editing)
  WorkHistoryData copyWith({
    String? id,
    String? position,
    String? company,
    String? startYear,
    String? endYear,
  }) {
    return WorkHistoryData(
      id: id ?? this.id,
      position: position ?? this.position,
      company: company ?? this.company,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
    );
  }
}

// Provider with work history data
final workHistoryDataProvider = StateProvider<List<WorkHistoryData>>((ref) {
  return [
    WorkHistoryData(
      id: 'wh1',
      position: 'PROGRAMMER',
      company: 'PT INSIGHT SYSTEM',
      startYear: '2006',
      endYear: '2009',
    ),
  ];
});

class WorkHistoryPage extends ConsumerStatefulWidget {
  const WorkHistoryPage({super.key});

  @override
  ConsumerState<WorkHistoryPage> createState() => _AddWorkHistoryPageState();
}

class _AddWorkHistoryPageState extends ConsumerState<WorkHistoryPage> {
  final TextEditingController _searchController = TextEditingController();

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
    final workHistoryData = ref.watch(workHistoryDataProvider);

    // Filter work history data based on search
    final filteredData =
        workHistoryData.where((work) {
          final searchTerm = _searchController.text.toLowerCase();
          if (searchTerm.isEmpty) return true;

          return work.position.toLowerCase().contains(searchTerm) ||
              work.company.toLowerCase().contains(searchTerm);
        }).toList();

    // Check if there are active filters
    final hasActiveFilters = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Data Riwayat Pekerjaan',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go("/home"); // Adjust this route as needed
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
              labelText: 'Pencarian Riwayat Pekerjaan',
              hintText: 'Cari berdasarkan posisi atau perusahaan...',
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

            // Note Section (Optional, similar to education page)
            _buildNoteSection(theme),
            const SizedBox(height: 20),

            // Add Work History Button
            _buildAddWorkHistoryButton(theme),
            const SizedBox(height: 20),

            // Work History Data Table
            _buildWorkHistoryTable(theme, filteredData),

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
                  'Wajib menambahkan Riwayat Pekerjaan Terakhir',
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

  Widget _buildAddWorkHistoryButton(dynamic theme) {
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
                'Tambah Riwayat Pekerjaan',
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
              onPressed: _addWorkHistory,
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
                'TAMBAH RIWAYAT PEKERJAAN',
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

  Widget _buildWorkHistoryTable(
    dynamic theme,
    List<WorkHistoryData> workHistoryData,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  Icons.business_center, // Icon for work history
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Riwayat Pekerjaan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primarySwatch.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${workHistoryData.length} data',
                  style: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: theme.primarySwatch,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (workHistoryData.isEmpty)
            _buildEmptyState(theme)
          else
            Column(
              children: [
                for (final work in workHistoryData) _buildWorkCard(theme, work),
              ],
            ),
        ],
      ),
    );
  }

  // Small rounded "pill" chip used in cards
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

  Widget _buildWorkCard(dynamic theme, WorkHistoryData work) {
    final stripeColor = theme.primarySwatch;
    return AppCard(
      leftAccentColor: stripeColor,
      gradient: LinearGradient(
        colors: [Colors.white, Colors.grey[50]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stripeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.business_center, color: stripeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(work.position, style: theme.typographyBold.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${work.id}',
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pillChip(
                icon: Icons.business,
                label: work.company,
                theme: theme,
              ),
              _pillChip(
                icon: Icons.calendar_today,
                label: '${work.startYear} - ${work.endYear}',
                theme: theme,
              ),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Edit',
                icon: Icon(Icons.edit, color: theme.primarySwatch),
                onPressed: () => _editWorkHistory(work),
              ),
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteWorkHistory(work),
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
            Icon(Icons.work_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada data riwayat pekerjaan',
              style: theme.typographyRegular.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan riwayat pekerjaan dengan menekan tombol di atas',
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

  void _addWorkHistory() {
    context.go(
      '/add-riwayat-pekerjaan',
    ); // Navigate to a form for adding new work history
  }

  void _editWorkHistory(WorkHistoryData work) {
    // Navigate to edit page, passing the data
    context.go('/edit-riwayat-pekerjaan', extra: work);
  }

  void _deleteWorkHistory(WorkHistoryData work) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Data Riwayat Pekerjaan'),
            content: Text(
              'Apakah Anda yakin ingin menghapus data ${work.position} - ${work.company}?',
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
                    final currentData = ref.read(workHistoryDataProvider);
                    final updatedData =
                        currentData.where((e) => e.id != work.id).toList();
                    ref.read(workHistoryDataProvider.notifier).state =
                        updatedData;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Data ${work.position} berhasil dihapus'),
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
