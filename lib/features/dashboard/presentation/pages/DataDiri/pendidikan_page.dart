import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';

// Education data model
class EducationData {
  final String id;
  final String jenjang;
  final String jurusan;
  final String institusi;
  final String kota;
  final String tahun;

  EducationData({
    required this.id,
    required this.jenjang,
    required this.jurusan,
    required this.institusi,
    required this.kota,
    required this.tahun,
  });
}

// Provider with education data
final educationDataProvider = StateProvider<List<EducationData>>((ref) {
  return [
    EducationData(
      id: '1',
      jenjang: 'Sarjana/S1',
      jurusan: 'TEKNIK INFORMATIKA',
      institusi: 'INSTITUT TEKNOLOGI SEPULUH NOPEMBER (ITSI)',
      kota: 'SURABAYA',
      tahun: '2004',
    ),
  ];
});

class PendidikanPage extends ConsumerStatefulWidget {
  const PendidikanPage({super.key});

  @override
  ConsumerState<PendidikanPage> createState() => _PendidikanPageState();
}

class _PendidikanPageState extends ConsumerState<PendidikanPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    final educationData = ref.watch(educationDataProvider);

    // Real-time Indonesian time (UTC+7)
    final currentTime = DateTime.now().toUtc().add(const Duration(hours: 7));

    // Filter education data based on search
    final filteredData =
        educationData.where((education) {
          return education.jenjang.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              education.jurusan.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              education.institusi.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              education.kota.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

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
            // Search Section
            _buildSearchSection(theme),
            const SizedBox(height: 20),

            // Note Section
            _buildNoteSection(theme),
            const SizedBox(height: 20),

            // Add Education Button
            _buildAddEducationButton(theme),
            const SizedBox(height: 20),

            // Education Data Table
            _buildEducationTable(theme, filteredData, isTablet),

            const SizedBox(height: 20), // Bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(dynamic theme) {
    return Container(
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
                child: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Pencarian Data Pendidikan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText:
                  'Cari berdasarkan jenjang, jurusan, institusi, atau kota...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear),
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.primarySwatch),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
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

  Widget _buildEducationTable(
    dynamic theme,
    List<EducationData> educationData,
    bool isTablet,
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
                  Icons.table_chart,
                  color: Colors.white,
                  size: 20,
                ),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primarySwatch.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${educationData.length} data',
                  style: theme.typographyRegular.bodyExtraSmall.copyWith(
                    color: theme.primarySwatch,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (educationData.isEmpty)
            _buildEmptyState(theme)
          else
            _buildDataTable(theme, educationData),
        ],
      ),
    );
  }

  Widget _buildDataTable(dynamic theme, List<EducationData> educationData) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
          dataRowMinHeight: 60,
          dataRowMaxHeight: 80,
          columnSpacing: 20,
          dividerThickness: 1,
          border: TableBorder.all(color: Colors.grey[300]!, width: 1),
          columns: [
            DataColumn(
              label: Text(
                'Jenjang',
                style: theme.typographyRegular.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Jurusan',
                style: theme.typographyRegular.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Institusi',
                style: theme.typographyRegular.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Kota',
                style: theme.typographyRegular.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Tahun',
                style: theme.typographyRegular.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Aksi',
                style: theme.typographyRegular.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
          rows:
              educationData
                  .map(
                    (education) => DataRow(
                      cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getJenjangColor(
                                education.jenjang,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              education.jenjang,
                              style: theme.typographyRegular.bodyExtraSmall
                                  .copyWith(
                                    color: _getJenjangColor(education.jenjang),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              education.jurusan,
                              style: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              education.institusi,
                              style: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            education.kota,
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              education.tahun,
                              style: theme.typographyRegular.bodyExtraSmall
                                  .copyWith(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _editEducation(education),
                                icon: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.blue[600],
                                ),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                onPressed: () => _deleteEducation(education),
                                icon: Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red[600],
                                ),
                                tooltip: 'Hapus',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
        ),
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

  void _addEducation() {
    context.go('/add-data-pendidikan');
  }

  void _editEducation(EducationData education) {
    context.go('/add-data-pendidikan');
  }

  void _deleteEducation(EducationData education) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Data Pendidikan'),
            content: Text(
              'Apakah Anda yakin ingin menghapus data ${education.jenjang} - ${education.jurusan}?',
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
                    final currentData = ref.read(educationDataProvider);
                    final updatedData =
                        currentData.where((e) => e.id != education.id).toList();
                    ref.read(educationDataProvider.notifier).state =
                        updatedData;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Data ${education.jenjang} berhasil dihapus',
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

  void _saveData() {
    final educationData = ref.read(educationDataProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data pendidikan untuk user miftahul01 berhasil disimpan (${educationData.length} data)',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}