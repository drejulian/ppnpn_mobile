import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import '../keluarga_page.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/family_member.dart'
    as dto;
import 'package:ppnpm_dpr/common/services/profile_service.dart';

class TambahAnggotaKeluargaPage extends ConsumerStatefulWidget {
  const TambahAnggotaKeluargaPage({super.key});

  @override
  ConsumerState<TambahAnggotaKeluargaPage> createState() =>
      _TambahAnggotaKeluargaPageState();
}

class _TambahAnggotaKeluargaPageState
    extends ConsumerState<TambahAnggotaKeluargaPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  final ProfileService _profileService = ProfileService();

  // Text Controllers
  final _namaController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _nikController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _handphoneController = TextEditingController();
  final _bpjsController = TextEditingController();
  final _suratKuliahController = TextEditingController();
  final _tanggalPerkawinanController = TextEditingController();

  // Selected values
  String? _selectedGender;
  String? _selectedAgama;
  String? _selectedHubungan;
  DateTime? _selectedTanggalLahir;
  DateTime? _selectedTanggalPerkawinan;

  // Dropdown options
  final List<String> _genderOptions = ['Laki-Laki', 'Perempuan'];
  final List<String> _agamaOptions = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];
  final List<String> _hubunganOptions = ['Istri', 'Suami', 'Anak'];

  @override
  void dispose() {
    _namaController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _nikController.dispose();
    _pekerjaanController.dispose();
    _handphoneController.dispose();
    _bpjsController.dispose();
    _suratKuliahController.dispose();
    _tanggalPerkawinanController.dispose();
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
        title: 'Tambah Anggota Keluarga',
        onBackPressed: () => context.go('/keluarga'),
        backTooltip: 'Kembali ke keluarga',
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
              // Header Card
              _buildHeaderCard(theme),
              const SizedBox(height: 20),

              // Form Card
              _buildFormCard(theme),
              const SizedBox(height: 20),

              // Note Card
              _buildNoteCard(theme),
              const SizedBox(height: 20),

              // Save Button
              _buildSaveButton(theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primarySwatch, theme.secondarySwatch],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.primarySwatch.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_add, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Anggota Keluarga',
                  style: theme.typographyRegular.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Lengkapi data anggota keluarga baru',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(dynamic theme) {
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
          Text(
            'Data Anggota Keluarga',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),

          // Nama
          _buildTextFormField(
            controller: _namaController,
            label: 'Nama',
            hint: 'Masukkan nama lengkap',
            required: true,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Tempat Lahir
          _buildTextFormField(
            controller: _tempatLahirController,
            label: 'Tempat Lahir',
            hint: 'Masukkan tempat lahir',
            required: true,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Tanggal Lahir
          _buildDateFormField(
            controller: _tanggalLahirController,
            label: 'Tanggal Lahir',
            hint: 'Pilih tanggal lahir',
            selectedDate: _selectedTanggalLahir,
            onDateSelected: (date) {
              setState(() {
                _selectedTanggalLahir = date;
                _tanggalLahirController.text = DateFormat(
                  'dd/MM/yyyy',
                ).format(date);
              });
            },
            required: true,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // NIK
          _buildTextFormField(
            controller: _nikController,
            label: 'No. KTP/NIK',
            hint: 'Masukkan nomor KTP/NIK',
            required: true,
            theme: theme,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 16,
          ),
          const SizedBox(height: 16),

          // Jenis Kelamin
          _buildDropdownFormField(
            value: _selectedGender,
            label: 'Jenis Kelamin',
            hint: 'Pilih jenis kelamin',
            items: _genderOptions,
            onChanged: (value) => setState(() => _selectedGender = value),
            required: true,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Agama
          _buildDropdownFormField(
            value: _selectedAgama,
            label: 'Agama',
            hint: 'Pilih agama',
            items: _agamaOptions,
            onChanged: (value) => setState(() => _selectedAgama = value),
            required: true,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Pekerjaan
          _buildTextFormField(
            controller: _pekerjaanController,
            label: 'Pekerjaan/Sekolah',
            hint: 'Masukkan pekerjaan atau sekolah',
            required: true,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Handphone
          _buildTextFormField(
            controller: _handphoneController,
            label: 'Handphone (WA)',
            hint: 'Masukkan nomor WhatsApp',
            required: true,
            theme: theme,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),

          // No BPJS
          _buildTextFormField(
            controller: _bpjsController,
            label: 'No. BPJS',
            hint: 'Masukkan nomor BPJS (opsional)',
            required: false,
            theme: theme,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),

          // No Surat Kuliah
          _buildTextFormField(
            controller: _suratKuliahController,
            label: 'No. Surat Kuliah',
            hint: 'Masukkan nomor surat kuliah (opsional)',
            required: false,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Tanggal Perkawinan
          _buildDateFormField(
            controller: _tanggalPerkawinanController,
            label: 'Tanggal Perkawinan',
            hint: 'Pilih tanggal perkawinan (opsional)',
            selectedDate: _selectedTanggalPerkawinan,
            onDateSelected: (date) {
              setState(() {
                _selectedTanggalPerkawinan = date;
                _tanggalPerkawinanController.text = DateFormat(
                  'dd/MM/yyyy',
                ).format(date);
              });
            },
            required: false,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Hubungan Keluarga
          _buildDropdownFormField(
            value: _selectedHubungan,
            label: 'Hubungan Keluarga',
            hint: 'Pilih hubungan keluarga',
            items: _hubunganOptions,
            onChanged: (value) => setState(() => _selectedHubungan = value),
            required: true,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keterangan',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hanya istri/suami/anak yang boleh ditambahkan pada Data Keluarga',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(dynamic theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saving ? null : _saveData,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primarySwatch,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child:
            _saving
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool required,
    required dynamic theme,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.typographyRegular.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
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
            counterText: '',
          ),
          validator:
              required
                  ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label wajib diisi';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildDropdownFormField({
    required String? value,
    required String label,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool required,
    required dynamic theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.typographyRegular.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
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
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
          validator:
              required
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label wajib dipilih';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildDateFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required DateTime? selectedDate,
    required ValueChanged<DateTime> onDateSelected,
    required bool required,
    required dynamic theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.typographyRegular.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: const Icon(Icons.calendar_today),
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
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          validator:
              required
                  ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label wajib dipilih';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final hubungan =
          _selectedHubungan == 'Anak' ? 'AK' : _selectedHubungan!.toUpperCase();

      // Create new FamilyMemberDto and add to local SQLite provider
      final newMember = dto.FamilyMemberDto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: _namaController.text.trim(),
        hubungan: hubungan,
        tempatLahir: _tempatLahirController.text.trim(),
        tanggalLahir: _selectedTanggalLahir!,
        jenisKelamin: _selectedGender!,
        pekerjaan: _pekerjaanController.text.trim(),
        tanggalMenikah: _selectedTanggalPerkawinan,
      );
      
      // Add to familyDataProvider
      final currentData = ref.read(familyDataProvider);
      print('TambahKeluarga: Current data length before add: ${currentData.length}');
      final updatedData = [...currentData, newMember];
      print('TambahKeluarga: Updated data length after add: ${updatedData.length}');
      
      ref.read(familyDataProvider.notifier).state = updatedData;
      print('TambahKeluarga: ✅ Data added to provider');
      
      // Also save the entire family data to SQLite to maintain consistency
      await _saveFamilyDataToSQLite(updatedData);
      print('TambahKeluarga: ✅ Data saved to SQLite');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data anggota keluarga berhasil disimpan'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        if (context.canPop()) {
          context.pop('saved'); // Return 'saved' result
        } else {
          context.go('/keluarga');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Save family data to SQLite database
  Future<void> _saveFamilyDataToSQLite(List<dto.FamilyMemberDto> familyList) async {
    try {
      String namaAyah = '';
      String namaIbu = '';
      String namaPasangan = '';
      String namaAnak = '';
      String pekerjaanAyah = '';
      String pekerjaanIbu = '';
      String pekerjaanPasangan = '';

      for (final member in familyList) {
        switch (member.hubungan) {
          case 'AYAH':
            namaAyah = member.nama;
            pekerjaanAyah = member.pekerjaan;
            break;
          case 'IBU':
            namaIbu = member.nama;
            pekerjaanIbu = member.pekerjaan;
            break;
          case 'ISTRI':
          case 'SUAMI':
            namaPasangan = member.nama;
            pekerjaanPasangan = member.pekerjaan;
            break;
          case 'AK':
            if (namaAnak.isEmpty) {
              namaAnak = member.nama;
            } else {
              namaAnak += ', ${member.nama}';
            }
            break;
        }
      }

      // Save to SQLite using ProfileService
      final success = await _profileService.saveKeluargaData(
        namaAyah: namaAyah,
        namaIbu: namaIbu,
        namaPasangan: namaPasangan,
        namaAnak: namaAnak,
        pekerjaanAyah: pekerjaanAyah,
        pekerjaanIbu: pekerjaanIbu,
        pekerjaanPasangan: pekerjaanPasangan,
      );

      if (!success) {
        print('TambahKeluarga: Warning - SQLite save failed');
      } else {
        print('TambahKeluarga: ✅ SQLite save successful');
      }
    } catch (e) {
      print('TambahKeluarga: Error saving to SQLite: $e');
    }
  }
}
