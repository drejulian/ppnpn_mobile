import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';

class DataKendaraanPage extends ConsumerStatefulWidget {
  const DataKendaraanPage({super.key});

  @override
  ConsumerState<DataKendaraanPage> createState() => _DataKendaraanPageState();
}

class _DataKendaraanPageState extends ConsumerState<DataKendaraanPage> {
  final _formKey = GlobalKey<FormState>();
  final _nopolDinasController = TextEditingController();
  final _nopolPribadiController = TextEditingController();
  bool _isEditing = false;

  static final Map<String, String> _persistentData = {};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {

    setState(() {
      _nopolDinasController.text = _persistentData['nopolDinas'] ?? '';
      _nopolPribadiController.text = _persistentData['nopolPribadi'] ?? '';
      if (_isAllRequiredFilled()) {
        ref.read(dataKendaraanFilledProvider.notifier).state = true;
      } else {
        ref.read(dataKendaraanFilledProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    _nopolDinasController.dispose();
    _nopolPribadiController.dispose();
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _nopolDinasController.text.isNotEmpty &&
        _nopolPribadiController.text.isNotEmpty;
  }

  Future<void> _saveData(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];

      if (_nopolDinasController.text.isEmpty) {
        errors.add('Nopol Dinas harus diisi');
      }
      if (_nopolPribadiController.text.isEmpty) {
        errors.add('Nopol Pribadi harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      _persistentData['nopolDinas'] = _nopolDinasController.text;
      _persistentData['nopolPribadi'] = _nopolPribadiController.text;

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Simpan Data Kendaraan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text('Data kendaraan berhasil disimpan.'),
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
        ref.read(dataKendaraanFilledProvider.notifier).state = true;
      });

      setState(() {
        _isEditing = false;
      });

      if (context.mounted) {
        context.go(
          '/dataKomisi',
          extra: {'justSaved': true, 'sourcePage': '/data-kendaraan'},
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Database Anggota DPR RI (DASI)',
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
            context.go('/dataKomisi');
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
              Text(
                'Data Kendaraan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              AppFormCard(
                title: 'Data Kendaraan',
                titleIcon: Icons.directions_car,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Nopol Dinas',
                    icon: Icons.local_police,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _nopolDinasController,
                    hintText: 'Masukkan nomor polisi dinas',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Nopol Pribadi',
                    icon: Icons.directions_car,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _nopolPribadiController,
                    hintText: 'Masukkan nomor polisi pribadi',
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
