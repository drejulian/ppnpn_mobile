import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/KegiatanRumahAspirasi/daftar_pengajuan_rumah_aspirasi.dart';
import 'package:flutter/services.dart'; // For input formatters

class TambahRumahAspirasiPage extends ConsumerStatefulWidget {
  const TambahRumahAspirasiPage({super.key});

  @override
  ConsumerState<TambahRumahAspirasiPage> createState() => _TambahRumahAspirasiPageState();
}

class _TambahRumahAspirasiPageState
    extends ConsumerState<TambahRumahAspirasiPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController(text: 'Alfian Kadang, M.M.');
  final _npwpController = TextEditingController(text: '81894097956000');
  final _tanggalSuratController = TextEditingController(text: '31-07-2025');
  final _tahunSidangController = TextEditingController(text: '2024-2025');
  final _anggotaController = TextEditingController();
  final _noAnggotaController = TextEditingController();
  final _nikAnggotaController = TextEditingController();
  final _fraksiAnggotaController = TextEditingController();
  final _dapilAnggotaController = TextEditingController();
  final _rekeningController = TextEditingController();
  final _kodeBankController = TextEditingController();
  final _namaBankController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _npwpController.dispose();
    _tanggalSuratController.dispose();
    _tahunSidangController.dispose();
    _anggotaController.dispose();
    _noAnggotaController.dispose();
    _nikAnggotaController.dispose();
    _fraksiAnggotaController.dispose();
    _dapilAnggotaController.dispose();
    _rekeningController.dispose();
    _kodeBankController.dispose();
    _namaBankController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newRumahAspirasi = RumahAspirasi(
        nama: _namaController.text,
        npwp: _npwpController.text,
        tanggalSurat: _tanggalSuratController.text,
        tahunSidang: _tahunSidangController.text,
        noAnggota: _noAnggotaController.text,
        nikAnggota: _nikAnggotaController.text,
        fraksiAnggota: _fraksiAnggotaController.text,
        dapilAnggota: _dapilAnggotaController.text,
        rekening: _rekeningController.text,
        kodeBank: _kodeBankController.text,
        namaBank: _namaBankController.text,
      );

      ref.read(rumahAspirasiDataProvider.notifier).addRumahAspirasi(newRumahAspirasi);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data berhasil disimpan'),
          backgroundColor: ref.read(themeProvider).primarySwatch,
        ),
      );

      context.pop();
    }
  }

  void _cancelForm() {
    _namaController.clear();
    _npwpController.clear();
    _tanggalSuratController.clear();
    _tahunSidangController.clear();
    _anggotaController.clear();
    _noAnggotaController.clear();
    _nikAnggotaController.clear();
    _fraksiAnggotaController.clear();
    _dapilAnggotaController.clear();
    _rekeningController.clear();
    _kodeBankController.clear();
    _namaBankController.clear();
    context.pop();
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
          'Kegiatan Rumah Aspirasi',
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
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
                    Icons.add_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tambah Rumah Aspirasi',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24.0 : 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data Pajak PPNPN Section
                    Container(
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
                                    colors: [Colors.greenAccent],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Data Pajak PPNPN',
                                style: theme.typographyRegular.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            'Nama',
                            _namaController,
                            Icons.person,
                            theme,
                            isRequired: true,
                          ),
                          _buildTextField(
                            'NPWP',
                            _npwpController,
                            Icons.receipt,
                            theme,
                            isRequired: true,
                            isNumeric: true,
                          ),
                          _buildTextField(
                            'Tanggal Surat',
                            _tanggalSuratController,
                            Icons.calendar_today,
                            theme,
                            isRequired: true,
                          ),
                          _buildTextField(
                            'Tahun Sidang',
                            _tahunSidangController,
                            Icons.date_range,
                            theme,
                            isRequired: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Data Anggota Section
                    Container(
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
                                    colors: [Colors.greenAccent],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Data Anggota',
                                style: theme.typographyRegular.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            'Anggota',
                            _anggotaController,
                            Icons.group,
                            theme,
                            isRequired: true,
                          ),
                          _buildTextField(
                            'No. Anggota',
                            _noAnggotaController,
                            Icons.format_list_numbered,
                            theme,
                            isRequired: true,
                            isNumeric: true,
                          ),
                          _buildTextField(
                            'NIK Anggota',
                            _nikAnggotaController,
                            Icons.credit_card,
                            theme,
                            isRequired: true,
                            isNumeric: true,
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
                            Icons.location_on,
                            theme,
                            isRequired: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Data Bank Section
                    Container(
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
                                    colors: [Colors.greenAccent],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Data Bank',
                                style: theme.typographyRegular.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            'Rekening',
                            _rekeningController,
                            Icons.account_balance,
                            theme,
                            isRequired: true,
                            isNumeric: true,
                          ),
                          _buildTextField(
                            'Kode Bank',
                            _kodeBankController,
                            Icons.numbers,
                            theme,
                            isRequired: true,
                            isNumeric: true,
                          ),
                          _buildTextField(
                            'Nama Bank',
                            _namaBankController,
                            Icons.business,
                            theme,
                            isRequired: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Action Buttons
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _saveForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primarySwatch,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Simpan',
                              style: theme.typographyRegular.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: _cancelForm,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.primarySwatch,
                              side: BorderSide(color: theme.primarySwatch),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Batal',
                              style: theme.typographyRegular.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.primarySwatch,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hubungi Kami functionality not implemented'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'HUBUNGI KAMI',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    bool isLast = false,
    bool isNumeric = false,
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
              child: Icon(
                icon,
                color: theme.primarySwatch,
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
                    keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
                    inputFormatters: isNumeric
                        ? [FilteringTextInputFormatter.digitsOnly]
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
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      if (isRequired && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      if (isNumeric && value != null && !RegExp(r'^\d+$').hasMatch(value)) {
                        return 'Field ini harus diisi dengan angka';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(
            color: Colors.grey[200],
            thickness: 1,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}