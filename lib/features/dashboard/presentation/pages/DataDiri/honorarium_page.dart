import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart' as notification;
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/profile_data_provider.dart';

class HonorariumPage extends ConsumerStatefulWidget {
  const HonorariumPage({super.key});

  @override
  ConsumerState<HonorariumPage> createState() => _HonorariumPageState();
}

class _HonorariumPageState extends ConsumerState<HonorariumPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kartuKeluargaController = TextEditingController();
  final TextEditingController _ktpController = TextEditingController();
  final TextEditingController _namaKtpController = TextEditingController();
  final TextEditingController _bpjsKesehatanController = TextEditingController();
  final TextEditingController _npwpController = TextEditingController();
  final TextEditingController _namaIbuController = TextEditingController();
  final TextEditingController _rekeningController = TextEditingController();
  final TextEditingController _namaPemilikRekController = TextEditingController();
  final TextEditingController _jumlahAnakController = TextEditingController();

  String _selectedStatusPTKP = 'Kawin (K)';
  bool _hasUnsavedChanges = false;
  final List<String> _statusPTKPOptions = ['Tidak Kawin (TK)', 'Kawin (K)'];

  @override
  void initState() {
    super.initState();
    _kartuKeluargaController.addListener(_updateUnsavedChanges);
    _ktpController.addListener(_updateUnsavedChanges);
    _namaKtpController.addListener(_updateUnsavedChanges);
    _bpjsKesehatanController.addListener(_updateUnsavedChanges);
    _npwpController.addListener(_updateUnsavedChanges);
    _namaIbuController.addListener(_updateUnsavedChanges);
    _rekeningController.addListener(_updateUnsavedChanges);
    _namaPemilikRekController.addListener(_updateUnsavedChanges);
    _jumlahAnakController.addListener(_updateUnsavedChanges);

    SharedPreferences.getInstance().then((prefs) {
      final hasChanges = prefs.getBool('honorarium_has_changes') ?? false;
      if (hasChanges && mounted) {
        setState(() {
          _hasUnsavedChanges = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final savedData = ref.read(honorariumDataProvider);
    if (_kartuKeluargaController.text.isEmpty) {
      _kartuKeluargaController.text = savedData.kartuKeluarga.isNotEmpty
          ? savedData.kartuKeluarga
          : '1111111111111111';
    }
    if (_ktpController.text.isEmpty) {
      _ktpController.text = savedData.ktp.isNotEmpty
          ? savedData.ktp
          : '0603200310820003';
    }
    if (_namaKtpController.text.isEmpty) {
      _namaKtpController.text = savedData.namaKtp.isNotEmpty
          ? savedData.namaKtp
          : 'AIRLANGGA EKA WARDHANA 01';
    }
    if (_bpjsKesehatanController.text.isEmpty) {
      _bpjsKesehatanController.text = savedData.bpjsKesehatan.isNotEmpty
          ? savedData.bpjsKesehatan
          : '406546495464';
    }
    if (_npwpController.text.isEmpty) {
      _npwpController.text = savedData.npwp.isNotEmpty
          ? savedData.npwp
          : '111111111111111';
    }
    if (_namaIbuController.text.isEmpty) {
      _namaIbuController.text = savedData.namaIbu.isNotEmpty
          ? savedData.namaIbu
          : 'HARTINI WIJAYA';
    }
    if (_rekeningController.text.isEmpty) {
      _rekeningController.text = savedData.rekening.isNotEmpty
          ? savedData.rekening
          : '1582100318';
    }
    if (_namaPemilikRekController.text.isEmpty) {
      _namaPemilikRekController.text = savedData.namaPemilikRek.isNotEmpty
          ? savedData.namaPemilikRek
          : 'Bpk. AIRLANGGA EKA WARDHANA';
    }
    if (_jumlahAnakController.text.isEmpty) {
      _jumlahAnakController.text = savedData.jumlahAnak.isNotEmpty
          ? savedData.jumlahAnak
          : '3';
    }
    if (_selectedStatusPTKP == 'Kawin (K)' && savedData.statusPTKP.isNotEmpty) {
      _selectedStatusPTKP = savedData.statusPTKP;
    }
  }

  @override
  void dispose() {
    _kartuKeluargaController.removeListener(_updateUnsavedChanges);
    _ktpController.removeListener(_updateUnsavedChanges);
    _namaKtpController.removeListener(_updateUnsavedChanges);
    _bpjsKesehatanController.removeListener(_updateUnsavedChanges);
    _npwpController.removeListener(_updateUnsavedChanges);
    _namaIbuController.removeListener(_updateUnsavedChanges);
    _rekeningController.removeListener(_updateUnsavedChanges);
    _namaPemilikRekController.removeListener(_updateUnsavedChanges);
    _jumlahAnakController.removeListener(_updateUnsavedChanges);
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

  void _updateUnsavedChanges() {
    final hasChanges = _hasUnsavedChangesInternal();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('honorarium_has_changes', hasChanges);
    });
    if (mounted) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  bool _hasUnsavedChangesInternal() {
    final savedData = ref.read(honorariumDataProvider);
    final expectedKartuKeluarga = savedData.kartuKeluarga.isNotEmpty ? savedData.kartuKeluarga : '1111111111111111';
    final expectedKtp = savedData.ktp.isNotEmpty ? savedData.ktp : '0603200310820003';
    final expectedNamaKtp = savedData.namaKtp.isNotEmpty ? savedData.namaKtp : 'AIRLANGGA EKA WARDHANA 01';
    final expectedBpjsKesehatan = savedData.bpjsKesehatan.isNotEmpty ? savedData.bpjsKesehatan : '406546495464';
    final expectedNpwp = savedData.npwp.isNotEmpty ? savedData.npwp : '111111111111111';
    final expectedNamaIbu = savedData.namaIbu.isNotEmpty ? savedData.namaIbu : 'HARTINI WIJAYA';
    final expectedRekening = savedData.rekening.isNotEmpty ? savedData.rekening : '1582100318';
    final expectedNamaPemilikRek = savedData.namaPemilikRek.isNotEmpty ? savedData.namaPemilikRek : 'Bpk. AIRLANGGA EKA WARDHANA';
    final expectedJumlahAnak = savedData.jumlahAnak.isNotEmpty ? savedData.jumlahAnak : '3';
    final expectedStatusPTKP = savedData.statusPTKP.isNotEmpty ? savedData.statusPTKP : 'Kawin (K)';

    return _kartuKeluargaController.text.trim() != expectedKartuKeluarga.trim() ||
        _ktpController.text.trim() != expectedKtp.trim() ||
        _namaKtpController.text.trim() != expectedNamaKtp.trim() ||
        _bpjsKesehatanController.text.trim() != expectedBpjsKesehatan.trim() ||
        _npwpController.text.trim() != expectedNpwp.trim() ||
        _namaIbuController.text.trim() != expectedNamaIbu.trim() ||
        _rekeningController.text.trim() != expectedRekening.trim() ||
        _namaPemilikRekController.text.trim() != expectedNamaPemilikRek.trim() ||
        _jumlahAnakController.text.trim() != expectedJumlahAnak.trim() ||
        _selectedStatusPTKP != expectedStatusPTKP;
  }

  Future<bool> _showUnsavedChangesDialog(BuildContext context, dynamic theme) async {
    final savedData = ref.read(honorariumDataProvider);
    final result = await SIHAKIConfirmationDialog.show(
      context,
      title: 'Batalkan Perubahan Honorarium',
      message: 'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
      confirmText: 'Batalkan',
      cancelText: 'Batal',
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red[600],
      isDestructive: true,
      onConfirm: () async {
        if (context.mounted) {
          _kartuKeluargaController.text = savedData.kartuKeluarga.isNotEmpty ? savedData.kartuKeluarga : '1111111111111111';
          _ktpController.text = savedData.ktp.isNotEmpty ? savedData.ktp : '0603200310820003';
          _namaKtpController.text = savedData.namaKtp.isNotEmpty ? savedData.namaKtp : 'AIRLANGGA EKA WARDHANA 01';
          _bpjsKesehatanController.text = savedData.bpjsKesehatan.isNotEmpty ? savedData.bpjsKesehatan : '406546495464';
          _npwpController.text = savedData.npwp.isNotEmpty ? savedData.npwp : '111111111111111';
          _namaIbuController.text = savedData.namaIbu.isNotEmpty ? savedData.namaIbu : 'HARTINI WIJAYA';
          _rekeningController.text = savedData.rekening.isNotEmpty ? savedData.rekening : '1582100318';
          _namaPemilikRekController.text = savedData.namaPemilikRek.isNotEmpty ? savedData.namaPemilikRek : 'Bpk. AIRLANGGA EKA WARDHANA';
          _jumlahAnakController.text = savedData.jumlahAnak.isNotEmpty ? savedData.jumlahAnak : '3';
          _selectedStatusPTKP = savedData.statusPTKP.isNotEmpty ? savedData.statusPTKP : 'Kawin (K)';

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('honorarium_has_changes', false);

          setState(() {
            _hasUnsavedChanges = false;
          });

          notification.NotificationUtils.showWarning(
            context,
            'Perubahan pada honorarium telah dibatalkan',
          );

          if (context.mounted) {
            context.pop();
          }
        }
      },
      onCancel: () {},
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_hasUnsavedChanges || _hasUnsavedChangesInternal()) {
          final shouldLeave = await _showUnsavedChangesDialog(context, theme);
          if (shouldLeave && context.mounted) {
            context.pop();
          }
        } else {
          context.pop();
        }
      },
      child: Scaffold(
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
            onPressed: () async {
              if (_hasUnsavedChanges || _hasUnsavedChangesInternal()) {
                final shouldLeave = await _showUnsavedChangesDialog(context, theme);
                if (shouldLeave && context.mounted) {
                  context.pop();
                }
              } else {
                context.pop();
              }
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
                _buildFormDataHonorarium(theme),
                const SizedBox(height: 20),
              ],
            ),
          ),
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
            color: Colors.grey.withOpacity(0.1),
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
            hintText: 'Jika Belum Punya, No. BPJS Kesehatan Diisi Dengan Angka "0" (Nol)',
            keyboardType: TextInputType.number,
            helperText: 'Jika Belum Punya, No. BPJS Kesehatan Diisi Dengan Angka "0" (Nol)',
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
              if (mounted) {
                setState(() {
                  _selectedStatusPTKP = value!;
                  _updateUnsavedChanges();
                });
              }
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
                    'Keterangan: perubahan status PTKP atau Jumlah Tanggungan Anak akan berlaku di awal tahun berikutnya',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                color: theme.primarySwatch.withOpacity(0.1),
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
                    items: items.map((String item) {
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
                    validator: isRequired
                        ? (value) => value == null || value.isEmpty ? 'Field ini wajib diisi' : null
                        : null,
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
                color: theme.primarySwatch.withOpacity(0.1),
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
                    validator: isRequired
                        ? (value) => value == null || value.isEmpty ? 'Field ini wajib diisi' : null
                        : null,
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

  Future<void> _saveData(BuildContext context, dynamic theme) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];
      if (_kartuKeluargaController.text.isEmpty) errors.add('No. Kartu Keluarga harus diisi');
      if (_ktpController.text.isEmpty) errors.add('No. KTP harus diisi');
      if (_namaKtpController.text.isEmpty) errors.add('Nama Sesuai KTP harus diisi');
      if (_bpjsKesehatanController.text.isEmpty) errors.add('No. BPJS Kesehatan harus diisi');
      if (_npwpController.text.isEmpty) errors.add('NPWP harus diisi');
      if (_namaIbuController.text.isEmpty) errors.add('Nama Ibu Kandung harus diisi');
      if (_rekeningController.text.isEmpty) errors.add('No. Rekening harus diisi');
      if (_namaPemilikRekController.text.isEmpty) errors.add('Nama Pemilik Rekening harus diisi');
      if (_selectedStatusPTKP.isEmpty) errors.add('Status PTKP harus dipilih');
      if (_jumlahAnakController.text.isEmpty) errors.add('Jumlah Anak harus diisi');

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      final newData = HonorariumData(
        kartuKeluarga: _kartuKeluargaController.text,
        ktp: _ktpController.text,
        namaKtp: _namaKtpController.text,
        bpjsKesehatan: _bpjsKesehatanController.text,
        npwp: _npwpController.text,
        namaIbu: _namaIbuController.text,
        rekening: _rekeningController.text,
        namaPemilikRek: _namaPemilikRekController.text,
        jumlahAnak: _jumlahAnakController.text,
        statusPTKP: _selectedStatusPTKP,
      );

      ref.read(honorariumDataProvider.notifier).updateData(newData);
      ref.read(profileCompletionProvider.notifier).markCompleted('honorarium');

      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool('honorarium_has_changes', false),
        prefs.setBool('honorarium_just_saved', true),
        prefs.setBool('honorarium_user_saved', true),
      ]);

      await ProfileCompletionNotifierCard.show(
        context,
        title: 'Berhasil Menyimpan Honorarium',
        message: 'Data honorarium Anda telah diperbarui dan tersimpan dengan sukses.',
        onConfirm: () {
          if (context.mounted) {
            notification.NotificationUtils.showSuccess(
              context,
              'Data honorarium telah disimpan',
            );
            setState(() {
              _hasUnsavedChanges = false;
            });
            context.pop('saved');
          }
        },
        icon: Icons.check_circle_rounded,
        iconColor: Colors.green[600],
      );
    }
  }

  void _showErrorDialog(BuildContext context, dynamic theme, String message) {
    notification.NotificationUtils.showErrorDialog(
      context,
      title: 'Gagal Menyimpan',
      message: 'Terjadi kesalahan saat menyimpan honorarium: $message',
      buttonText: 'OK',
    );
  }
}