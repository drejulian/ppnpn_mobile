import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
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
  late TextEditingController _negaraController;
  late TextEditingController _provinsiController;
  late TextEditingController _kotaController;

  String _coerceOption(String? raw, List<String> allowed, String fallback) {
    if (raw == null) return fallback;
    final v = raw.toString().trim();

    if (allowed.contains(v)) return v;

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

    // Debug: Print data yang diterima untuk troubleshooting
    print('DEBUG EditKunkerPage: Data received = ${widget.kunkerData}');

    // Informasi Surat
    _noSuratController = TextEditingController(
      text: widget.kunkerData['no_surat']?.toString() ?? '',
    );
    _selectedJenisPerjadin = _coerceOption(
      widget.kunkerData['jenis_perjadin'], 
      _jenisPerjadinOptions, 
      _jenisPerjadinOptions.first
    );
    _tanggalSuratController = TextEditingController(
      text: widget.kunkerData['tanggal_surat']?.toString() ?? '',
    );
    _tanggalAwalController = TextEditingController(
      text: widget.kunkerData['tanggal_awal']?.toString() ?? '',
    );
    _tanggalAkhirController = TextEditingController(
      text: widget.kunkerData['tanggal_akhir']?.toString() ?? '',
    );

    _tahunSidangController = TextEditingController(
      text: widget.kunkerData['tahun_sidang']?.toString() ?? '2024-2025',
    );

    // Data Anggota
    _anggotaController = TextEditingController(
      text: widget.kunkerData['anggota']?.toString() ?? '',
    );
    _noAnggotaController = TextEditingController(
      text: widget.kunkerData['no_anggota']?.toString() ?? '',
    );
    _nikAnggotaController = TextEditingController(
      text: widget.kunkerData['nik_anggota']?.toString() ?? '',
    );
    _fraksiAnggotaController = TextEditingController(
      text: widget.kunkerData['fraksi']?.toString() ?? '',
    );
    _dapilAnggotaController = TextEditingController(
      text: widget.kunkerData['dapil']?.toString() ?? '',
    );
    _rekAnggotaController = TextEditingController(
      text: widget.kunkerData['rek_anggota']?.toString() ?? '',
    );
    _namaRekAnggotaController = TextEditingController(
      text: widget.kunkerData['nama_rek_anggota']?.toString() ?? '',
    );
    _kodeBankAnggotaController = TextEditingController(
      text: widget.kunkerData['kode_bank_anggota']?.toString() ?? '',
    );
    _namaBankAnggotaController = TextEditingController(
      text: widget.kunkerData['nama_bank_anggota']?.toString() ?? '',
    );

    // Data TA
    _taController = TextEditingController(
      text: widget.kunkerData['tenaga_ahli']?.toString() ?? '',
    );
    _noTaController = TextEditingController(
      text: widget.kunkerData['no_ta']?.toString() ?? '',
    );
    _nikTaController = TextEditingController(
      text: widget.kunkerData['nik_ta']?.toString() ?? '',
    );
    _hpTaController = TextEditingController(
      text: widget.kunkerData['hp_ta']?.toString() ?? '',
    );
    _emailTaController = TextEditingController(
      text: widget.kunkerData['email_ta']?.toString() ?? '',
    );
    _rekTaController = TextEditingController(
      text: widget.kunkerData['rek_ta']?.toString() ?? '',
    );
    _namaRekTaController = TextEditingController(
      text: widget.kunkerData['nama_rek_ta']?.toString() ?? '',
    );
    _kodeBankTaController = TextEditingController(
      text: widget.kunkerData['kode_bank_ta']?.toString() ?? '',
    );
    _namaBankTaController = TextEditingController(
      text: widget.kunkerData['nama_bank_ta']?.toString() ?? '',
    );

    // Detail Perjalanan
    _negaraController = TextEditingController(
      text: widget.kunkerData['negara']?.toString() ?? 'Indonesia',
    );
    _provinsiController = TextEditingController(
      text: widget.kunkerData['provinsi']?.toString() ?? '',
    );
    _kotaController = TextEditingController(
      text: widget.kunkerData['kota']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    // Informasi Surat
    _noSuratController.dispose();
    _tanggalSuratController.dispose();
    _tanggalAwalController.dispose();
    _tanggalAkhirController.dispose();
    _tahunSidangController.dispose();
    
    // Data Anggota
    _anggotaController.dispose();
    _noAnggotaController.dispose();
    _nikAnggotaController.dispose();
    _fraksiAnggotaController.dispose();
    _dapilAnggotaController.dispose();
    _rekAnggotaController.dispose();
    _namaRekAnggotaController.dispose();
    _kodeBankAnggotaController.dispose();
    _namaBankAnggotaController.dispose();
    
    // Data TA
    _taController.dispose();
    _noTaController.dispose();
    _nikTaController.dispose();
    _hpTaController.dispose();
    _emailTaController.dispose();
    _rekTaController.dispose();
    _namaRekTaController.dispose();
    _kodeBankTaController.dispose();
    _namaBankTaController.dispose();
    
    // Detail Perjalanan
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
        title: 'Ubah Kunker Perorangan',
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
              _buildStatusRow(theme),
              const SizedBox(height: 16),
              _buildCard(
                theme,
                title: 'Informasi Dasar',
                icon: Icons.description,
                child: Column(
                  children: [
                    _buildTextField(
                      'No. Surat',
                      _noSuratController,
                      Icons.receipt_long,
                      theme,
                      hintText: 'Nomor surat',
                    ),
                    _buildTextField(
                      'Jenis Perjadin',
                      TextEditingController(text: _selectedJenisPerjadin),
                      Icons.category,
                      theme,
                      enabled: false,
                    ),
                    _buildTextField(
                      'Anggota',
                      _anggotaController,
                      Icons.person,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'TA',
                      _taController,
                      Icons.engineering,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Dapil',
                      _dapilAnggotaController,
                      Icons.map,
                      theme,
                      isRequired: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _buildCard(
                theme,
                title: 'Lokasi Perjalanan',
                icon: Icons.map,
                child: Column(
                  children: [
                    _buildTextField(
                      'Negara',
                      _negaraController,
                      Icons.flag,
                      theme,
                      isRequired: true,
                    ),
                    _buildTextField(
                      'Kota',
                      _kotaController,
                      Icons.location_city,
                      theme,
                      isRequired: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _buildCard(
                theme,
                title: 'Tanggal Perjalanan',
                icon: Icons.date_range,
                child: Column(
                  children: [
                    _buildDateField(
                      'Tanggal Awal',
                      _tanggalAwalController,
                      Icons.flight_takeoff,
                      theme,
                      isRequired: true,
                    ),
                    _buildDateField(
                      'Tanggal Akhir',
                      _tanggalAkhirController,
                      Icons.flight_land,
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
                icon: Icons.location_on,
                child: Column(
                  children: [
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
                      'Kota',
                      _kotaController,
                      Icons.location_on,
                      theme,
                      isRequired: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

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

  Widget _buildStatusRow(dynamic theme) {
    String currentStatus = 'diajukan'; // Default status
    Color statusColor = _getStatusColor(currentStatus);

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
          'Status: $currentStatus',
          statusColor,
          Icons.flag,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diajukan':
        return Colors.orange;
      case 'disetujui':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
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



  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Gunakan format yang sesuai dengan KunkerModel.fromUIMap
    final updated = <String, dynamic>{
      'nomor_surat': _noSuratController.text.trim(),
      'keperluan': _selectedJenisPerjadin,
      'tanggal_berangkat': _tanggalAwalController.text.trim(),
      'tanggal_kembali': _tanggalAkhirController.text.trim(),
      'tujuan': '${_provinsiController.text.trim()}, ${_kotaController.text.trim()}',
      'negara': _negaraController.text.trim(),
      'kota': _kotaController.text.trim(),
      'status': 'diajukan', // Default status
      'keterangan': 'Anggota: ${_anggotaController.text.trim()}, TA: ${_taController.text.trim()}, Dapil: ${_dapilAnggotaController.text.trim()}',
    };

    // Get no_surat dengan key yang benar dari toUIMap()
    final noSurat = widget.kunkerData['no_surat']?.toString();
    
    // Debug prints
    print('DEBUG EditKunkerPage: Saving changes...');
    print('DEBUG EditKunkerPage: noSurat = $noSurat');
    print('DEBUG EditKunkerPage: updated data = $updated');
    
    if (noSurat == null || noSurat.isEmpty) {
      _showSnack('No. Surat tidak valid untuk update');
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
      final success = await ref.read(kunkerProvider.notifier).updateKunker(noSurat, updated);
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
