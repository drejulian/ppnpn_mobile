import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';

class DataPenerbanganPage extends ConsumerStatefulWidget {
  const DataPenerbanganPage({super.key});

  @override
  ConsumerState<DataPenerbanganPage> createState() =>
      _DataPenerbanganPageState();
}

class _DataPenerbanganPageState extends ConsumerState<DataPenerbanganPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomorPassportController = TextEditingController();
  final _bandaraPreferensiController = TextEditingController();
  final _maskapaiPreferensiController = TextEditingController();
  final _kelasPenerbanganController = TextEditingController();
  bool _isEditing = false;


  static final Map<String, String> _persistentData = {};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {

    setState(() {
      _nomorPassportController.text = _persistentData['nomorPassport'] ?? '';
      _bandaraPreferensiController.text =
          _persistentData['bandaraPreferensi'] ?? '';
      _maskapaiPreferensiController.text =
          _persistentData['maskapaiPreferensi'] ?? '';
      _kelasPenerbanganController.text =
          _persistentData['kelasPenerbangan'] ?? '';
      if (_isAllRequiredFilled()) {
        ref.read(dataPenerbanganFilledProvider.notifier).state = true;
      } else {
        ref.read(dataPenerbanganFilledProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    _nomorPassportController.dispose();
    _bandaraPreferensiController.dispose();
    _maskapaiPreferensiController.dispose();
    _kelasPenerbanganController.dispose();
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _nomorPassportController.text.isNotEmpty &&
        _bandaraPreferensiController.text.isNotEmpty &&
        _maskapaiPreferensiController.text.isNotEmpty &&
        _kelasPenerbanganController.text.isNotEmpty;
  }

  Future<void> _saveData(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];

      if (_nomorPassportController.text.isEmpty) {
        errors.add('Nomor Passport harus diisi');
      }
      if (_bandaraPreferensiController.text.isEmpty) {
        errors.add('Bandara Preferensi harus diisi');
      }
      if (_maskapaiPreferensiController.text.isEmpty) {
        errors.add('Maskapai Preferensi harus diisi');
      }
      if (_kelasPenerbanganController.text.isEmpty) {
        errors.add('Kelas Penerbangan harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      _persistentData['nomorPassport'] = _nomorPassportController.text;
      _persistentData['bandaraPreferensi'] = _bandaraPreferensiController.text;
      _persistentData['maskapaiPreferensi'] =
          _maskapaiPreferensiController.text;
      _persistentData['kelasPenerbangan'] = _kelasPenerbanganController.text;

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Simpan Data Penerbangan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text('Data penerbangan berhasil disimpan.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );

      await Future.delayed(Duration.zero, () {
        ref.read(dataPenerbanganFilledProvider.notifier).state = true;
      });

      setState(() {
        _isEditing = false;
      });

      if (context.mounted) {
        context.go(
          '/dataKomisi',
          extra: {'justSaved': true, 'sourcePage': '/data-penerbangan'},
        );
      }
    }
  }

  void _showErrorDialog(BuildContext context, dynamic theme, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Error',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppCustomAppBar(
        title: 'Data Penerbangan',
        onBackPressed: () => context.go('/dataKomisi'),
        backTooltip: 'Kembali',
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
              AppFormCard(
                title: 'Data Penerbangan',
                titleIcon: Icons.flight,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Nomor Passport',
                    icon: Icons.credit_card,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _nomorPassportController,
                    hintText: 'Masukkan nomor passport',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Bandara Preferensi',
                    icon: Icons.flight_takeoff,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _bandaraPreferensiController,
                    hintText: 'Masukkan bandara preferensi',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Maskapai Preferensi',
                    icon: Icons.airplanemode_active,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _maskapaiPreferensiController,
                    hintText: 'Masukkan maskapai preferensi',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Kelas Penerbangan',
                    icon: Icons.event_seat,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _kelasPenerbanganController,
                    hintText:
                        'Masukkan kelas penerbangan (Economy/Business/First)',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tombol EDIT dan SIMPAN
              Column(
                children: [
                  if (!_isEditing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
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
                          'EDIT',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_isEditing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _saveData(context, ref, theme),
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
                  ],
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
