import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart';
import 'package:ppnpm_dpr/features/dashboard/data/services/keluarga_api.dart';
import 'package:ppnpm_dpr/features/dashboard/data/models/family_member.dart'
    as dto;
import 'providers/profile_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final familyDataProvider = StateProvider<List<dto.FamilyMemberDto>>((ref) {
  return [
    dto.FamilyMemberDto(
      id: '1',
      nama: 'RENI GUMILA DEWI',
      hubungan: 'ISTRI',
      tempatLahir: 'Jakarta',
      tanggalLahir: DateTime(1982, 9, 4),
      jenisKelamin: 'Perempuan',
      pekerjaan: 'IBU RUMAH TANGGA',
      tanggalMenikah: DateTime(2008, 12, 14),
    ),
    dto.FamilyMemberDto(
      id: '2',
      nama: 'ARVIE PRAMATYA ALGHANI',
      hubungan: 'AK',
      tempatLahir: 'Jakarta',
      tanggalLahir: DateTime(1998, 9, 25),
      jenisKelamin: 'Laki-laki',
      pekerjaan: 'Pelajar',
    ),
    dto.FamilyMemberDto(
      id: '3',
      nama: 'DYLAN PRADIPTA ALGHANI',
      hubungan: 'AK',
      tempatLahir: 'Jakarta',
      tanggalLahir: DateTime(2011, 7, 7),
      jenisKelamin: 'Laki-laki',
      pekerjaan: 'Pelajar',
    ),
    dto.FamilyMemberDto(
      id: '4',
      nama: 'nadine rafarindya alghani',
      hubungan: 'AK',
      tempatLahir: 'Jakarta',
      tanggalLahir: DateTime(2016, 2, 25),
      jenisKelamin: 'Perempuan',
      pekerjaan: 'belum/Tidak bekerja',
    ),
  ];
});

// Remote provider directly uses API; keep simple and composable
final keluargaRemoteProvider =
    FutureProvider.autoDispose<List<dto.FamilyMemberDto>>((ref) async {
      final api = ref.read(keluargaApiProvider);
      return api.fetchMembers();
    });

class KeluargaPage extends ConsumerStatefulWidget {
  const KeluargaPage({super.key});

  @override
  ConsumerState<KeluargaPage> createState() => _KeluargaPageState();
}

