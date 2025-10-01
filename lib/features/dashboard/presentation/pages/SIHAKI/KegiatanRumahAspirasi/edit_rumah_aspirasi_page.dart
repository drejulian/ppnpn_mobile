import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/kegiatan_rumah_aspirasi_provider.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/kegiatan_rumah_aspirasi_model.dart';

class EditRumahAspirasiPage extends ConsumerStatefulWidget {
  final KegiatanRumahAspirasiModel kegiatanItem;

  const EditRumahAspirasiPage({super.key, required this.kegiatanItem});

  @override
  ConsumerState<EditRumahAspirasiPage> createState() =>
      _EditRumahAspirasiPageState();
}

class _EditRumahAspirasiPageState extends ConsumerState<EditRumahAspirasiPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaKegiatanController;
  late TextEditingController _tanggalKegiatanController;
  late TextEditingController _waktuMulaiController;
  late TextEditingController _waktuSelesaiController;
  late TextEditingController _tempatController;
  late TextEditingController _picController;
  late TextEditingController _kontakPicController;
  late TextEditingController _jumlahPesertaController;
  late TextEditingController _deskripsiController;

  late String _selectedStatus;
  DateTime? _selectedDate;

  final List<String> _statusOptions = [
    'direncanakan',
    'berlangsung',
    'selesai',
    'dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data
    _namaKegiatanController = TextEditingController(text: widget.kegiatanItem.namaKegiatan);
    _tanggalKegiatanController = TextEditingController(text: widget.kegiatanItem.tanggalKegiatan);
    _waktuMulaiController = TextEditingController(text: widget.kegiatanItem.waktuMulai);
    _waktuSelesaiController = TextEditingController(text: widget.kegiatanItem.waktuSelesai);
    _tempatController = TextEditingController(text: widget.kegiatanItem.tempat);
    _picController = TextEditingController(text: widget.kegiatanItem.pic);
    _kontakPicController = TextEditingController(text: widget.kegiatanItem.kontakPic ?? '');
    _jumlahPesertaController = TextEditingController(text: widget.kegiatanItem.jumlahPeserta.toString());
    _deskripsiController = TextEditingController(text: widget.kegiatanItem.deskripsi ?? '');
    
    _selectedStatus = widget.kegiatanItem.status;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalKegiatanController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _namaKegiatanController.dispose();
    _tanggalKegiatanController.dispose();
    _waktuMulaiController.dispose();
    _waktuSelesaiController.dispose();
    _tempatController.dispose();
    _picController.dispose();
    _kontakPicController.dispose();
    _jumlahPesertaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Ubah kegiatan Rumah Aspirasi',
        onBackPressed: () => Navigator.of(context).pop(),
        backTooltip: 'Kembali',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFormCard(
                title: 'Data Kegiatan',
                titleIcon: Icons.business_center,
                fields: [
                  FormFieldConfig(
                    label: 'Nama Kegiatan',
                    icon: Icons.event,
                    controller: _namaKegiatanController,
                    hintText: 'Masukkan nama kegiatan',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                ],
                onSave: null,
              ),
              const SizedBox(height: 16),

              AppFormCard(
                title: 'Data Surat',
                titleIcon: Icons.description,
                fields: [
                  FormFieldConfig(
                    label: 'Tanggal Kegiatan',
                    icon: Icons.calendar_today,
                    controller: _tanggalKegiatanController,
                    hintText: 'dd-mm-yyyy',
                    type: FormFieldType.datePicker,
                    suffixIcon: Icons.calendar_today,
                    isRequired: true,
                    onTap: () => _pickDate(),
                  ),
                  FormFieldConfig(
                    label: 'Waktu Mulai',
                    icon: Icons.access_time,
                    controller: _waktuMulaiController,
                    hintText: 'HH:MM (contoh: 09:00)',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'Waktu Selesai',
                    icon: Icons.access_time_filled,
                    controller: _waktuSelesaiController,
                    hintText: 'HH:MM (contoh: 17:00)',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'Tempat',
                    icon: Icons.location_on,
                    controller: _tempatController,
                    hintText: 'Masukkan lokasi kegiatan',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'PIC (Person In Charge)',
                    icon: Icons.person,
                    controller: _picController,
                    hintText: 'Nama penanggung jawab',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'Kontak PIC (Opsional)',
                    icon: Icons.phone,
                    controller: _kontakPicController,
                    hintText: 'Nomor telepon PIC',
                    type: FormFieldType.text,
                    isRequired: false,
                  ),
                  FormFieldConfig(
                    label: 'Estimasi Jumlah Peserta',
                    icon: Icons.people,
                    controller: _jumlahPesertaController,
                    hintText: 'Contoh: 50',
                    type: FormFieldType.textRequired,
                    isRequired: false,
                    isLast: true,
                  ),
                ],
                onSave: null, // No save button for this section
              ),
              const SizedBox(height: 16),

              // Status dan Deskripsi Section
              AppFormCard(
                title: 'Status dan Deskripsi',
                titleIcon: Icons.info_outline,
                fields: [
                  FormFieldConfig(
                    label: 'Deskripsi (Opsional)',
                    icon: Icons.description,
                    controller: _deskripsiController,
                    hintText: 'Deskripsi kegiatan...',
                    type: FormFieldType.multiline,
                    isRequired: false,
                    maxLines: 3,
                    isLast: true,
                  ),
                ],
                onSave: null,
              ),
              const SizedBox(height: 16),

              // Status Dropdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          color: theme.primarySwatch,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status Kegiatan',
                          style: theme.typographyBold.bodyMedium.copyWith(
                            color: theme.primarySwatch,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.primarySwatch, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: _statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedStatus = newValue;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Status kegiatan harus dipilih';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Update
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange[600]!,
                      Colors.orange[500]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    try {
                      final updatedKegiatan = widget.kegiatanItem.copyWith(
                        namaKegiatan: _namaKegiatanController.text.trim(),
                        tanggalKegiatan: _tanggalKegiatanController.text.trim(),
                        waktuMulai: _waktuMulaiController.text.trim(),
                        waktuSelesai: _waktuSelesaiController.text.trim(),
                        tempat: _tempatController.text.trim(),
                        pic: _picController.text.trim(),
                        kontakPic: _kontakPicController.text.trim().isEmpty 
                            ? null 
                            : _kontakPicController.text.trim(),
                        jumlahPeserta: int.tryParse(_jumlahPesertaController.text.trim()) ?? 0,
                        status: _selectedStatus,
                        deskripsi: _deskripsiController.text.trim().isEmpty 
                            ? null 
                            : _deskripsiController.text.trim(),
                        updatedAt: DateTime.now(),
                      );

                      await ref
                          .read(kegiatanRumahAspirasiProvider.notifier)
                          .updateKegiatan(updatedKegiatan);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Kegiatan "${_namaKegiatanController.text.trim()}" berhasil diperbarui',
                            ),
                            backgroundColor: Colors.green[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                        
                        // Force refresh data dan pop dengan result
                        await ref.read(kegiatanRumahAspirasiProvider.notifier).loadKegiatan();
                        context.pop(true); // Pass true untuk menandakan data berhasil diupdate
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal memperbarui kegiatan: $e'),
                            backgroundColor: Colors.red[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.update_rounded, size: 20),
                  label: Text(
                    'UPDATE KEGIATAN',
                    style: theme.typographyBold.bodyMedium.copyWith(
                      color: Colors.white,
                      letterSpacing: 0.8,
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
}