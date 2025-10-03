import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/keluarga_page.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/family_member.dart'
    as dto;
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';

// SQLite-only implementation - no more API provider needed

class EditDataKeluargaPage extends ConsumerStatefulWidget {
  final String? memberId;

  const EditDataKeluargaPage({super.key, this.memberId});

  @override
  ConsumerState<EditDataKeluargaPage> createState() =>
      _EditDataKeluargaPageState();
}

class _EditDataKeluargaPageState extends ConsumerState<EditDataKeluargaPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _loadedRemote = false;

  // Form controllers
  final _namaController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _pekerjaanController = TextEditingController();

  // Form values
  String? _selectedHubungan;
  String? _selectedJenisKelamin;
  DateTime? _tanggalLahir;
  DateTime? _tanggalMenikah;

  // Options
  final List<String> _hubunganOptions = ['ISTRI', 'SUAMI', 'AK', 'AYAH', 'IBU'];
  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];

  bool _isEditing = false;
  dto.FamilyMemberDto? _editingMember;

  @override
  void initState() {
    super.initState();
    _checkIfEditing();
  }

  void _checkIfEditing() {
    if (widget.memberId != null) {
      _isEditing = true;
      // Prefill from local seed if present; remote will override later
      final familyMembers = ref.read(familyDataProvider);
      dto.FamilyMemberDto? match;
      for (final m in familyMembers) {
        if (m.id == widget.memberId) {
          match = m;
          break;
        }
      }
      if (match != null) {
        _editingMember = match;
        _populateFormWithExistingData();
      }
    }
  }

  void _populateFormWithExistingData() {
    if (_editingMember != null) {
      _namaController.text = _editingMember!.nama;
      _tempatLahirController.text = _editingMember!.tempatLahir;
      _pekerjaanController.text = _editingMember!.pekerjaan;
      _selectedHubungan = _editingMember!.hubungan;
      _selectedJenisKelamin = _editingMember!.jenisKelamin;
      _tanggalLahir = _editingMember!.tanggalLahir;
      _tanggalMenikah = _editingMember!.tanggalMenikah;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tempatLahirController.dispose();
    _pekerjaanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final isEditingWithId = _isEditing && widget.memberId != null;
    // Get member data from SQLite via familyDataProvider
    if (isEditingWithId && !_loadedRemote) {
      final familyData = ref.watch(familyDataProvider);
      try {
        final member = familyData.firstWhere(
          (m) => m.id == widget.memberId,
        );
        _editingMember = member;
        _populateFormWithExistingData();
        _loadedRemote = true;
      } catch (e) {
        // Member not found, handle error or navigate back
        print('Edit: Member with id ${widget.memberId} not found');
      }
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppCustomAppBar(
        title: _isEditing ? 'Edit Data Keluarga' : 'Tambah Data Keluarga',
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/keluarga');
          }
        },
        backTooltip: 'Kembali ke halaman keluarga',
        backgroundColor: Colors.white,
        titleColor: theme.primarySwatch,
        iconColor: theme.primarySwatch,
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
              // Header Info
              _buildHeaderInfo(theme),
              const SizedBox(height: 20),

              // Form Fields
              _buildFormSection(theme),
              const SizedBox(height: 30),

              // Save Button
              _buildSaveButton(theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(dynamic theme) {
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isEditing ? Icons.edit : Icons.person_add,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing
                      ? 'Edit Data Anggota Keluarga'
                      : 'Tambah Anggota Keluarga Baru',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditing
                      ? 'Perbarui informasi ${_editingMember?.nama ?? ''}'
                      : 'Lengkapi formulir di bawah untuk menambah anggota keluarga',
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
          // Section Header
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
                  Icons.assignment,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informasi Anggota Keluarga',
                style: theme.typographyRegular.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Nama Lengkap
          _buildTextFormField(
            controller: _namaController,
            label: 'Nama Lengkap',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama lengkap harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Hubungan Keluarga
          _buildDropdownField(
            label: 'Hubungan Keluarga',
            icon: Icons.family_restroom,
            value: _selectedHubungan,
            items: _hubunganOptions,
            onChanged: (value) => setState(() => _selectedHubungan = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Hubungan keluarga harus dipilih';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Tempat Lahir
          _buildTextFormField(
            controller: _tempatLahirController,
            label: 'Tempat Lahir',
            icon: Icons.location_on,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tempat lahir harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Tanggal Lahir
          _buildDateField(
            label: 'Tanggal Lahir',
            icon: Icons.cake,
            selectedDate: _tanggalLahir,
            onDateSelected: (date) => setState(() => _tanggalLahir = date),
            validator: () {
              if (_tanggalLahir == null) {
                return 'Tanggal lahir harus dipilih';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Jenis Kelamin
          _buildDropdownField(
            label: 'Jenis Kelamin',
            icon: Icons.wc,
            value: _selectedJenisKelamin,
            items: _jenisKelaminOptions,
            onChanged: (value) => setState(() => _selectedJenisKelamin = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jenis kelamin harus dipilih';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Pekerjaan
          _buildTextFormField(
            controller: _pekerjaanController,
            label: 'Pekerjaan',
            icon: Icons.work,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pekerjaan harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Tanggal Menikah (Optional)
          if (_selectedHubungan == 'ISTRI' || _selectedHubungan == 'SUAMI') ...[
            _buildDateField(
              label: 'Tanggal Menikah (Opsional)',
              icon: Icons.favorite,
              selectedDate: _tanggalMenikah,
              onDateSelected: (date) => setState(() => _tanggalMenikah = date),
              isOptional: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
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

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
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
                  child: Text(_getHubunganLabel(item)),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required void Function(DateTime) onDateSelected,
    String? Function()? validator,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        FormField<DateTime>(
          validator: isOptional ? null : (_) => validator?.call(),
          builder:
              (field) => GestureDetector(
                onTap: () => _selectDate(context, selectedDate, onDateSelected),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: field.hasError ? Colors.red : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedDate != null
                              ? DateFormat(
                                'dd MMMM yyyy',
                                'id_ID',
                              ).format(selectedDate)
                              : 'Pilih tanggal',
                          style: TextStyle(
                            color:
                                selectedDate != null
                                    ? Colors.grey[800]
                                    : Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ],
                  ),
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
        onPressed: _saving ? null : _saveData,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primarySwatch,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon:
            _saving
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Icon(_isEditing ? Icons.update : Icons.save, size: 20),
        label: Text(
          _isEditing ? 'UPDATE DATA' : 'SIMPAN DATA',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  String _getHubunganLabel(String hubungan) {
    switch (hubungan.toUpperCase()) {
      case 'ISTRI':
        return 'Istri';
      case 'SUAMI':
        return 'Suami';
      case 'AK':
        return 'Anak';
      case 'AYAH':
        return 'Ayah';
      case 'IBU':
        return 'Ibu';
      default:
        return hubungan;
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    void Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate() || _tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua field yang wajib diisi'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isEditing && widget.memberId != null) {
        // Update existing member in SQLite provider
        final updatedMember = dto.FamilyMemberDto(
          id: widget.memberId!,
          nama: _namaController.text.trim(),
          hubungan: _selectedHubungan!,
          tempatLahir: _tempatLahirController.text.trim(),
          tanggalLahir: _tanggalLahir!,
          jenisKelamin: _selectedJenisKelamin!,
          pekerjaan: _pekerjaanController.text.trim(),
          tanggalMenikah: _tanggalMenikah,
        );
        
        final currentData = ref.read(familyDataProvider);
        final updatedData = currentData.map((member) {
          return member.id == widget.memberId ? updatedMember : member;
        }).toList();
        ref.read(familyDataProvider.notifier).state = updatedData;
      } else {
        // Create new member and add to SQLite provider
        final newMember = dto.FamilyMemberDto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nama: _namaController.text.trim(),
          hubungan: _selectedHubungan!,
          tempatLahir: _tempatLahirController.text.trim(),
          tanggalLahir: _tanggalLahir!,
          jenisKelamin: _selectedJenisKelamin!,
          pekerjaan: _pekerjaanController.text.trim(),
          tanggalMenikah: _tanggalMenikah,
        );
        
        final currentData = ref.read(familyDataProvider);
        final updatedData = [...currentData, newMember];
        ref.read(familyDataProvider.notifier).state = updatedData;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Data ${_namaController.text} berhasil diperbarui'
                  : 'Data ${_namaController.text} berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        context.go('/keluarga');
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
}
