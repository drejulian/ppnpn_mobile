import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:flutter/services.dart';
// No shared education state; this page returns result via Navigator.pop.

class TambahDataPendidikanPage extends ConsumerStatefulWidget {
  const TambahDataPendidikanPage({super.key});

  @override
  ConsumerState<TambahDataPendidikanPage> createState() =>
      _TambahDataPendidikanPageState();
}

class _TambahDataPendidikanPageState
    extends ConsumerState<TambahDataPendidikanPage> {
  final _formKey = GlobalKey<FormState>();
  final _programStudiController = TextEditingController();
  final _universitasController = TextEditingController();
  // Replace single year controller with start and end year controllers
  final _tahunMulaiController = TextEditingController();
  final _tahunSelesaiController = TextEditingController();

  String? _selectedJenisPendidikan;
  bool _isLoading = false;

  final List<String> _jenisPendidikanList = [
    'SD',
    'SMP',
    'SMA',
    'SMK',
    'D1',
    'D2',
    'D3',
    'D4',
    'Sarjana/S1',
    'S2/Magister',
    'S3/Doktor',
  ];

  @override
  void dispose() {
    _programStudiController.dispose();
    _universitasController.dispose();
    _tahunMulaiController.dispose();
    _tahunSelesaiController.dispose();
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
          'Tambah Data Pendidikan',
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
            context.go("/pendidikan");
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 16.0,
          vertical: 16.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(theme),
              const SizedBox(height: 24),

              // Form Section
              _buildFormSection(theme),
              const SizedBox(height: 32),

              // Save Button
              _buildSaveButton(theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(dynamic theme) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primarySwatch, theme.secondarySwatch],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Riwayat Pendidikan',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lengkapi data pendidikan Anda dengan benar',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(dynamic theme) {
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
          // Jenis Pendidikan Dropdown
          _buildDropdownField(
            theme,
            label: 'Jenis Pendidikan',
            hint: 'Pilih jenis pendidikan',
            value: _selectedJenisPendidikan,
            items: _jenisPendidikanList,
            onChanged:
                (value) => setState(() => _selectedJenisPendidikan = value),
            validator:
                (value) =>
                    value == null ? 'Jenis pendidikan wajib dipilih' : null,
          ),
          const SizedBox(height: 20),

          // Program Studi
          _buildTextFormField(
            theme,
            controller: _programStudiController,
            label: 'Program Studi',
            hint: 'Masukkan program studi/jurusan',
            validator:
                (value) =>
                    value?.isEmpty == true ? 'Program studi wajib diisi' : null,
          ),
          const SizedBox(height: 20),

          // Nama Universitas
          _buildTextFormField(
            theme,
            controller: _universitasController,
            label: 'Nama Universitas',
            hint: 'Masukkan nama universitas/institusi',
            validator:
                (value) =>
                    value?.isEmpty == true
                        ? 'Nama universitas wajib diisi'
                        : null,
          ),
          const SizedBox(height: 20),

          // Tahun Mulai (Start Year)
          _buildTextFormField(
            theme,
            controller: _tahunMulaiController,
            label: 'Tahun Mulai',
            hint: 'contoh: 2019',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4), // Limit to 4 digits
            ],
            validator: (value) {
              if (value?.isEmpty == true) return 'Tahun mulai wajib diisi';
              if (value!.length != 4) return 'Format tahun harus 4 digit';
              final year = int.tryParse(value);
              if (year == null || year < 1950 || year > DateTime.now().year) {
                return 'Tahun tidak valid (1950-${DateTime.now().year})';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Tahun Selesai (End Year)
          _buildTextFormField(
            theme,
            controller: _tahunSelesaiController,
            label: 'Tahun Selesai',
            hint: 'contoh: 2023',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4), // Limit to 4 digits
            ],
            validator: (value) {
              if (value?.isEmpty == true) return 'Tahun selesai wajib diisi';
              if (value!.length != 4) return 'Format tahun harus 4 digit';

              // Compare with start year if both are filled
              if (_tahunMulaiController.text.isNotEmpty) {
                final startYear = int.tryParse(_tahunMulaiController.text);
                final endYear = int.tryParse(value);

                if (startYear != null &&
                    endYear != null &&
                    endYear < startYear) {
                  return 'Tahun selesai tidak boleh kurang dari tahun mulai';
                }
              }

              final year = int.tryParse(value);
              if (year == null ||
                  year < 1950 ||
                  year > DateTime.now().year + 5) {
                return 'Tahun tidak valid (1950-${DateTime.now().year + 5})';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    dynamic theme, {
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String?> validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.typographyRegular.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: theme.typographyRegular.bodySmall.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
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
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextFormField(
    dynamic theme, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required FormFieldValidator<String?> validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.typographyRegular.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: theme.typographyRegular.bodySmall.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
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
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(dynamic theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveData,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primarySwatch,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  'SIMPAN',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
      ),
    );
  }

  void _saveData() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final tahunMulai = _tahunMulaiController.text.trim();
      final tahunSelesai = _tahunSelesaiController.text.trim();

      // Build new education entry with formatted years for display
      final newEducation = <String, String>{
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'jenjang': _selectedJenisPendidikan!,
        'jurusan': _programStudiController.text.trim().toUpperCase(),
        'institusi': _universitasController.text.trim().toUpperCase(),
        'kota': 'JAKARTA', // Default value - could be another field
        'tahun_mulai': tahunMulai,
        'tahun_selesai': tahunSelesai,
        // Add formatted display for the card
        'tahun': '$tahunMulai - $tahunSelesai',
      };

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data pendidikan berhasil disimpan'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Return new item to previous page
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            Navigator.pop(context, {'action': 'add', 'data': newEducation});
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
