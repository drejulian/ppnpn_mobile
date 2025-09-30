import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart' as notification;
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/profile_data_provider.dart';

const List<String> positions = [
  'Tenaga Ahli',
  'Staf Administrasi',
  'Staf Sus',
  'Lainnya',
];

const List<String> placements = [
  'Sekretariat Jenderal',
  'DPRD',
  'Fraksi',
  'Lainnya',
];

const List<String> subPlacements = [
  'ONCE MEKEL, S.H.',
  'ARI WIJAYA, S.E., M.AP.',
  'BUDI SANTOSO, S.Sos',
  'CITRA DEWI, S.H., M.H.',
  'DONI SAPUTRA, M.Kom',
];

final selectedStartDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedLetterDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedPlacementDateProvider = StateProvider<DateTime?>((ref) => null);

class ApplicationDataPage extends ConsumerStatefulWidget {
  const ApplicationDataPage({super.key});

  @override
  ConsumerState<ApplicationDataPage> createState() => _ApplicationDataPageState();
}

class _ApplicationDataPageState extends ConsumerState<ApplicationDataPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPosition;
  String? _selectedPlacement;
  late TextEditingController _subPlacementController;
  late TextEditingController _otherPositionController;
  late TextEditingController _otherPlacementController;
  late TextEditingController _notesController;
  final List<String> _existingPositions = [
    'Manajer Proyek - PT ABC (2020-2023)',
    'Analis Data - CV XYZ (2018-2020)',
  ];
  String? _selectedExistingPosition;
  bool _hasUnsavedChanges = false;
  Map<String, dynamic> _originalData = {};

  @override
  void initState() {
    super.initState();
    _subPlacementController = TextEditingController();
    _otherPositionController = TextEditingController();
    _otherPlacementController = TextEditingController();
    _notesController = TextEditingController();

    _subPlacementController.addListener(_updateUnsavedChanges);
    _otherPositionController.addListener(_updateUnsavedChanges);
    _otherPlacementController.addListener(_updateUnsavedChanges);
    _notesController.addListener(_updateUnsavedChanges);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final savedData = ref.read(dataLamaranDataProvider);

    if (_selectedPosition == null) {
      _selectedPosition = savedData.position.isNotEmpty ? savedData.position : null;
      _otherPositionController.text = savedData.otherPosition;
      _selectedPlacement = savedData.placement.isNotEmpty ? savedData.placement : null;
      _otherPlacementController.text = savedData.placement == 'Lainnya' ? savedData.placement : '';
      _subPlacementController.text = savedData.subPlacement;
      _notesController.text = savedData.notes ?? '';

      if (savedData.startDate != null) {
        ref.read(selectedStartDateProvider.notifier).state = savedData.startDate;
      }
      if (savedData.letterDate != null) {
        ref.read(selectedLetterDateProvider.notifier).state = savedData.letterDate;
      }
      if (savedData.placementDate != null) {
        ref.read(selectedPlacementDateProvider.notifier).state = savedData.placementDate;
      }

      _originalData = _getCurrentData();
    }
  }

  @override
  void dispose() {
    _subPlacementController.removeListener(_updateUnsavedChanges);
    _otherPositionController.removeListener(_updateUnsavedChanges);
    _otherPlacementController.removeListener(_updateUnsavedChanges);
    _notesController.removeListener(_updateUnsavedChanges);

    try {
      _subPlacementController.dispose();
      _otherPositionController.dispose();
      _otherPlacementController.dispose();
      _notesController.dispose();
    } catch (e) {
      if (context.mounted) {
        notification.NotificationUtils.showError(
          context,
          'Gagal menutup controller: $e',
        );
      }
    }
    super.dispose();
  }

  Map<String, dynamic> _getCurrentData() {
    final savedData = ref.read(dataLamaranDataProvider);
    return {
      'position': _selectedPosition ?? savedData.position,
      'otherPosition': _otherPositionController.text,
      'placement': _selectedPlacement ?? savedData.placement,
      'otherPlacement': _otherPlacementController.text,
      'subPlacement': _subPlacementController.text,
      'notes': _notesController.text,
      'startDate': ref.read(selectedStartDateProvider),
      'letterDate': ref.read(selectedLetterDateProvider),
      'placementDate': ref.read(selectedPlacementDateProvider),
      'existingPosition': _selectedExistingPosition,
    };
  }

  bool _hasUnsavedChangesInternal() {
    final currentData = _getCurrentData();
    bool hasChanges = false;

    _originalData.forEach((key, value) {
      if (key == 'startDate' || key == 'letterDate' || key == 'placementDate') {
        if ((value == null && currentData[key] != null) ||
            (value != null && currentData[key] == null) ||
            (value != null &&
                currentData[key] != null &&
                value.millisecondsSinceEpoch !=
                    currentData[key].millisecondsSinceEpoch)) {
          hasChanges = true;
        }
      } else if (currentData[key] != value) {
        hasChanges = true;
      }
    });

    return hasChanges;
  }

  void _updateUnsavedChanges() {
    setState(() {
      _hasUnsavedChanges = _hasUnsavedChangesInternal();
    });
  }

  Future<bool> _showUnsavedChangesDialog() async {
    final theme = ref.read(themeProvider);
    return await SIHAKIConfirmationDialog.show(
      context,
      title: 'Batalkan Perubahan Data Lamaran',
      message:
          'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
      confirmText: 'Batalkan',
      cancelText: 'Batal',
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red[600]!,
      isDestructive: true,
      onConfirm: () {
        _restoreOriginalData();
        if (context.mounted) {
          notification.NotificationUtils.showWarning(
            context,
            'Perubahan pada data lamaran telah dibatalkan',
          );
        }
      },
      onCancel: () {},
    ) ?? false;
  }

  void _restoreOriginalData() {
    final savedData = ref.read(dataLamaranDataProvider);
    setState(() {
      _selectedPosition = savedData.position.isNotEmpty ? savedData.position : null;
      _otherPositionController.text = savedData.otherPosition;
      _selectedPlacement = savedData.placement.isNotEmpty ? savedData.placement : null;
      _otherPlacementController.text = savedData.placement == 'Lainnya' ? savedData.placement : '';
      _subPlacementController.text = savedData.subPlacement;
      _notesController.text = savedData.notes ?? '';
      _selectedExistingPosition = null;

      ref.read(selectedStartDateProvider.notifier).state = savedData.startDate;
      ref.read(selectedLetterDateProvider.notifier).state = savedData.letterDate;
      ref.read(selectedPlacementDateProvider.notifier).state = savedData.placementDate;

      _hasUnsavedChanges = false;
    });
  }

  Future<void> _selectDate(
    BuildContext context,
    StateProvider<DateTime?> provider,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: ref.read(provider) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      ref.read(provider.notifier).state = picked;
      _updateUnsavedChanges();
    }
  }

  Future<void> _submitApplicationData() async {
    if (_formKey.currentState!.validate()) {
      final String? position =
          _selectedPosition == 'Lainnya' ? _otherPositionController.text : _selectedPosition;
      final String? placement =
          _selectedPlacement == 'Lainnya' ? _otherPlacementController.text : _selectedPlacement;
      final String subPlacement = _subPlacementController.text;
      final DateTime? startDate = ref.read(selectedStartDateProvider);
      final DateTime? letterDate = ref.read(selectedLetterDateProvider);
      final DateTime? placementDate = ref.read(selectedPlacementDateProvider);

      final dataLamaranData = DataLamaranData(
        position: position ?? '',
        placement: placement ?? '',
        subPlacement: subPlacement,
        otherPosition: _selectedPosition == 'Lainnya' ? _otherPositionController.text : '',
        startDate: startDate,
        letterDate: letterDate,
        placementDate: placementDate,
        notes: _notesController.text,
      );

      ref.read(dataLamaranDataProvider.notifier).updateData(dataLamaranData);

      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool('data_lamaran_has_changes', false),
        prefs.setBool('data_lamaran_just_saved', true),
        prefs.setBool('data_lamaran_user_saved', true),
      ]);

      await ProfileCompletionNotifierCard.show(
        context,
        title: 'Berhasil Menyimpan Data Lamaran',
        message: 'Data lamaran Anda telah diperbarui dan tersimpan dengan sukses.',
        onConfirm: () {
          if (context.mounted) {
            notification.NotificationUtils.showSuccess(
              context,
              'Data lamaran telah disimpan',
            );
            context.pop('saved');
          }
        },
        icon: Icons.check_circle_rounded,
        iconColor: Colors.green[600],
      );

      setState(() {
        _hasUnsavedChanges = false;
        _originalData = _getCurrentData();
      });
    } else {
      await ErrorUploadDialogCard.show(
        context,
        title: 'Gagal Menyimpan',
        message: 'Mohon lengkapi semua field yang diperlukan.',
        onConfirm: () {
        },
      );
    }
  }

  Future<void> _saveAllApplicationData() async {
    if (_formKey.currentState!.validate()) {
      final String? position =
          _selectedPosition == 'Lainnya' ? _otherPositionController.text : _selectedPosition;
      final String? placement =
          _selectedPlacement == 'Lainnya' ? _otherPlacementController.text : _selectedPlacement;
      final String subPlacement = _subPlacementController.text;
      final DateTime? startDate = ref.read(selectedStartDateProvider);
      final DateTime? letterDate = ref.read(selectedLetterDateProvider);
      final DateTime? placementDate = ref.read(selectedPlacementDateProvider);

      final dataLamaranData = DataLamaranData(
        position: position ?? '',
        placement: placement ?? '',
        subPlacement: subPlacement,
        otherPosition: _selectedPosition == 'Lainnya' ? _otherPositionController.text : '',
        startDate: startDate,
        letterDate: letterDate,
        placementDate: placementDate,
        notes: _notesController.text,
      );

      ref.read(dataLamaranDataProvider.notifier).updateData(dataLamaranData);
      ref.read(profileCompletionProvider.notifier).markCompleted('dataLamaran');

      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool('data_lamaran_has_changes', false),
        prefs.setBool('data_lamaran_just_saved', true),
        prefs.setBool('data_lamaran_user_saved', true),
      ]);

      await ProfileCompletionNotifierCard.show(
        context,
        title: 'Berhasil Menyimpan Semua Data Lamaran',
        message: 'Semua data lamaran Anda telah diperbarui dan tersimpan dengan sukses.',
        onConfirm: () {
          if (context.mounted) {
            notification.NotificationUtils.showSuccess(
              context,
              'Semua data lamaran telah disimpan',
            );
            context.pop('saved');
          }
        },
        icon: Icons.check_circle_rounded,
        iconColor: Colors.green[600],
      );

      setState(() {
        _hasUnsavedChanges = false;
        _originalData = _getCurrentData();
      });
    } else {
      await ErrorUploadDialogCard.show(
        context,
        title: 'Gagal Menyimpan',
        message: 'Mohon lengkapi semua field yang diperlukan.',
        onConfirm: () {
        },
      );
    }
  }

  void _downloadTransferData() {
    if (context.mounted) {
      notification.NotificationUtils.showSuccess(
        context,
        'Mendownload data transfer...',
      );
    }
  }

  void _printApplicationFiles() {
    if (context.mounted) {
      notification.NotificationUtils.showSuccess(
        context,
        'Mencetak berkas lamaran dalam format PDF...',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final selectedStartDate = ref.watch(selectedStartDateProvider);
    final selectedLetterDate = ref.watch(selectedLetterDateProvider);
    final selectedPlacementDate = ref.watch(selectedPlacementDateProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_hasUnsavedChanges || _hasUnsavedChangesInternal()) {
          final shouldLeave = await _showUnsavedChangesDialog();
          if (shouldLeave && context.mounted) {
            context.pop();
          }
        } else if (context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
       backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Data Lamaran',
        onBackPressed: () => Navigator.of(context).pop(),
        backTooltip: 'Kembali',
      ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 16.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                theme,
                'Data Lamaran',
                Icons.assignment,
                theme.primarySwatch,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                theme,
                'Laman data hanya diisi bila Anda akan mengajukan lamaran untuk menempati posisi baru baik sebagai Tenaga Ahli, Staf Administrasi maupun Staf Sus.',
                Colors.blue[50]!,
                Colors.blue[700]!,
                Icons.info_outline,
              ),
              const SizedBox(height: 20),
              _buildApplicationForm(
                theme,
                selectedStartDate,
                selectedLetterDate,
                selectedPlacementDate,
              ),
              const SizedBox(height: 30),
              _buildSectionHeader(
                theme,
                'Data Pergantian / Posisi Baru',
                Icons.swap_horiz,
                Colors.purple,
              ),
              const SizedBox(height: 16),
              _buildReplacementPositionSection(theme),
              const SizedBox(height: 30),
              _buildSectionHeader(
                theme,
                'Pernyataan Pengisian Data',
                Icons.gavel,
                Colors.teal,
              ),
              const SizedBox(height: 16),
              _buildStatementSection(theme),
              const SizedBox(height: 30),
              _buildSectionHeader(
                theme,
                'Transfer Data',
                Icons.upload_file,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildTransferDataSection(theme),
              const SizedBox(height: 30),
              _buildSectionHeader(
                theme,
                'Cetak Berkas Lamaran',
                Icons.picture_as_pdf,
                Colors.red,
              ),
              const SizedBox(height: 16),
              _buildPrintFilesSection(theme),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.save_outlined,
                      size: 48,
                      color: theme.primarySwatch,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Simpan Semua Data Lamaran',
                      style: theme.typographyRegular.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pastikan semua data telah diisi dengan benar sebelum menyimpan.',
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveAllApplicationData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primarySwatch,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.save, size: 22),
                        label: Text(
                          'SIMPAN DATA LAMARAN',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    dynamic theme,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.typographyRegular.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    dynamic theme,
    String text,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        border: Border.all(color: textColor.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.typographyRegular.bodySmall.copyWith(
                color: textColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required dynamic theme, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildApplicationForm(
    dynamic theme,
    DateTime? selectedStartDate,
    DateTime? selectedLetterDate,
    DateTime? selectedPlacementDate,
  ) {
    return _buildCard(
      theme: theme,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Posisi',
              style: theme.typographyRegular.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: _inputDecoration(theme),
              value: _selectedPosition,
              hint: const Text('Pilih Posisi'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPosition = newValue;
                  _updateUnsavedChanges();
                });
              },
              items: positions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Posisi tidak boleh kosong';
                }
                return null;
              },
            ),
            if (_selectedPosition == 'Lainnya') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _otherPositionController,
                decoration: _inputDecoration(theme).copyWith(
                  labelText: 'Masukkan Posisi Lainnya',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Posisi lainnya tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Penempatan',
              style: theme.typographyRegular.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: _inputDecoration(theme),
              value: _selectedPlacement,
              hint: const Text('Pilih Penempatan'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPlacement = newValue;
                  _updateUnsavedChanges();
                });
              },
              items: placements.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Penempatan tidak boleh kosong';
                }
                return null;
              },
            ),
            if (_selectedPlacement == 'Lainnya') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _otherPlacementController,
                decoration: _inputDecoration(theme).copyWith(
                  labelText: 'Masukkan Penempatan Lainnya',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Penempatan lainnya tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Sub Penempatan',
              style: theme.typographyRegular.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            RawAutocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return subPlacements.where((String option) {
                  return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              onSelected: (String selection) {
                setState(() {
                  _subPlacementController.text = selection;
                  _updateUnsavedChanges();
                });
              },
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                _subPlacementController = textEditingController;
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: _inputDecoration(theme).copyWith(
                    hintText: 'Cari atau ketik sub penempatan',
                    suffixIcon: textEditingController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              textEditingController.clear();
                              _updateUnsavedChanges();
                            },
                          )
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sub Penempatan tidak boleh kosong';
                    }
                    return null;
                  },
                );
              },
              optionsViewBuilder: (
                BuildContext context,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options,
              ) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: 400,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(title: Text(option)),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDateFormField(
              theme,
              'Tanggal Mulai',
              selectedStartDate,
              () => _selectDate(context, selectedStartDateProvider),
              'Tanggal Mulai tidak boleh kosong',
            ),
            const SizedBox(height: 16),
            _buildDateFormField(
              theme,
              'Tanggal Surat',
              selectedLetterDate,
              () => _selectDate(context, selectedLetterDateProvider),
              'Tanggal Surat tidak boleh kosong',
            ),
            const SizedBox(height: 16),
            _buildDateFormField(
              theme,
              'Tanggal Penempatan',
              selectedPlacementDate,
              () => _selectDate(context, selectedPlacementDateProvider),
              'Tanggal Penempatan tidak boleh kosong',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitApplicationData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  'SUBMIT POSISI BARU',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(dynamic theme, {String? labelText}) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: theme.primarySwatch),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildDateFormField(
    dynamic theme,
    String label,
    DateTime? date,
    VoidCallback onTap,
    String validationMessage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typographyRegular.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          controller: TextEditingController(
            text: date != null ? DateFormat('dd-MM-yyyy').format(date) : '',
          ),
          decoration: _inputDecoration(theme).copyWith(
            hintText: 'Pilih Tanggal',
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: onTap,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return validationMessage;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildReplacementPositionSection(dynamic theme) {
    return _buildCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Posisi yang Sudah Ada',
            style: theme.typographyRegular.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: _inputDecoration(theme),
            value: _selectedExistingPosition,
            hint: const Text(
              'Pilih Posisi',
              overflow: TextOverflow.ellipsis,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedExistingPosition = newValue;
                _updateUnsavedChanges();
              });
            },
            items: _existingPositions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
            validator: (value) {
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_selectedExistingPosition != null) {
                  if (context.mounted) {
                    notification.NotificationUtils.showSuccess(
                      context,
                      'Mengajukan lamaran untuk posisi yang sudah ada: $_selectedExistingPosition',
                    );
                  }
                } else {
                  ErrorUploadDialogCard.show(
                    context,
                    title: 'Gagal Mengajukan',
                    message: 'Pilih posisi terlebih dahulu.',
                    onConfirm: () {
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.add_task, size: 20),
              label: Text(
                'UNTUK PEMENUHAN POSISI BARU',
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

  Widget _buildStatementSection(dynamic theme) {
    return _buildCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saya yang bertanda tangan di bawah ini, mengkonfirmasi bahwa data yang saya masukkan adalah benar dan valid.',
            style: theme.typographyRegular.bodyMedium.copyWith(
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Nama: Airlangga Eka Wardhana, S.Kom, M.T.I.',
            style: theme.typographyRegular.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (context.mounted) {
                  notification.NotificationUtils.showSuccess(
                    context,
                    'Pernyataan data berhasil disimpan secara digital.',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.fingerprint, size: 20),
              label: Text(
                'SIMPAN DIGI',
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

  Widget _buildTransferDataSection(dynamic theme) {
    return _buildCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anda dapat mentransfer data lamaran Anda ke unit lain jika diperlukan.',
            style: theme.typographyRegular.bodyMedium.copyWith(
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: _inputDecoration(theme).copyWith(
              labelText: 'Catatan Lainnya (misal: Unit tujuan transfer)',
              hintText: 'Masukkan detail atau catatan tambahan di sini...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _downloadTransferData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.download, size: 20),
              label: Text(
                'DOWNLOAD TRANSFER DATA',
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

  Widget _buildPrintFilesSection(dynamic theme) {
    return _buildCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Setelah data lamaran Anda disimpan, Anda dapat mengunduh berkas lamaran lengkap dalam format PDF untuk dicetak atau keperluan lainnya.',
            style: theme.typographyRegular.bodyMedium.copyWith(
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _printApplicationFiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.print, size: 20),
              label: Text(
                'CETAK BERKAS',
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
}