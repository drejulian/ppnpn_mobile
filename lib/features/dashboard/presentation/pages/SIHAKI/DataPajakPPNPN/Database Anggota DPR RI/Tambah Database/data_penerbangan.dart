import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataPajakPPNPN/Database%20Anggota%20DPR%20RI/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataPenerbanganPage extends ConsumerStatefulWidget {
  const DataPenerbanganPage({super.key});

  @override
  ConsumerState<DataPenerbanganPage> createState() => _DataPenerbanganPageState();
}

class _DataPenerbanganPageState extends ConsumerState<DataPenerbanganPage> {
  final _formKey = GlobalKey<FormState>();
  final _noKartuGarudaController = TextEditingController(text: '');
  final _noKartuEmiratesController = TextEditingController(text: '');
  final _noKartuQantasController = TextEditingController(text: '');
  String? _tempatDuduk;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _noKartuGarudaController.dispose();
    _noKartuEmiratesController.dispose();
    _noKartuQantasController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _noKartuGarudaController.text = prefs.getString('noKartuGaruda') ?? '';
      _noKartuEmiratesController.text = prefs.getString('noKartuEmirates') ?? '';
      _noKartuQantasController.text = prefs.getString('noKartuQantas') ?? '';
      _tempatDuduk = prefs.getString('tempatDuduk');
      if (_noKartuGarudaController.text.isNotEmpty &&
          _noKartuEmiratesController.text.isNotEmpty &&
          _noKartuQantasController.text.isNotEmpty &&
          _tempatDuduk != null) {
        ref.read(dataPenerbanganFilledProvider.notifier).state = true;
      } else {
        ref.read(dataPenerbanganFilledProvider.notifier).state = false;
      }
    });
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
                'Data Penerbangan',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              _buildFormDataPenerbangan(theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormDataPenerbangan(dynamic theme) {
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
          _buildTextFieldWithRequired(
            'No. Kartu Garuda',
            _noKartuGarudaController,
            Icons.airplanemode_active,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor kartu Garuda',
            keyboardType: TextInputType.number,
            enabled: _isEditing,
          ),
          _buildTextFieldWithRequired(
            'No. Kartu Emirates',
            _noKartuEmiratesController,
            Icons.airplanemode_active,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor kartu Emirates',
            keyboardType: TextInputType.number,
            enabled: _isEditing,
          ),
          _buildTextFieldWithRequired(
            'No. Kartu Qantas',
            _noKartuQantasController,
            Icons.airplanemode_active,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor kartu Qantas',
            keyboardType: TextInputType.number,
            enabled: _isEditing,
          ),
          _buildDropdownFieldWithRequired(
            'Tempat Duduk',
            _tempatDuduk,
            Icons.event_seat,
            theme,
            isRequired: true,
            isLast: true,
          ),
          const SizedBox(height: 20),
          Column(
            children: [
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
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isEditing ? () => _saveData(context, ref, theme) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditing ? theme.primarySwatch : theme.primarySwatch.withOpacity(0.5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) return theme.primarySwatch.withOpacity(0.5);
                        return theme.primarySwatch;
                      },
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
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithRequired(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isLast = false,
    bool enabled = true,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib Diisi',
                            style: theme.typographyRegular.bodyExtraSmall.copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    enabled: enabled,
                    decoration: InputDecoration(
                      hintText: hintText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                      hintStyle: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    validator: isRequired && enabled
                        ? (value) {
                            if (value == null || value.isEmpty) {
                              return 'Field ini wajib diisi';
                            }
                            return null;
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildDropdownFieldWithRequired(
    String label,
    String? value,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib Diisi',
                            style: theme.typographyRegular.bodyExtraSmall.copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _isEditing || value != null ? value : null,
                    hint: value == null && !_isEditing
                        ? Text(
                            'Pilih tempat duduk',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[400],
                            ),
                          )
                        : null,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    items: ['Economy', 'Business', 'First Class'].map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: _isEditing
                        ? (String? newValue) {
                            setState(() {
                              _tempatDuduk = newValue;
                            });
                          }
                        : null,
                    validator: _isEditing && isRequired
                        ? (value) {
                            if (value == null) {
                              return 'Field ini wajib diisi';
                            }
                            return null;
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Future<void> _saveData(BuildContext context, WidgetRef ref, dynamic theme) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];

      if (_noKartuGarudaController.text.isEmpty) {
        errors.add('No. Kartu Garuda harus diisi');
      }
      if (_noKartuEmiratesController.text.isEmpty) {
        errors.add('No. Kartu Emirates harus diisi');
      }
      if (_noKartuQantasController.text.isEmpty) {
        errors.add('No. Kartu Qantas harus diisi');
      }
      if (_tempatDuduk == null) {
        errors.add('Tempat Duduk harus diisi');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('noKartuGaruda', _noKartuGarudaController.text);
      await prefs.setString('noKartuEmirates', _noKartuEmiratesController.text);
      await prefs.setString('noKartuQantas', _noKartuQantasController.text);
      await prefs.setString('tempatDuduk', _tempatDuduk!);

      ref.read(dataPenerbanganFilledProvider.notifier).state = true;

      await _showSuccessDialog(context, theme);

      setState(() {
        _isEditing = false;
      });
    }
  }

  void _showErrorDialog(BuildContext context, dynamic theme, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  Future<void> _showSuccessDialog(BuildContext context, dynamic theme) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
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
                Navigator.of(dialogContext, rootNavigator: true).pop();
                context.go('/dataKomisi', extra: {'justSaved': true, 'sourcePage': '/data-penerbangan'});
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}