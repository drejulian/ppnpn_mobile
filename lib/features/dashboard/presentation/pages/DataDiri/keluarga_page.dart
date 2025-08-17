import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';

// Family member data model
class FamilyMember {
  final String id;
  final String nama;
  final String hubungan;
  final String tempatLahir;
  final DateTime tanggalLahir;
  final String jenisKelamin;
  final String pekerjaan;
  final DateTime? tanggalMenikah;

  FamilyMember({
    required this.id,
    required this.nama,
    required this.hubungan,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.pekerjaan,
    this.tanggalMenikah,
  });
}

// Provider with updated family data
final familyDataProvider = StateProvider<List<FamilyMember>>((ref) {
  return [
    FamilyMember(
      id: '1',
      nama: 'RENI GUMILA DEWI',
      hubungan: 'ISTRI',
      tempatLahir: 'Jakarta',
      tanggalLahir: DateTime(1982, 9, 4),
      jenisKelamin: 'Perempuan',
      pekerjaan: 'IBU RUMAH TANGGA',
      tanggalMenikah: DateTime(2008, 12, 14),
    ),
    FamilyMember(
      id: '2',
      nama: 'ARVIE PRAMATYA ALGHANI',
      hubungan: 'AK',
      tempatLahir: 'Jakarta',
      tanggalLahir: DateTime(1998, 9, 25),
      jenisKelamin: 'Laki-laki',
      pekerjaan: 'Pelajar',
    ),
    FamilyMember(
      id: '3',
      nama: 'DYLAN PRADIPTA ALGHANI',
      hubungan: 'AK',
      tempatLahir: 'Jakarta',
      tanggalLahir: DateTime(2011, 7, 7),
      jenisKelamin: 'Laki-laki',
      pekerjaan: 'Pelajar',
    ),
    FamilyMember(
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

class KeluargaPage extends ConsumerStatefulWidget {
  const KeluargaPage({super.key});

  @override
  ConsumerState<KeluargaPage> createState() => _KeluargaPageState();
}

class _KeluargaPageState extends ConsumerState<KeluargaPage> {
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
    final familyMembers = ref.watch(familyDataProvider);

    // Real-time Indonesian time (UTC+7)
    final currentTime = DateTime.now().toUtc().add(const Duration(hours: 7));

    // Filter family members based on search
    final filteredMembers =
        familyMembers.where((member) {
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
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
            // Header Info
            _buildHeaderInfo(theme, currentTime, familyMembers.length),
            const SizedBox(height: 20),

            // Search Section
            _buildSearchSection(theme),
            const SizedBox(height: 20),

            // Add Family Member Button
            _buildAddFamilyButton(theme),
            const SizedBox(height: 20),

            // Family Data Cards
            _buildFamilyCards(theme, filteredMembers),

            const SizedBox(height: 20), // Bottom spacing
          ],
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
            color: theme.primarySwatch.withOpacity(0.3),
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

  Widget _buildFamilyCards(dynamic theme, List<FamilyMember> members) {
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
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ],
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

  Widget _buildSimpleCardsList(dynamic theme, List<FamilyMember> members) {
    return Column(
      children:
          members
              .map((member) => _buildSimpleMemberCard(theme, member))
              .toList(),
    );
  }

  Widget _buildSimpleMemberCard(dynamic theme, FamilyMember member) {
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  void _editFamilyMember(FamilyMember member) {
    context.go('/edit-data-keluarga/${member.id}');
  }

  void _viewMemberDetail(FamilyMember member) {
    context.go('/detail-data-keluarga/${member.id}');
  }

  void _deleteFamilyMember(FamilyMember member) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Anggota Keluarga'),
            content: Text(
              'Apakah Anda yakin ingin menghapus data ${member.nama}?',
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
                    final currentData = ref.read(familyDataProvider);
                    final updatedData =
                        currentData.where((m) => m.id != member.id).toList();
                    ref.read(familyDataProvider.notifier).state = updatedData;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Data ${member.nama} berhasil dihapus'),
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
