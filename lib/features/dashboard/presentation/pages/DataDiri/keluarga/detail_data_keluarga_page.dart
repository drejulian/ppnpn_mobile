import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/keluarga_page.dart';
import 'package:ppnpm_dpr/features/dashboard/data/services/keluarga_api.dart';
import 'package:ppnpm_dpr/features/dashboard/data/models/family_member.dart'
    as dto;

// Remote provider to fetch a member by ID
final keluargaMemberProvider = FutureProvider.autoDispose
    .family<dto.FamilyMemberDto, String>(
      (ref, id) => ref.read(keluargaApiProvider).getMember(id),
    );

class DetailDataKeluargaPage extends ConsumerWidget {
  final String memberId;

  const DetailDataKeluargaPage({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final remote = ref.watch(keluargaMemberProvider(memberId));
    // Fallback to local list when remote not available
    final localList = ref.watch(familyDataProvider);
    dto.FamilyMemberDto? member = remote.asData?.value;
    if (member == null) {
      for (final m in localList) {
        if (m.id == memberId) {
          member = m;
          break;
        }
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Detail Anggota Keluarga',
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
              context.go('/keluarga');
            }
          },
        ),
        actions: [
          IconButton(
            onPressed:
                member == null
                    ? null
                    : () {
                      final m = member;
                      if (m != null) _editFamilyMember(context, m);
                    },
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Edit Data',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'delete') {
                if (member != null) {
                  _deleteFamilyMember(context, ref, member);
                }
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Hapus Data'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 16.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (remote.isLoading) const LinearProgressIndicator(minHeight: 2),
            if (remote.hasError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gagal memuat detail dari server. Menampilkan data lokal bila tersedia.',
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          () =>
                              ref.invalidate(keluargaMemberProvider(memberId)),
                      icon: const Icon(Icons.refresh, color: Colors.orange),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            if (member == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Data tidak ditemukan.',
                    style: theme.typographyRegular.bodyMedium,
                  ),
                ),
              )
            else ...[
              // Profile Header
              _buildProfileHeader(theme, member),
              const SizedBox(height: 20),

              // Personal Information
              _buildPersonalInfoSection(theme, member),
              const SizedBox(height: 20),

              // Family Information
              _buildFamilyInfoSection(theme, member),
              const SizedBox(height: 20),

              // Additional Information
              if (member.tanggalMenikah != null)
                _buildMarriageInfoSection(theme, member),

              const SizedBox(height: 20),

              // Action Buttons
              _buildActionButtons(theme, context, ref, member),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic theme, dto.FamilyMemberDto member) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getHubunganColor(member.hubungan),
            _getHubunganColor(member.hubungan).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getHubunganColor(member.hubungan).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Large Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Icon(
              _getHubunganIcon(member.hubungan),
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            member.nama,
            style: theme.typographyRegular.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Relationship Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              _getHubunganLabel(member.hubungan),
              style: theme.typographyRegular.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(dynamic theme, dto.FamilyMemberDto member) {
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
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Informasi Personal',
                style: theme.typographyRegular.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildDetailRow(
            theme,
            Icons.cake,
            'Tanggal Lahir',
            DateFormat('dd MMMM yyyy', 'id_ID').format(member.tanggalLahir),
          ),
          const SizedBox(height: 16),

          _buildDetailRow(
            theme,
            Icons.location_on,
            'Tempat Lahir',
            member.tempatLahir,
          ),
          const SizedBox(height: 16),

          _buildDetailRow(
            theme,
            Icons.wc,
            'Jenis Kelamin',
            member.jenisKelamin,
          ),
          const SizedBox(height: 16),

          _buildDetailRow(
            theme,
            Icons.calendar_today,
            'Usia',
            '${_calculateAge(member.tanggalLahir)} tahun',
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyInfoSection(dynamic theme, dto.FamilyMemberDto member) {
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
                  Icons.family_restroom,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informasi Keluarga',
                style: theme.typographyRegular.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildDetailRow(
            theme,
            Icons.people,
            'Status dalam Keluarga',
            _getHubunganLabel(member.hubungan),
          ),
          const SizedBox(height: 16),

          _buildDetailRow(theme, Icons.work, 'Pekerjaan', member.pekerjaan),
        ],
      ),
    );
  }

  Widget _buildMarriageInfoSection(dynamic theme, dto.FamilyMemberDto member) {
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
                    colors: [Colors.pink, Colors.pink.shade300],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informasi Pernikahan',
                style: theme.typographyRegular.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildDetailRow(
            theme,
            Icons.favorite,
            'Tanggal Menikah',
            DateFormat('dd MMMM yyyy', 'id_ID').format(member.tanggalMenikah!),
          ),
          const SizedBox(height: 16),

          _buildDetailRow(
            theme,
            Icons.timeline,
            'Lama Menikah',
            '${_calculateMarriageYears(member.tanggalMenikah!)} tahun',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    dynamic theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.typographyRegular.bodyMedium.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    dynamic theme,
    BuildContext context,
    WidgetRef ref,
    dto.FamilyMemberDto member,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _editFamilyMember(context, member),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primarySwatch,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.edit, size: 20),
            label: Text(
              'EDIT DATA',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _deleteFamilyMember(context, ref, member),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.delete, size: 20, color: Colors.white),
            label: Text(
              'HAPUS DATA',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
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
      case 'SUAMI':
        return 'Suami';
      default:
        return hubungan;
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  int _calculateMarriageYears(DateTime marriageDate) {
    DateTime today = DateTime.now();
    int years = today.year - marriageDate.year;
    if (today.month < marriageDate.month ||
        (today.month == marriageDate.month && today.day < marriageDate.day)) {
      years--;
    }
    return years;
  }

  // FIXED: Navigate to the correct route with member ID
  void _editFamilyMember(BuildContext context, dto.FamilyMemberDto member) {
    // Use the route with memberId parameter
    context.go('/edit-data-keluarga/${member.id}');
  }

  void _deleteFamilyMember(
    BuildContext context,
    WidgetRef ref,
    dto.FamilyMemberDto member,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Anggota Keluarga'),
            content: Text(
              'Apakah Anda yakin ingin menghapus data ${member.nama}?\n\nTindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  // Try API deletion, fallback to local removal
                  try {
                    await ref.read(keluargaApiProvider).deleteMember(member.id);
                    // Refresh remote list and member detail providers
                    ref.invalidate(keluargaRemoteProvider);
                    ref.invalidate(keluargaMemberProvider(member.id));
                  } catch (_) {
                    // Fallback: update local provider
                    final currentData = ref.read(familyDataProvider);
                    final updatedData =
                        currentData.where((m) => m.id != member.id).toList();
                    ref.read(familyDataProvider.notifier).state = updatedData;
                  }

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Data ${member.nama} berhasil dihapus',
                              style: const TextStyle(fontSize: 13.0),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );

                  // Navigate back to list
                  context.go('/keluarga');
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
