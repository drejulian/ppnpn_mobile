import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/DataBPJS/data_bpjs_page.dart';
import 'package:flutter/services.dart'; // For input formatters

class DaftarPengajuanBPJS extends ConsumerStatefulWidget {
  const DaftarPengajuanBPJS({super.key});

  @override
  ConsumerState<DaftarPengajuanBPJS> createState() => _DaftarPengajuanBPJSState();
}

class _DaftarPengajuanBPJSState
    extends ConsumerState<DaftarPengajuanBPJS> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController(text: 'Alfian Kadang, M.M.');
  final _noBPJSController = TextEditingController(text: '000112233445566');
  final _tanggalBerlakuController = TextEditingController(text: '31-07-2025');
  final _jenisAnggotaController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _noBPJSController.dispose();
    _tanggalBerlakuController.dispose();
    _jenisAnggotaController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newBPJSData = BPJSData(
        nama: _namaController.text,
        noBPJS: _noBPJSController.text,
        tanggalBerlaku: _tanggalBerlakuController.text,
        jenisAnggota: _jenisAnggotaController.text,
      );

      ref.read(bpjsDataProvider.notifier).addBPJSData(newBPJSData);

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
    _noBPJSController.clear();
    _tanggalBerlakuController.clear();
    _jenisAnggotaController.clear();
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
          'Data BPJS',
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
                  'Tambah Data BPJS',
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
                    // Data Pribadi Section
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
                                'Data Pribadi',
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
                            'Nomor BPJS',
                            _noBPJSController,
                            Icons.receipt,
                            theme,
                            isRequired: true,
                            isNumeric: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Data Keanggotaan Section
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
                                'Data Keanggotaan',
                                style: theme.typographyRegular.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            'Tanggal Berlaku',
                            _tanggalBerlakuController,
                            Icons.calendar_today,
                            theme,
                            isRequired: true,
                          ),
                          _buildTextField(
                            'Jenis Anggota',
                            _jenisAnggotaController,
                            Icons.group,
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