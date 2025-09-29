import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'dart:async';

class DaftarAgendaNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  DaftarAgendaNotifier()
    : super([
        {
          'id': 'AGD-001',
          'acara': 'Rapat Koordinasi Tim',
          'deskripsi':
              'Membahas persiapan acara internal dan koordinasi antar divisi untuk kelancaran program kerja.',
          'tanggal': '28-08-2025',
          'waktu': '10:00',
        },
        {
          'id': 'AGD-002',
          'acara': 'Evaluasi Program Semester',
          'deskripsi':
              'Menilai keberhasilan program semester lalu dan menyusun rencana perbaikan untuk periode mendatang.',
          'tanggal': '30-08-2025',
          'waktu': '13:30',
        },
        {
          'id': 'AGD-003',
          'acara': 'Pelatihan Karyawan',
          'deskripsi':
              'Pelatihan soft skills untuk seluruh staf guna meningkatkan kualitas pelayanan.',
          'tanggal': '02-09-2025',
          'waktu': '09:00',
        },
        {
          'id': 'AGD-004',
          'acara': 'Review Anggaran',
          'deskripsi': 'Tinjauan dan evaluasi penggunaan anggaran kuartal ini.',
          'tanggal': '05-09-2025',
          'waktu': '14:00',
        },
      ]);

  void addAgenda(Map<String, dynamic> agenda) {
    // Generate ID otomatis
    final existingIds = state.map((item) => item['id'] as String).toList();
    int counter = 1;
    String newId;
    do {
      newId = 'AGD-${counter.toString().padLeft(3, '0')}';
      counter++;
    } while (existingIds.contains(newId));

    final agendaWithId = {...agenda, 'id': newId};
    state = [...state, agendaWithId];
  }

  void removeAgenda(String id) {
    state = state.where((agenda) => agenda['id'] != id).toList();
  }

  void updateAgenda(String id, Map<String, dynamic> updatedData) {
    final index = state.indexWhere((agenda) => agenda['id'] == id);

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

final agendaDataProvider =
    StateNotifierProvider<DaftarAgendaNotifier, List<Map<String, dynamic>>>((
      ref,
    ) {
      return DaftarAgendaNotifier();
    });

final searchQueryProvider = StateProvider<String>((ref) => '');
final filteredAgendaProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final allItems = ref.watch(agendaDataProvider);

  if (query.isEmpty) return allItems;

  return allItems.where((item) {
    return item['id'].toString().toLowerCase().contains(query) ||
        item['acara'].toString().toLowerCase().contains(query) ||
        item['deskripsi'].toString().toLowerCase().contains(query) ||
        item['tanggal'].toString().toLowerCase().contains(query) ||
        item['waktu'].toString().toLowerCase().contains(query);
  }).toList();
});

class DaftarAgendaPage extends ConsumerStatefulWidget {
  const DaftarAgendaPage({super.key});

  @override
  ConsumerState<DaftarAgendaPage> createState() => _DaftarAgendaPageState();
}

class _DaftarAgendaPageState extends ConsumerState<DaftarAgendaPage> {
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

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredList = ref.watch(filteredAgendaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Agenda Pribadi Anggota',
        onBackPressed: () => context.go('/home'),
        backTooltip: 'Kembali ke Beranda',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AppSearchBar(
              controller: _searchController,
              hintText: 'Cari ID agenda, acara, tanggal...',
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
                onPressed: () => context.pushNamed(Routes.tambahAgenda.name),
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
                  'TAMBAH AGENDA PRIBADI',
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
                      Icon(
                        Icons.event_note,
                        color: theme.primarySwatch,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Daftar Agenda Pribadi',
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

            // Agenda List
            Expanded(
              child:
                  filteredList.isEmpty
                      ? _buildEmptyState(theme)
                      : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final agenda = filteredList[index];
                          return _buildAgendaCard(agenda, theme);
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
              searchQuery.isNotEmpty ? Icons.search_off : Icons.event_note,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isNotEmpty
                ? 'Tidak ada agenda yang ditemukan'
                : 'Belum ada agenda tersimpan',
            style: theme.typographyBold.bodyLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            searchQuery.isNotEmpty
                ? 'Coba kata kunci yang berbeda'
                : 'Tambahkan agenda pribadi pertama Anda',
            style: theme.typographyRegular.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed(Routes.tambahAgenda.name),
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
                'Tambah Agenda',
                style: theme.typographyBold.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAgendaCard(Map<String, dynamic> agenda, dynamic theme) {
    return AppListCard(
      onTap: () => _showDetailDialog(context, agenda, theme),
      leftAccentColor: theme.primarySwatch,
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
              theme.primarySwatch.withValues(alpha: 0.2),
              theme.primarySwatch.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primarySwatch.withValues(alpha: 0.3)),
        ),
        child: Icon(Icons.event_note, color: theme.primarySwatch, size: 24),
      ),
      title: agenda['acara'].toString(),
      subtitle: agenda['id'].toString(),
      chips: [
        AppPillChip(
          icon: Icons.calendar_today_rounded,
          label: agenda['tanggal'],
          color: theme.primarySwatch,
        ),
        AppPillChip(
          icon: Icons.access_time_rounded,
          label: agenda['waktu'],
          color: Colors.blue[600],
        ),
      ],
      actions: [
        AppViewDetailButton(
          onPressed: () => _showDetailDialog(context, agenda, theme),
          tooltip: 'Lihat Detail',
        ),
      ],
    );
  }

  void _confirmDelete(Map<String, dynamic> agenda) {
    SIHAKIConfirmationDialog.show(
      context,
      title: 'Hapus Agenda',
      message:
          'Apakah Anda yakin ingin menghapus agenda "${agenda['acara']}"? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      icon: Icons.delete_forever_rounded,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () {
        ref.read(agendaDataProvider.notifier).removeAgenda(agenda['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agenda "${agenda['acara']}" berhasil dihapus'),
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

  void _showDetailDialog(
    BuildContext context,
    Map<String, dynamic> agenda,
    dynamic theme,
  ) {
    final dialogData = SIHAKIDialogData(
      title: 'Detail Agenda - ${agenda['acara']}',
      fields: [
        SIHAKIDialogField(label: 'ID', value: agenda['id']),
        SIHAKIDialogField(label: 'Acara', value: agenda['acara']),
        SIHAKIDialogField(label: 'Tanggal', value: agenda['tanggal']),
        SIHAKIDialogField(label: 'Waktu', value: agenda['waktu']),
        SIHAKIDialogField(label: '', value: ''),
        SIHAKIDialogField(label: 'Deskripsi', value: agenda['deskripsi']),
      ],
      actions: [
        SIHAKIDialogAction(
          icon: Icons.edit_rounded,
          label: 'Ubah Agenda',
          textColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            context.pushNamed(Routes.editAgenda.name, extra: agenda);
          },
        ),
        SIHAKIDialogAction(
          icon: Icons.delete_rounded,
          label: 'Hapus Agenda',
          backgroundColor: Colors.red[600],
          textColor: Colors.white,
          isDestructive: true,
          onTap: () {
            Navigator.of(context).pop();
            _confirmDelete(agenda);
          },
        ),
      ],
    );

    SIHAKIDetailDialog.show(context, dialogData);
  }
}
