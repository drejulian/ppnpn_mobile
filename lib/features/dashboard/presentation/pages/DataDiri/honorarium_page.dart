import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/app/theme.dart';

class HonorariumPage extends ConsumerStatefulWidget {
  const HonorariumPage({super.key});

  @override
  ConsumerState<HonorariumPage> createState() => _HonorariumPageState();
}

class _HonorariumPageState extends ConsumerState<HonorariumPage> {
  // Text Controllers
  final TextEditingController _kartuKeluargaController =
      TextEditingController();
  final TextEditingController _ktpController = TextEditingController();
  final TextEditingController _namaKtpController = TextEditingController();
  final TextEditingController _bpjsKesehatanController =
      TextEditingController();
  final TextEditingController _npwpController = TextEditingController();
  final TextEditingController _namaIbuController = TextEditingController();
  final TextEditingController _rekeningController = TextEditingController();
  final TextEditingController _namaPemilikRekController =
      TextEditingController();
  final TextEditingController _jumlahAnakController = TextEditingController();

  // Dropdown values
  String _selectedStatusPTKP = 'Kawin (K)';

  // Dropdown options
  final List<String> _statusPTKPOptions = ['Tidak Kawin (TK)', 'Kawin (K)'];

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _kartuKeluargaController.text = '1111111111111111';
    _ktpController.text = '0603200310820003';
    _namaKtpController.text = 'AIRLANGGA EKA WARDHANA 01';
    _bpjsKesehatanController.text = '406546495464';
    _npwpController.text = '111111111111111';
    _namaIbuController.text = 'HARTINI WIJAYA';
    _rekeningController.text = '1582100318';
    _namaPemilikRekController.text = 'Bpk. AIRLANGGA EKA WARDHANA';
    _jumlahAnakController.text = '3';
    _selectedStatusPTKP = 'Kawin (K)';
  }

  @override
  void dispose() {
    _kartuKeluargaController.dispose();
    _ktpController.dispose();
    _namaKtpController.dispose();
    _bpjsKesehatanController.dispose();
    _npwpController.dispose();
    _namaIbuController.dispose();
    _rekeningController.dispose();
    _namaPemilikRekController.dispose();
    _jumlahAnakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Real-time Indonesian time (UTC+7)
    DateTime.now().toUtc().add(const Duration(hours: 7));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Data Honorarium',
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
          onPressed: () => Navigator.pop(context),
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
            // Form Data Honorarium
            _buildFormDataHonorarium(theme),

            const SizedBox(height: 20), // Bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildFormDataHonorarium(dynamic theme) {
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
          // Section Title
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
                  Icons.payment_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Data Honorarium',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Form Fields
          _buildTextFieldWithRequired(
            'No. Kartu Keluarga (Family Card Number)',
            _kartuKeluargaController,
            Icons.family_restroom,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor kartu keluarga',
            keyboardType: TextInputType.number,
          ),

          _buildTextFieldWithRequired(
            'No. KTP (ID Card Number)',
            _ktpController,
            Icons.credit_card,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor KTP',
            keyboardType: TextInputType.number,
          ),

          _buildTextFieldWithRequired(
            'Nama Sesuai KTP (Name as per KTP)',
            _namaKtpController,
            Icons.person,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama sesuai KTP',
          ),

          _buildTextFieldWithRequired(
            'No. BPJS Kesehatan (Health BPJS Number)',
            _bpjsKesehatanController,
            Icons.medical_services,
            theme,
            isRequired: true,
            hintText:
                'Jika Belum Punya, No. BPJS Kesehatan Diisi Dengan Angka "0" (Nol)',
            keyboardType: TextInputType.number,
            helperText:
                'Jika Belum Punya, No. BPJS Kesehatan Diisi Dengan Angka "0" (Nol)',
          ),

          _buildTextFieldWithRequired(
            'NPWP (Tax ID Number)',
            _npwpController,
            Icons.receipt_long,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor NPWP',
            keyboardType: TextInputType.number,
          ),

          _buildTextFieldWithRequired(
            'Nama Ibu Kandung (Mother\'s Maiden Name)',
            _namaIbuController,
            Icons.woman,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama ibu kandung',
          ),

          _buildTextFieldWithRequired(
            'No. Rekening (Bank Account Number)',
            _rekeningController,
            Icons.account_balance,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor rekening',
            keyboardType: TextInputType.number,
          ),

          _buildTextFieldWithRequired(
            'Nama Pemilik Rek. (Account Holder Name)',
            _namaPemilikRekController,
            Icons.account_circle,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama pemilik rekening',
          ),

          _buildDropdownField(
            'Status PTKP (Non-Taxable Income Status)',
            _selectedStatusPTKP,
            _statusPTKPOptions,
            Icons.assignment_ind,
            theme,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedStatusPTKP = value!;
              });
            },
            helperText: 'Untuk Perempuan, Status PTKP Adalah Tidak Kawin',
          ),

          _buildTextFieldWithRequired(
            'Jumlah Anak (Number of Children)',
            _jumlahAnakController,
            Icons.child_care,
            theme,
            isRequired: true,
            hintText: 'Masukkan jumlah anak',
            keyboardType: TextInputType.number,
            isLast: true,
          ),

          // Information Note
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Keterangan : perubahan status PTKP atau Jumlah Tanggungan Anak akan berlaku di awal tahun berikutnya',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Save Button
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
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
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    required Function(String?) onChanged,
    String? helperText,
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
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall
                                .copyWith(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: value,
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
                    ),
                    items:
                        items.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.grey[800],
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: onChanged,
                  ),
                  if (helperText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      helperText,
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
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

  Widget _buildTextFieldWithRequired(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    String? hintText,
    String? helperText,
    TextInputType? keyboardType,
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
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall
                                .copyWith(
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
                      hintStyle: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (helperText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      helperText,
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
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

  void _saveData(BuildContext context, dynamic theme) {
    // Validate required fields
    List<String> errors = [];

    if (_kartuKeluargaController.text.isEmpty) {
      errors.add('No. Kartu Keluarga harus diisi');
    }
    if (_ktpController.text.isEmpty) {
      errors.add('No. KTP harus diisi');
    }
    if (_namaKtpController.text.isEmpty) {
      errors.add('Nama Sesuai KTP harus diisi');
    }
    if (_bpjsKesehatanController.text.isEmpty) {
      errors.add('No. BPJS Kesehatan harus diisi');
    }
    if (_npwpController.text.isEmpty) {
      errors.add('NPWP harus diisi');
    }
    if (_namaIbuController.text.isEmpty) {
      errors.add('Nama Ibu Kandung harus diisi');
    }
    if (_rekeningController.text.isEmpty) {
      errors.add('No. Rekening harus diisi');
    }
    if (_namaPemilikRekController.text.isEmpty) {
      errors.add('Nama Pemilik Rekening harus diisi');
    }
    if (_selectedStatusPTKP.isEmpty) {
      errors.add('Status PTKP harus dipilih');
    }
    if (_jumlahAnakController.text.isEmpty) {
      errors.add('Jumlah Anak harus diisi');
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(context, theme, errors.join('\n'));
      return;
    }

    // Show success dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Simpan Data Honorarium',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text('Data honorarium berhasil disimpan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
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
}
