import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:flutter/services.dart';

class EditDataPendidikanPage extends ConsumerStatefulWidget {
  final Map<String, String>? educationToEdit;

  const EditDataPendidikanPage({super.key, this.educationToEdit});

  @override
  ConsumerState<EditDataPendidikanPage> createState() =>
      _EditDataPendidikanPageState();
}

class _EditDataPendidikanPageState
    extends ConsumerState<EditDataPendidikanPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _jurusanController;
  late TextEditingController _institusiController;
  late TextEditingController _kotaController;
  late TextEditingController _tahunMulaiController;
  late TextEditingController _tahunSelesaiController;

  String? _selectedJenjang;
  bool _isLoading = false;

  final List<String> _jenjangOptions = [
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
  void initState() {
    super.initState();
    _selectedJenjang = widget.educationToEdit?['jenjang'];
    _jurusanController = TextEditingController(
      text: widget.educationToEdit?['jurusan'] ?? '',
    );
    _institusiController = TextEditingController(
      text: widget.educationToEdit?['institusi'] ?? '',
    );
    _kotaController = TextEditingController(
      text: widget.educationToEdit?['kota'] ?? '',
    );

 
    String? tahunMulai = widget.educationToEdit?['tahun_mulai'];
    String? tahunSelesai = widget.educationToEdit?['tahun_selesai'];

    if ((tahunMulai == null || tahunSelesai == null) &&
        widget.educationToEdit?['tahun'] != null) {
      final parts = widget.educationToEdit?['tahun']?.split('-');
      if (parts != null && parts.length == 2) {
        tahunMulai = parts[0].trim();
        tahunSelesai = parts[1].trim();
      }
    }

    _tahunMulaiController = TextEditingController(text: tahunMulai ?? '');
    _tahunSelesaiController = TextEditingController(text: tahunSelesai ?? '');
  }

  @override
  void dispose() {
    _jurusanController.dispose();
    _institusiController.dispose();
    _kotaController.dispose();
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
          'Edit Data Pendidikan',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(theme),
              const SizedBox(height: 24),

              _buildFormSection(theme),
              const SizedBox(height: 32),

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
                  'Edit Riwayat Pendidikan',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${widget.educationToEdit?['id'] ?? '-'}',
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
          // Jenis Pendidikan
          _buildDropdownField(
            theme,
            label: 'Jenis Pendidikan',
            hint: 'Pilih jenis pendidikan',
            value: _selectedJenjang,
            items: _jenjangOptions,
            onChanged: (value) => setState(() => _selectedJenjang = value),
            validator:
                (value) =>
                    value == null ? 'Jenis pendidikan wajib dipilih' : null,
          ),
          const SizedBox(height: 20),

          // Program Studi
          _buildTextFormField(
            theme,
            controller: _jurusanController,
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
            controller: _institusiController,
            label: 'Nama Universitas',
            hint: 'Masukkan nama universitas/institusi',
            validator:
                (value) =>
                    value?.isEmpty == true
                        ? 'Nama universitas wajib diisi'
                        : null,
          ),
          const SizedBox(height: 20),

          // Kota
          _buildTextFormField(
            theme,
            controller: _kotaController,
            label: 'Kota',
            hint: 'Masukkan kota',
            validator:
                (value) => value?.isEmpty == true ? 'Kota wajib diisi' : null,
          ),
          const SizedBox(height: 20),

          // Tahun Mulai
          _buildTextFormField(
            theme,
            controller: _tahunMulaiController,
            label: 'Tahun Mulai',
            hint: 'contoh: 2019',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
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

          // Tahun Selesai
          _buildTextFormField(
            theme,
            controller: _tahunSelesaiController,
            label: 'Tahun Selesai',
            hint: 'contoh: 2023',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            validator: (value) {
              if (value?.isEmpty == true) return 'Tahun selesai wajib diisi';
              if (value!.length != 4) return 'Format tahun harus 4 digit';

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
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveEducationData,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primarySwatch,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        icon:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Icon(Icons.save, size: 20),
        label: Text(
          'SIMPAN PERUBAHAN',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _saveEducationData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {

      await Future.delayed(const Duration(milliseconds: 500));

      final tahunMulai = _tahunMulaiController.text.trim();
      final tahunSelesai = _tahunSelesaiController.text.trim();

      final updated = <String, String>{
        'id':
            widget.educationToEdit?['id'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'jenjang': _selectedJenjang!,
        'jurusan': _jurusanController.text.trim().toUpperCase(),
        'institusi': _institusiController.text.trim().toUpperCase(),
        'kota': _kotaController.text.trim().toUpperCase(),
        'tahun_mulai': tahunMulai,
        'tahun_selesai': tahunSelesai,

        'tahun': '$tahunMulai - $tahunSelesai',

        'isDummy': 'false',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pendidikan berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, {'action': 'edit', 'data': updated});
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