class _KeluargaPageState extends ConsumerState<KeluargaPage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _searchQuery = '';
  
  // Store original data for change detection
  late List<dto.FamilyMemberDto> _originalFamilyData;
  bool _hasLoadedInitialData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load initial data for change detection
    if (!_hasLoadedInitialData) {
      final remote = ref.read(keluargaRemoteProvider);
      _originalFamilyData = List.from(remote.asData?.value ?? ref.read(familyDataProvider));
      _hasLoadedInitialData = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Check if there are unsaved changes
  bool _hasUnsavedChanges() {
    final remote = ref.read(keluargaRemoteProvider);
    final currentFamilyData = remote.asData?.value ?? ref.read(familyDataProvider);
    
    // Ensure we have valid data to compare
    if (currentFamilyData == null) {
      print('=== CHECKING KELUARGA UNSAVED CHANGES ===');
      print('Current family data is null, no changes detected');
      print('Has changes: false');
      print('==========================================');
      return false;
    }
    
    // Debug print untuk melihat perbandingan data
    print('=== CHECKING KELUARGA UNSAVED CHANGES ===');
    print('Original data count: ${_originalFamilyData.length}');
    print('Current data count: ${currentFamilyData.length}');
    
    // Compare family data lists
    if (_originalFamilyData.length != currentFamilyData.length) {
      print('Different length detected');
      print('Has changes: true');
      print('==========================================');
      return true;
    }
    
    // Check each member for changes
    for (int i = 0; i < _originalFamilyData.length; i++) {
      final original = _originalFamilyData[i];
      final current = currentFamilyData[i];
      
      if (original.id != current.id ||
          original.nama.trim() != current.nama.trim() ||
          original.hubungan != current.hubungan ||
          original.tempatLahir.trim() != current.tempatLahir.trim() ||
          original.tanggalLahir != current.tanggalLahir ||
          original.jenisKelamin != current.jenisKelamin ||
          original.pekerjaan.trim() != current.pekerjaan.trim() ||
          original.tanggalMenikah != current.tanggalMenikah) {
        
        print('Changes detected in member ${original.nama}:');
        print('  Nama: "${original.nama}" vs "${current.nama}"');
        print('  Hubungan: "${original.hubungan}" vs "${current.hubungan}"');
        print('  Pekerjaan: "${original.pekerjaan}" vs "${current.pekerjaan}"');
        print('Has changes: true');
        print('==========================================');
        return true;
      }
    }
    
    print('No changes detected');
    print('Has changes: false');
    print('==========================================');
    return false;
  }

  // Show unsaved changes dialog
  Future<bool> _showUnsavedChangesDialog(BuildContext context, dynamic theme) async {
    final result = await NotificationUtils.showConfirmationDialog(
      context,
      title: 'Perubahan Belum Disimpan',
      message: 'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
      confirmButtonText: 'Keluar Tanpa Menyimpan',
      cancelButtonText: 'Batal',
      icon: Icons.warning_amber_rounded,
      isDangerous: true,
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    // Prefer remote API; fallback to local state
    final remote = ref.watch(keluargaRemoteProvider);
    List<dto.FamilyMemberDto> allFamilyMembers = remote.asData?.value ?? ref.watch(familyDataProvider);
    
    // Real-time Indonesian time (UTC+7)
    final currentTime = DateTime.now().toUtc().add(const Duration(hours: 7));

    // Filter family members based on search
    final filteredMembers =
        allFamilyMembers.where((member) {
          return member.nama.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              member.hubungan.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              member.pekerjaan.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
        }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Data Keluarga',
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
          onPressed: () async {
            // Check if there are unsaved changes
            if (_hasUnsavedChanges()) {
              final shouldLeave = await _showUnsavedChangesDialog(context, theme);
              if (shouldLeave) {
                // Safe navigation back
                if (Navigator.canPop(context)) {
                  Navigator.pop(context, false);
                } else {
                  context.go('/profile-sections');
                }
              }
            } else {
              if (Navigator.canPop(context)) {
                Navigator.pop(context, false);
              } else {
                context.go('/profile-sections');
              }
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 16.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              _buildHeaderInfo(theme, currentTime, allFamilyMembers.length),
              const SizedBox(height: 20),

              // Search Section
              _buildSearchSection(theme),
              const SizedBox(height: 20),

              // Add Family Member Button
              _buildAddFamilyButton(theme),
              const SizedBox(height: 20),

              // Loading/Error banners
              if (remote.isLoading) const LinearProgressIndicator(minHeight: 2),
              if (remote.hasError)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Gagal memuat data dari server. Menampilkan data lokal.',
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        color: Colors.orange,
                        onPressed: () => ref.invalidate(keluargaRemoteProvider),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Family Data Cards with dummy data filtering
              FutureBuilder<bool>(
                future: SharedPreferences.getInstance().then((prefs) => prefs.getBool('family_user_saved') ?? false),
                builder: (context, snapshot) {
                  final familyUserSaved = snapshot.data ?? false;
                  List<dto.FamilyMemberDto> displayMembers = filteredMembers;
                  
                  print('=== FAMILY DATA DISPLAY FILTER ===');
                  print('familyUserSaved: $familyUserSaved');
                  print('All filtered members: ${filteredMembers.length}');
                  
                  // Jika user belum pernah save, filter dummy data
                  if (!familyUserSaved) {
                    displayMembers = filteredMembers.where((member) {
                      bool isDummy = member.nama.contains('RENI GUMILA') || 
                                   member.nama.contains('ARVIE PRAMATYA') ||
                                   member.nama.contains('DYLAN PRADIPTA') ||
                                   member.nama.contains('nadine rafarindya');
                      return !isDummy;
                    }).toList();
                    print('User has not saved - filtered to ${displayMembers.length} non-dummy members');
                  } else {
                    print('User has saved - showing all ${displayMembers.length} members');
                  }
                  
                  return _buildFamilyCards(theme, displayMembers);
                },
              ),

              const SizedBox(height: 30),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    print('=== SAVE BUTTON CLICKED ===');
                    _saveData(context, theme);
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

              const SizedBox(height: 20), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(
    dynamic theme,
    DateTime currentTime,
    int totalMembers,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primarySwatch, theme.secondarySwatch],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.primarySwatch.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.family_restroom,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Keluarga',
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Airlangga Eka Wardhana (miftahul01)',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(currentTime),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${DateFormat('HH:mm').format(currentTime)} WIB',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  '$totalMembers Anggota Keluarga',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Aktif',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                'Pencarian Data Keluarga',
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
              hintText: 'Cari berdasarkan nama, hubungan, atau pekerjaan...',
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

  Widget _buildAddFamilyButton(dynamic theme) {
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
                  Icons.person_add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tambah Anggota Keluarga',
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
              onPressed: _addFamilyMember,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primarySwatch,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.person_add, size: 20),
              label: Text(
                'TAMBAH ANGGOTA KELUARGA',
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

  Widget _buildFamilyCards(dynamic theme, List<dto.FamilyMemberDto> members) {
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
                child: const Icon(Icons.people, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Daftar Anggota Keluarga',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.primarySwatch.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${members.length} orang',
                style: theme.typographyRegular.bodyExtraSmall.copyWith(
                  color: theme.primarySwatch,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (members.isEmpty)
            _buildEmptyState(theme)
          else
            _buildSimpleCardsList(theme, members),
        ],
      ),
    );
  }

  Widget _buildSimpleCardsList(
    dynamic theme,
    List<dto.FamilyMemberDto> members,
  ) {
    return Column(
      children:
          members
              .map((member) => _buildSimpleMemberCard(theme, member))
              .toList(),
    );
  }

  Widget _buildSimpleMemberCard(dynamic theme, dto.FamilyMemberDto member) {
    return GestureDetector(
      onTap: () => _viewMemberDetail(member),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with relationship icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getHubunganColor(member.hubungan),
                    _getHubunganColor(member.hubungan).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _getHubunganIcon(member.hubungan),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Name and relationship
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.nama,
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getHubunganColor(
                        member.hubungan,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getHubunganLabel(member.hubungan),
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: _getHubunganColor(member.hubungan),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            ),
          ],
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
            Icon(Icons.family_restroom, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada data keluarga',
              style: theme.typographyRegular.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan anggota keluarga dengan menekan tombol di atas',
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

  Color _getHubunganColor(String hubungan) {
    switch (hubungan.toLowerCase()) {
      case 'istri':
      case 'suami':
        return Colors.pink;
      case 'ak':
      case 'anak':
        return Colors.orange;
      case 'ayah':
        return Colors.blue;
      case 'ibu':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getHubunganIcon(String hubungan) {
    switch (hubungan.toLowerCase()) {
      case 'istri':
        return Icons.woman;
      case 'suami':
        return Icons.man;
      case 'ak':
      case 'anak':
        return Icons.child_care;
      case 'ayah':
        return Icons.man_2;
      case 'ibu':
        return Icons.woman_2;
      default:
        return Icons.person;
    }
  }

  String _getHubunganLabel(String hubungan) {
    switch (hubungan.toUpperCase()) {
      case 'ISTRI':
        return 'Istri';
      case 'AK':
        return 'Anak';
      case 'AYAH':
        return 'Ayah';
      case 'IBU':
        return 'Ibu';
      default:
        return hubungan;
    }
  }

  void _addFamilyMember() {
    context.go('/add-data-keluarga');
  }

  Future<void> _saveFamilyUserFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('family_user_saved', true);
      print('Family user saved flag set to true');
    } catch (e) {
      print('Error saving family user flag: $e');
    }
  }

  void _saveData(BuildContext context, dynamic theme) {
    if (_formKey.currentState!.validate()) {
      // Get current family data from the list
      final familyList = ref.read(familyDataProvider);
      
      // Convert family list to KeluargaData format for the global provider
      String namaAyah = '';
      String namaIbu = '';
      String namaPasangan = '';
      String namaAnak = '';
      String pekerjaanAyah = '';
      String pekerjaanIbu = '';
      String pekerjaanPasangan = '';
      
      for (final member in familyList) {
        switch (member.hubungan) {
          case 'AYAH':
            namaAyah = member.nama;
            pekerjaanAyah = member.pekerjaan;
            break;
          case 'IBU':
            namaIbu = member.nama;
            pekerjaanIbu = member.pekerjaan;
            break;
          case 'ISTRI':
          case 'SUAMI':
            namaPasangan = member.nama;
            pekerjaanPasangan = member.pekerjaan;
            break;
          case 'AK': // Anak
            if (namaAnak.isEmpty) {
              namaAnak = member.nama;
            } else {
              namaAnak += ', ${member.nama}';
            }
            break;
        }
      }
      
      // Save to global provider
      final keluargaData = KeluargaData(
        namaAyah: namaAyah,
        namaIbu: namaIbu,
        namaPasangan: namaPasangan,
        namaAnak: namaAnak,
        pekerjaanAyah: pekerjaanAyah,
        pekerjaanIbu: pekerjaanIbu,
        pekerjaanPasangan: pekerjaanPasangan,
      );
      
      ref.read(keluargaDataProvider.notifier).updateData(keluargaData);
      
      // Set flag bahwa user telah menyimpan data keluarga
      _saveFamilyUserFlag();
      
      print('=== SAVED KELUARGA DATA ===');
      print('Ayah: $namaAyah - $pekerjaanAyah');
      print('Ibu: $namaIbu - $pekerjaanIbu');
      print('Pasangan: $namaPasangan - $pekerjaanPasangan');
      print('Anak: $namaAnak');
      print('============================');

      // Show immediate feedback with SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Data keluarga berhasil disimpan'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      print('=== SHOWING SUCCESS DIALOG ===');
      // Show success dialog with delay to ensure SnackBar is visible first
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && context.mounted) {
          NotificationUtils.showSuccessDialog(
            context,
            title: 'Simpan Data Keluarga',
            message: 'Data keluarga berhasil disimpan.',
            onPressed: () {
              print('=== SUCCESS DIALOG BUTTON PRESSED ===');
              
              // Safe navigation back to previous page
              if (Navigator.canPop(context)) {
                print('Using Navigator.pop');
                Navigator.pop(context, 'saved');
              } else {
                print('Using context.go');
                context.go('/profile-sections');
              }
            },
          );
          print('=== SUCCESS DIALOG COMPLETED ===');
        } else {
          print('=== CONTEXT NOT MOUNTED, SKIPPING DIALOG ===');
        }
      });
    }
  }

  void _viewMemberDetail(dto.FamilyMemberDto member) {
    context.go('/detail-data-keluarga/${member.id}');
  }
}
