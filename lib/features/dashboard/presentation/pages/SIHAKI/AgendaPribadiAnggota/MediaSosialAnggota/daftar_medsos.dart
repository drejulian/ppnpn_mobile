import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'dart:async';

// StateNotifier untuk Media Sosial
class MediaSosialNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  MediaSosialNotifier()
    : super([
        {
          'id': 'MED-001',
          'platform': 'Facebook',
          'username': 'https://facebook.com/username',
        },
        {
          'id': 'MED-002',
          'platform': 'Twitter',
          'username': 'https://twitter.com/username',
        },
        {
          'id': 'MED-003',
          'platform': 'LinkedIn',
          'username': 'https://linkedin.com/in/username',
        },
        {
          'id': 'MED-004',
          'platform': 'Instagram',
          'username': 'https://instagram.com/username',
        },
        {
          'id': 'MED-005',
          'platform': 'Website',
          'username': 'https://websiteanda.com',
        },
      ]);

  void addMediaSosial(Map<String, dynamic> medsos) {
    // Generate ID otomatis
    final existingIds = state.map((item) => item['id'] as String).toList();
    int counter = 1;
    String newId;
    do {
      newId = 'MED-${counter.toString().padLeft(3, '0')}';
      counter++;
    } while (existingIds.contains(newId));

    final medsosWithId = {...medsos, 'id': newId};
    state = [...state, medsosWithId];
  }

  void removeMediaSosial(String id) {
    state = state.where((medsos) => medsos['id'] != id).toList();
  }

  void updateMediaSosial(String id, Map<String, dynamic> updatedData) {
    final index = state.indexWhere((medsos) => medsos['id'] == id);

    if (index != -1) {
      final oldData = state[index];
      final mergedData = {...oldData, ...updatedData};

      state = [
        ...state.sublist(0, index),
        mergedData,
        ...state.sublist(index + 1),
      ];
    }
  }
}

final mediaSosialDataProvider =
    StateNotifierProvider<MediaSosialNotifier, List<Map<String, dynamic>>>((
      ref,
    ) {
      return MediaSosialNotifier();
    });

final searchQueryProvider = StateProvider<String>((ref) => '');
final filteredMediaSosialProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final allItems = ref.watch(mediaSosialDataProvider);

  if (query.isEmpty) return allItems;

  return allItems.where((item) {
    return item['id'].toString().toLowerCase().contains(query) ||
        item['platform'].toString().toLowerCase().contains(query) ||
        item['username'].toString().toLowerCase().contains(query) ||
        item['status'].toString().toLowerCase().contains(query);
  }).toList();
});

class MediaSosialAnggota extends ConsumerStatefulWidget {
  const MediaSosialAnggota({super.key});

  @override
  ConsumerState<MediaSosialAnggota> createState() => _MediaSosialAnggotaState();
}

class _MediaSosialAnggotaState extends ConsumerState<MediaSosialAnggota> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchQueryProvider);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _editData(Map<String, dynamic> medsos) {
    context.push('/edit-media-sosial-anggota', extra: medsos);
  }

  void _confirmDelete(Map<String, dynamic> medsos) {
    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Media Sosial',
      message:
          'Apakah Anda yakin ingin menghapus media sosial "${medsos['platform']}"? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () {
        ref
            .read(mediaSosialDataProvider.notifier)
            .removeMediaSosial(medsos['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Media sosial "${medsos['platform']}" berhasil dihapus',
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  IconData? _getIcon(String nama) {
    switch (nama.toLowerCase()) {
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'website':
        return FontAwesomeIcons.globe;
      default:
        return FontAwesomeIcons.shareAlt;
    }
  }

  Color _getColor(String nama) {
    switch (nama.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'linkedin':
        return const Color(0xFF0077B5);
      case 'instagram':
        return const Color(0xFFE1306C);
      case 'website':
        return Colors.blueGrey;
      default:
        return const Color.fromARGB(255, 178, 0, 191);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredList = ref.watch(filteredMediaSosialProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Media Sosial Anggota',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AppSearchBar(
              controller: _searchController,
              hintText: 'Cari ID, platform, username...',
              onChanged: (_) {},
              onClear: () => ref.read(searchQueryProvider.notifier).state = '',
              margin: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    theme.primarySwatch,
                    theme.primarySwatch.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primarySwatch.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/tambah-media-sosial-anggota'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_circle_rounded, size: 22),
                label: Text(
                  'TAMBAH MEDIA SOSIAL',
                  style: theme.typographyBold.bodyMedium.copyWith(
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header with data count
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primarySwatch.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share, color: theme.primarySwatch, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Daftar Media Sosial',
                        style: theme.typographyBold.bodyMedium.copyWith(
                          color: theme.primarySwatch,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.primarySwatch.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${filteredList.length} data',
                    style: theme.typographyBold.bodySmall.copyWith(
                      color: theme.primarySwatch,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Media Sosial List
            Expanded(
              child:
                  filteredList.isEmpty
                      ? _buildEmptyState(theme)
                      : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final medsos = filteredList[index];
                          return _buildMediaSosialCard(medsos, theme);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(dynamic theme) {
    final searchQuery = ref.watch(searchQueryProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              searchQuery.isNotEmpty ? Icons.search_off : Icons.share,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isNotEmpty
                ? 'Tidak ada media sosial yang ditemukan'
                : 'Belum ada media sosial tersimpan',
            style: theme.typographyBold.bodyLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            searchQuery.isNotEmpty
                ? 'Coba kata kunci yang berbeda'
                : 'Tambahkan media sosial pertama Anda',
            style: theme.typographyRegular.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/tambah-media-sosial-anggota'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primarySwatch,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text(
                'Tambah Media Sosial',
                style: theme.typographyBold.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaSosialCard(Map<String, dynamic> medsos, dynamic theme) {
    final icon = _getIcon(medsos['platform']);
    final color = _getColor(medsos['platform']);

    return AppListCard(
      onTap: () => _showDetailDialog(context, medsos, theme),
      leftAccentColor: color,
      gradient: LinearGradient(
        colors: [Colors.white, Colors.grey[50]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: medsos['platform'].toString(),
      subtitle: medsos['id'].toString(),
      chips: [
        AppPillChip(
          icon: Icons.link,
          label:
              medsos['username'].toString().length > 30
                  ? '${medsos['username'].toString().substring(0, 30)}...'
                  : medsos['username'].toString(),
          color: Colors.blue[600],
        ),
      ],
      actions: [
        AppViewDetailButton(
          onPressed: () => _showDetailDialog(context, medsos, theme),
          tooltip: 'Lihat Detail',
        ),
      ],
    );
  }

  void _showDetailDialog(
    BuildContext context,
    Map<String, dynamic> medsos,
    dynamic theme,
  ) {
    final dialogData = SIHAKIDialogData(
      title: 'Detail Media Sosial - ${medsos['platform']}',
      fields: [
        SIHAKIDialogField(label: 'ID', value: medsos['id']),
        SIHAKIDialogField(label: 'Platform', value: medsos['platform']),
        SIHAKIDialogField(label: 'Username/URL', value: medsos['username']),
      ],
      actions: [
        SIHAKIDialogAction(
          icon: Icons.edit_rounded,
          label: 'Ubah Media Sosial',
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            _editData(medsos);
          },
        ),
        SIHAKIDialogAction(
          icon: Icons.delete_rounded,
          label: 'Hapus Media Sosial',
          backgroundColor: Colors.red[600],
          textColor: Colors.white,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(medsos);
          },
        ),
      ],
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }
}
