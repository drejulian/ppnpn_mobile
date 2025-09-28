import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import '../../../providers/sihaki/kunker_provider.dart';

class EditKunkerPeroranganPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> kunkerData;
  const EditKunkerPeroranganPage({Key? key, required this.kunkerData})
    : super(key: key);

  @override
  ConsumerState<EditKunkerPeroranganPage> createState() =>
      _EditKunkerPeroranganPageState();
}

class _EditKunkerPeroranganPageState
    extends ConsumerState<EditKunkerPeroranganPage> {
  final _formKey = GlobalKey<FormState>();

  // Informasi Surat
  late TextEditingController _noSuratController;
  String _selectedJenisPerjadin = 'Dapil 8x setahun';
  final List<String> _jenisPerjadinOptions = [
    'Dapil 8x setahun',
    'Dapil 10x setahun',
    'Dapil 12x setahun',
  ];
  late TextEditingController _tanggalSuratController;
  late TextEditingController _tanggalAwalController;
  late TextEditingController _tanggalAkhirController;
  String _masaPersidangan = 'II';
  final List<String> _masaPersidanganOptions = ['I', 'II', 'III', 'IV'];
  late TextEditingController _tahunSidangController;

  // Data Anggota
  late TextEditingController _anggotaController;
  late TextEditingController _noAnggotaController;
  late TextEditingController _nikAnggotaController;
  late TextEditingController _fraksiAnggotaController;
  late TextEditingController _dapilAnggotaController;
  late TextEditingController _rekAnggotaController;
  late TextEditingController _namaRekAnggotaController;
  late TextEditingController _kodeBankAnggotaController;
  late TextEditingController _namaBankAnggotaController;

  // Data TA
  late TextEditingController _taController;
  late TextEditingController _noTaController;
  late TextEditingController _nikTaController;
  late TextEditingController _hpTaController;
  late TextEditingController _emailTaController;
  late TextEditingController _rekTaController;
  late TextEditingController _namaRekTaController;
  late TextEditingController _kodeBankTaController;
  late TextEditingController _namaBankTaController;

  // Detail Perjalanan
  String _modaTransportasi = 'Pesawat';
  final List<String> _modaOptions = ['Pesawat', 'Kereta', 'Kapal', 'Mobil'];
  late TextEditingController _negaraController;
  late TextEditingController _provinsiController;
  late TextEditingController _kotaController;

  // Status
  late String _statusPengajuan;
  late String _statusPencairan;
  final List<String> _statusPengajuanOptions = [
    'Menunggu Konfirmasi',
    'Konfirmasi',
  ];
  final List<String> _statusPencairanOptions = ['-', 'Disetujui', 'Ditolak'];

  // Helper to coerce any incoming string into one of the allowed options
  String _coerceOption(String? raw, List<String> allowed, String fallback) {
    if (raw == null) return fallback;
    final v = raw.toString().trim();
    // Exact match
    if (allowed.contains(v)) return v;
    // Case-insensitive match
    final ci = allowed.firstWhere(
      (o) => o.toLowerCase() == v.toLowerCase(),
      orElse: () => '',
    );
    if (ci.isNotEmpty) return ci;
    return fallback;
  }

  @override
  void initState() {
    super.initState();

    // Map existing data or defaults
    _noSuratController = TextEditingController(
      text: widget.kunkerData['no_surat'] ?? '',
    );
    _selectedJenisPerjadin = _coerceOption(
      widget.kunkerData['jenis_perjadin'],
      _jenisPerjadinOptions,
      _jenisPerjadinOptions.first,
    );
    _tanggalSuratController = TextEditingController(
      text: widget.kunkerData['tanggal_surat'] ?? '',
    );
    _tanggalAwalController = TextEditingController(
      text: widget.kunkerData['tanggal_awal'] ?? '',
    );
    _tanggalAkhirController = TextEditingController(
      text: widget.kunkerData['tanggal_akhir'] ?? '',
    );
    _masaPersidangan = _coerceOption(
      widget.kunkerData['masa_persidangan'],
      _masaPersidanganOptions,
      _masaPersidangan,
    );
    _tahunSidangController = TextEditingController(
      text: widget.kunkerData['tahun_sidang'] ?? '2024-2025',
    );

    _anggotaController = TextEditingController(
      text: widget.kunkerData['anggota'] ?? '',
    );
    _noAnggotaController = TextEditingController(
      text: widget.kunkerData['no_anggota'] ?? '',
    );
    _nikAnggotaController = TextEditingController(
      text: widget.kunkerData['nik_anggota'] ?? '',
    );
    _fraksiAnggotaController = TextEditingController(
      text: widget.kunkerData['fraksi'] ?? '',
    );
    _dapilAnggotaController = TextEditingController(
      text: widget.kunkerData['dapil'] ?? '',
    );
    _rekAnggotaController = TextEditingController(
      text: widget.kunkerData['rek_anggota'] ?? '',
    );
    _namaRekAnggotaController = TextEditingController(
      text: widget.kunkerData['nama_rek_anggota'] ?? '',
    );
    _kodeBankAnggotaController = TextEditingController(
      text: widget.kunkerData['kode_bank_anggota'] ?? '',
    );
    _namaBankAnggotaController = TextEditingController(
      text: widget.kunkerData['nama_bank_anggota'] ?? '',
    );

    _taController = TextEditingController(text: widget.kunkerData['ta'] ?? '');
    _noTaController = TextEditingController(
      text: widget.kunkerData['no_ta'] ?? '',
    );
    _nikTaController = TextEditingController(
      text: widget.kunkerData['nik_ta'] ?? '',
    );
    _hpTaController = TextEditingController(
      text: widget.kunkerData['hp_ta'] ?? '',
    );
    _emailTaController = TextEditingController(
      text: widget.kunkerData['email_ta'] ?? '',
    );
    _rekTaController = TextEditingController(
      text: widget.kunkerData['rek_ta'] ?? '',
    );
    _namaRekTaController = TextEditingController(
      text: widget.kunkerData['nama_rek_ta'] ?? '',
    );
    _kodeBankTaController = TextEditingController(
      text: widget.kunkerData['kode_bank_ta'] ?? '',
    );
    _namaBankTaController = TextEditingController(
      text: widget.kunkerData['nama_bank_ta'] ?? '',
    );

    _modaTransportasi = _coerceOption(
      widget.kunkerData['moda'],
      _modaOptions,
      _modaTransportasi,
    );
    _negaraController = TextEditingController(
      text: widget.kunkerData['negara'] ?? 'Indonesia',
    );
    _provinsiController = TextEditingController(
      text: widget.kunkerData['provinsi'] ?? '',
    );
    _kotaController = TextEditingController(
      text: widget.kunkerData['kota'] ?? '',
    );

    _statusPengajuan = _coerceOption(
      widget.kunkerData['status_pengajuan'],
      _statusPengajuanOptions,
      _statusPengajuanOptions.first,
    );
    _statusPencairan = _coerceOption(
      widget.kunkerData['status_pencairan'],
      _statusPencairanOptions,
      _statusPencairanOptions.first,
    );
  }

  @override
  void dispose() {
    _noSuratController.dispose();
    _tanggalSuratController.dispose();
    _tanggalAwalController.dispose();
    _tanggalAkhirController.dispose();
    _tahunSidangController.dispose();
    _anggotaController.dispose();
    _noAnggotaController.dispose();
    _nikAnggotaController.dispose();
    _fraksiAnggotaController.dispose();
    _dapilAnggotaController.dispose();
    _rekAnggotaController.dispose();
    _namaRekAnggotaController.dispose();
    _kodeBankAnggotaController.dispose();
    _namaBankAnggotaController.dispose();
    _taController.dispose();
    _noTaController.dispose();
    _nikTaController.dispose();
    _hpTaController.dispose();
    _emailTaController.dispose();
    _rekTaController.dispose();
    _namaRekTaController.dispose();
    _kodeBankTaController.dispose();
    _namaBankTaController.dispose();
    _negaraController.dispose();
    _provinsiController.dispose();
    _kotaController.dispose();
    super.dispose();
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
          'EDIT KUNKER PERORANGAN',
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
              _buildStatusRow(theme),
              const SizedBox(height: 16),
              _buildCard(
                theme,
                title: 'Informasi Surat',
                icon: Icons.description,
                child: Column(
                  children: [
                    _buildTextField(
                      'No. Surat',
                      _noSuratController,
                      Icons.receipt_long,
                      theme,
                      enabled: false,
                      hintText: 'Tidak dapat diubah',
                      isRequired: true,
                    ),
                    _buildDropdownField(
                      'Jenis Perjadin',
                      _selectedJenisPerjadin,
                      _jenisPerjadinOptions,
                      Icons.category,
                      theme,
                      (v) => setState(
                        () =>
                            _selectedJenisPerjadin =
                                v ?? _selectedJenisPerjadin,
                      ),
                      isRequired: true,
                    ),
                    _buildDateField(
                      'Tanggal Surat',
                      _tanggalSuratController,
                      Icons.event,
                      theme,
                      isRequired: true,
                    ),
                    _buildDateField(
                      'Tanggal Awal',
                      _tanggalAwalController,
                      Icons.event,
                      theme,
                      isRequired: true,
                    ),
                    _buildDateField(
                      'Tanggal Akhir',
                      _tanggalAkhirController,
                      Icons.event,
                      theme,
                      isRequired: true,
                    ),
                    _buildDropdownField(
                      'Masa Persidangan',
                      _masaPersidangan,
                      _masaPersidanganOptions,
                      Icons.schedule,
                      theme,
                      (v) => setState(
                        () => _masaPersidangan = v ?? _masaPersidangan,
                      ),
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Tahun Sidang',
                      _tahunSidangController,
                      Icons.calendar_month,
                      theme,
                      isRequired: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _buildCard(
                theme,
                title: 'Data Anggota',
                icon: Icons.group,
                leadingCheck: true,
                child: Column(
                  children: [
                    _buildTextField(
                      'Anggota',
                      _anggotaController,
                      Icons.person,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'No. Anggota',
                      _noAnggotaController,
                      Icons.numbers,
                      theme,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      isRequired: true,
                    ),
                    _buildTextField(
                      'NIK Anggota',
                      _nikAnggotaController,
                      Icons.badge,
                      theme,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Fraksi Anggota',
                      _fraksiAnggotaController,
                      Icons.group_work,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Dapil Anggota',
                      _dapilAnggotaController,
                      Icons.map,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Rekening',
                      _rekAnggotaController,
                      Icons.credit_card,
                      theme,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Nama Rekening',
                      _namaRekAnggotaController,
                      Icons.person_outline,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Kode Bank',
                      _kodeBankAnggotaController,
                      Icons.qr_code,
                      theme,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Nama Bank',
                      _namaBankAnggotaController,
                      Icons.account_balance,
                      theme,
                      isRequired: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _buildCard(
                theme,
                title: 'Data Tenaga Ahli (TA)',
                icon: Icons.engineering,
                leadingCheck: true,
                child: Column(
                  children: [
                    _buildTextField(
                      'TA',
                      _taController,
                      Icons.person,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'No. TA',
                      _noTaController,
                      Icons.numbers,
                      theme,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      isRequired: true,
                    ),
                    _buildTextField(
                      'NIK TA',
                      _nikTaController,
                      Icons.badge,
                      theme,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      isRequired: true,
                    ),
                    _buildTextField(
                      'No. HP TA',
                      _hpTaController,
                      Icons.phone,
                      theme,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Email TA',
                      _emailTaController,
                      Icons.email,
                      theme,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Email TA wajib diisi';
                        final emailRegex = RegExp(r'^\S+@\S+\.\S+$');
                        if (!emailRegex.hasMatch(v)) return 'Email tidak valid';
                        return null;
                      },
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Rekening',
                      _rekTaController,
                      Icons.credit_card,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Nama Rekening',
                      _namaRekTaController,
                      Icons.person_outline,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Kode Bank',
                      _kodeBankTaController,
                      Icons.qr_code,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Nama Bank',
                      _namaBankTaController,
                      Icons.account_balance,
                      theme,
                      isRequired: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _buildCard(
                theme,
                title: 'Detail Perjalanan',
                icon: Icons.airplanemode_active,
                child: Column(
                  children: [
                    _buildDropdownField(
                      'Moda Transportasi',
                      _modaTransportasi,
                      _modaOptions,
                      Icons.directions_car,
                      theme,
                      (v) => setState(
                        () => _modaTransportasi = v ?? _modaTransportasi,
                      ),
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Negara',
                      _negaraController,
                      Icons.flag,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Provinsi',
                      _provinsiController,
                      Icons.location_city,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Kabupaten/Kota',
                      _kotaController,
                      Icons.location_on,
                      theme,
                      isRequired: true,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                () => _showSnack(
                                  'Rincian Perkiraan Biaya (Anggota)',
                                ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.primarySwatch,
                              side: BorderSide(color: theme.primarySwatch),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                            ),
                            child: const Text(
                              'Rincian Perkiraan Biaya (Anggota)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                () =>
                                    _showSnack('Rincian Perkiraan Biaya (TA)'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.primarySwatch,
                              side: BorderSide(color: theme.primarySwatch),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                            ),
                            child: const Text('Rincian Perkiraan Biaya (TA)'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Status is admin-controlled; editable card removed.
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'SIMPAN PERUBAHAN',
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
      ),
    );
  }

  // UI helpers
  Widget _buildStatusRow(dynamic theme) {
    Color pengajuanColor =
        _statusPengajuan == 'Konfirmasi' ? Colors.green : Colors.orange;
    Color pencairanColor =
        _statusPencairan == 'Disetujui'
            ? Colors.green
            : (_statusPencairan == 'Ditolak' ? Colors.red : Colors.grey);

    Widget chip(String label, Color color, IconData icon) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.typographyRegular.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(
          'Status Pengajuan: $_statusPengajuan',
          pengajuanColor,
          Icons.verified_user,
        ),
        chip(
          'Status Pencairan: $_statusPencairan',
          pencairanColor,
          Icons.payments,
        ),
      ],
    );
  }

  Widget _buildCard(
    dynamic theme, {
    required String title,
    required IconData icon,
    required Widget child,
    bool leadingCheck = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
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
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool enabled = true,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  enabled
                      ? theme.primarySwatch.withOpacity(0.08)
                      : Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: enabled ? theme.primarySwatch : Colors.grey,
              size: 18,
            ),
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
                  enabled: enabled,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  validator: (v) {
                    if (isRequired && (v == null || v.trim().isEmpty)) {
                      return '$label wajib diisi';
                    }
                    if (validator != null) return validator(v);
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: hintText,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.primarySwatch),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: !enabled,
                    fillColor: !enabled ? Colors.grey[100] : null,
                    hintStyle: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: enabled ? Colors.grey[800] : Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.primarySwatch.withOpacity(0.08),
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
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      controller.text =
                          "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: controller,
                      validator: (v) {
                        if (isRequired && (v == null || v.trim().isEmpty)) {
                          return '$label wajib diisi';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Pilih tanggal',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
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
                  ),
                ),
              ],
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
    dynamic theme,
    Function(String?) onChanged, {
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.primarySwatch.withOpacity(0.08),
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
                      vertical: 12,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.primarySwatch),
                    ),
                  ),
                  items:
                      items
                          .map(
                            (String v) => DropdownMenuItem<String>(
                              value: v,
                              child: Text(v),
                            ),
                          )
                          .toList(),
                  onChanged: onChanged,
                  validator: (v) {
                    if (isRequired && (v == null || v.isEmpty)) {
                      return '$label wajib dipilih';
                    }
                    if (validator != null) return validator(v);
                    return null;
                  },
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Build updated map (preserve no_surat as identifier)
    final updated = <String, dynamic>{
      'no_surat': _noSuratController.text.trim(),
      'jenis_perjadin': _selectedJenisPerjadin,
      'tanggal_surat': _tanggalSuratController.text.trim(),
      'tanggal_awal': _tanggalAwalController.text.trim(),
      'tanggal_akhir': _tanggalAkhirController.text.trim(),
      'masa_persidangan': _masaPersidangan,
      'tahun_sidang': _tahunSidangController.text.trim(),
      'anggota': _anggotaController.text.trim(),
      'no_anggota': _noAnggotaController.text.trim(),
      'nik_anggota': _nikAnggotaController.text.trim(),
      'fraksi': _fraksiAnggotaController.text.trim(),
      'dapil': _dapilAnggotaController.text.trim(),
      'rek_anggota': _rekAnggotaController.text.trim(),
      'nama_rek_anggota': _namaRekAnggotaController.text.trim(),
      'kode_bank_anggota': _kodeBankAnggotaController.text.trim(),
      'nama_bank_anggota': _namaBankAnggotaController.text.trim(),
      'ta': _taController.text.trim(),
      'no_ta': _noTaController.text.trim(),
      'nik_ta': _nikTaController.text.trim(),
      'hp_ta': _hpTaController.text.trim(),
      'email_ta': _emailTaController.text.trim(),
      'rek_ta': _rekTaController.text.trim(),
      'nama_rek_ta': _namaRekTaController.text.trim(),
      'kode_bank_ta': _kodeBankTaController.text.trim(),
      'nama_bank_ta': _namaBankTaController.text.trim(),
      'moda': _modaTransportasi,
      'negara': _negaraController.text.trim(),
      'provinsi': _provinsiController.text.trim(),
      'kota': _kotaController.text.trim(),
      'status_pengajuan': _statusPengajuan,
      'status_pencairan': _statusPencairan,
    };

    final keyNoSurat = widget.kunkerData['no_surat']?.toString() ?? '';
    if (keyNoSurat.isEmpty) {
      _showSnack('No. Surat tidak valid');
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success = await ref.read(kunkerProvider.notifier).updateKunker(keyNoSurat, updated);
      Navigator.pop(context); // Close loading dialog

      if (success) {
        _showSnack('Perubahan berhasil disimpan');
        Navigator.pop(context);
      } else {
        _showSnack('Gagal menyimpan perubahan');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showSnack('Error: $e');
    }
  }
}
