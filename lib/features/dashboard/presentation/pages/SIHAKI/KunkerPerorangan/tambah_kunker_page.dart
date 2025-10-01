import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/MenuUtama/notification_provider.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'daftar_pengajuan_kunker_page.dart' show kunkerDataProvider;
import '../../../providers/sihaki/kunker_provider.dart';

class TambahKunkerPeroranganPage extends ConsumerStatefulWidget {
  const TambahKunkerPeroranganPage({super.key});

  @override
  ConsumerState<TambahKunkerPeroranganPage> createState() =>
      _TambahKunkerPeroranganPageState();
}

class _TambahKunkerPeroranganPageState
    extends ConsumerState<TambahKunkerPeroranganPage> {
  final _formKey = GlobalKey<FormState>();

  // Informasi Surat
  final _noSuratController = TextEditingController();
  String _selectedJenisPerjadin = 'Dapil 8x setahun';
  final List<String> _jenisPerjadinOptions = [
    'Dapil 8x setahun',
    'Dapil 10x setahun',
    'Dapil 12x setahun',
  ];
  final _tanggalSuratController = TextEditingController();
  final _tanggalAwalController = TextEditingController();
  final _tanggalAkhirController = TextEditingController();
  String _masaPersidangan = 'II';
  final List<String> _masaPersidanganOptions = ['I', 'II', 'III', 'IV'];
  final _tahunSidangController = TextEditingController(text: '2024-2025');

  // Data Anggota
  final _anggotaController = TextEditingController();
  final _noAnggotaController = TextEditingController();
  final _nikAnggotaController = TextEditingController();
  final _fraksiAnggotaController = TextEditingController();
  final _dapilAnggotaController = TextEditingController();
  final _rekAnggotaController = TextEditingController();
  final _namaRekAnggotaController = TextEditingController();
  final _kodeBankAnggotaController = TextEditingController();
  final _namaBankAnggotaController = TextEditingController();

  // Data TA
  final _taController = TextEditingController();
  final _noTaController = TextEditingController();
  final _nikTaController = TextEditingController();
  final _hpTaController = TextEditingController();
  final _emailTaController = TextEditingController();
  final _rekTaController = TextEditingController();
  final _namaRekTaController = TextEditingController();
  final _kodeBankTaController = TextEditingController();
  final _namaBankTaController = TextEditingController();

  // Detail Perjalanan
  String _modaTransportasi = 'Pesawat';
  final List<String> _modaOptions = ['Pesawat', 'Kereta', 'Kapal', 'Mobil'];
  final _negaraController = TextEditingController(text: 'Indonesia');
  final _provinsiController = TextEditingController();
  final _kotaController = TextEditingController();

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Tambah Kunker Perorangan',
        onBackPressed: () => Navigator.of(context).pop(),
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
                      hintText: 'Wajib diisi',
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
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return null;
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Rekening',
                      _rekTaController,
                      Icons.credit_card,
                      theme,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
        ),
      ),
    );
  }

  Widget _buildCard(
    dynamic theme, {
    required String title,
    required IconData icon,
    required Widget child,
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
                    if (label == 'No. Surat' &&
                        (v == null || v.trim().isEmpty)) {
                      return 'No. Surat wajib diisi';
                    }
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
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
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

  Map<String, dynamic> _collectFormData() {
    return {
      'no_surat': _noSuratController.text.trim(),
      'jenis_perjadin': _selectedJenisPerjadin,
      'tanggal_surat': _tanggalSuratController.text.trim(),
      'tanggal_awal': _tanggalAwalController.text.trim(),
      'tanggal_akhir': _tanggalAkhirController.text.trim(),
      'anggota': _anggotaController.text.trim(),
      'tenaga_ahli':
          _taController.text.trim().isNotEmpty ? _taController.text.trim() : '',
      'dapil': _dapilAnggotaController.text.trim(),
      'status_pengajuan': 'Menunggu Konfirmasi',
      'status_pencairan': '-',

      'masa_persidangan': _masaPersidangan,
      'tahun_sidang': _tahunSidangController.text.trim(),
      'no_anggota': _noAnggotaController.text.trim(),
      'nik_anggota': _nikAnggotaController.text.trim(),
      'fraksi': _fraksiAnggotaController.text.trim(),
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
    };
  }

  void _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final data = _collectFormData();
    if (data['no_surat'].toString().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No. Surat wajib diisi')));
      return;
    }
    
    ref.read(kunkerDataProvider.notifier).addKunker(data);
    
    // Tambahkan notifikasi ke dalam app (page notifikasi)
    ref.read(notificationProvider.notifier).addKunkerNotification(
      noSurat: data['no_surat'].toString(),
      tanggalAwal: data['tanggal_awal'].toString(),
      tanggalAkhir: data['tanggal_akhir'].toString(),
      lokasi: data['lokasi_kunjungan']?.toString() ?? 'Tidak diketahui',
      jenisPerjadin: data['jenis_perjadin']?.toString() ?? _selectedJenisPerjadin,
    );
    
    // Kirim notifikasi lokal langsung
    _showLocalNotification(data);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengajuan kunker ditambahkan dan notifikasi dikirim')),
    );

    try {
      final success = await ref.read(kunkerProvider.notifier).addKunker(data);
      Navigator.pop(context); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pengajuan kunker berhasil ditambahkan'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menambahkan pengajuan kunker'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // Method untuk mengirim notifikasi lokal
  Future<void> _showLocalNotification(Map<String, dynamic> data) async {
    try {
      await NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Kunjungan Kerja Berhasil Diajukan',
        body: 'Kunjungan kerja ${data['no_surat']} ke ${data['lokasi_kunjungan'] ?? 'lokasi'} telah berhasil diajukan.',
        payload: 'kunker_${data['no_surat']}',
      );
    } catch (e) {
      // Jika notifikasi gagal, tidak perlu mengganggu user
      debugPrint('Gagal mengirim notifikasi: $e');
    }
  }
}
