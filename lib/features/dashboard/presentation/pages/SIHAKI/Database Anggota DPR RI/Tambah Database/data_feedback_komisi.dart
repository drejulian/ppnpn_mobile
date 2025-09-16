import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';

class DataFeedbackKomisiPage extends ConsumerStatefulWidget {
  const DataFeedbackKomisiPage({super.key});

  @override
  ConsumerState<DataFeedbackKomisiPage> createState() =>
      _DataFeedbackKomisiPageState();
}

class _DataFeedbackKomisiPageState
    extends ConsumerState<DataFeedbackKomisiPage> {
  final _formKey = GlobalKey<FormState>();
  final _topikController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _saranController = TextEditingController();
  String? _ratingKinerja;
  bool _isEditing = false;


  static final Map<String, String> _persistentData = {};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
  
    setState(() {
      _topikController.text = _persistentData['topik'] ?? '';
      _feedbackController.text = _persistentData['feedback'] ?? '';
      _saranController.text = _persistentData['saran'] ?? '';
      _ratingKinerja = _persistentData['ratingKinerja'];
      if (_isAllRequiredFilled()) {
        ref.read(dataFeedbackKomisiFilledProvider.notifier).state = true;
      } else {
        ref.read(dataFeedbackKomisiFilledProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    _topikController.dispose();
    _feedbackController.dispose();
    _saranController.dispose();
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _topikController.text.isNotEmpty &&
        _feedbackController.text.isNotEmpty &&
        _ratingKinerja != null;
  }

  Future<void> _saveData(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];

      if (_topikController.text.isEmpty) {
        errors.add('Topik harus diisi');
      }
      if (_feedbackController.text.isEmpty) {
        errors.add('Feedback harus diisi');
      }
      if (_ratingKinerja == null || _ratingKinerja!.isEmpty) {
        errors.add('Rating Kinerja harus dipilih');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      _persistentData['topik'] = _topikController.text;
      _persistentData['feedback'] = _feedbackController.text;
      _persistentData['saran'] = _saranController.text;
      _persistentData['ratingKinerja'] = _ratingKinerja!;

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Simpan Data Feedback Komisi',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text('Data feedback komisi berhasil disimpan.'),
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
        ref.read(dataFeedbackKomisiFilledProvider.notifier).state = true;
      });

      setState(() {
        _isEditing = false;
      });

      if (context.mounted) {
        context.go(
          '/dataKomisi',
          extra: {'justSaved': true, 'sourcePage': '/data-feedback-komisi'},
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
                'Data Feedback Komisi',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              AppFormCard(
                title: 'Feedback Komisi',
                titleIcon: Icons.feedback,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Topik',
                    icon: Icons.topic,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _topikController,
                    hintText: 'Masukkan topik feedback',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Feedback',
                    icon: Icons.comment,
                    type:
                        _isEditing
                            ? FormFieldType.multiline
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _feedbackController,
                    hintText: 'Masukkan feedback detail',
                    maxLines: 4,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Rating Kinerja',
                    icon: Icons.star_rate,
                    type:
                        _isEditing
                            ? FormFieldType.dropdown
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    value: _ratingKinerja,
                    options: const [
                      'Sangat Baik (5)',
                      'Baik (4)',
                      'Cukup (3)',
                      'Kurang (2)',
                      'Sangat Kurang (1)',
                    ],
                    hintText: 'Pilih rating kinerja',
                    onChanged: (value) {
                      setState(() {
                        _ratingKinerja = value;
                      });
                    },
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Saran Perbaikan',
                    icon: Icons.lightbulb_outline,
                    type:
                        _isEditing
                            ? FormFieldType.multiline
                            : FormFieldType.disabled,
                    isRequired: false,
                    enabled: _isEditing,
                    controller: _saranController,
                    hintText: 'Masukkan saran perbaikan (opsional)',
                    maxLines: 3,
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
