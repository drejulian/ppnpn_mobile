import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/kegiatan_rumah_aspirasi_provider.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/kegiatan_rumah_aspirasi_model.dart';

class TambahRumahAspirasiPage extends ConsumerStatefulWidget {
  const TambahRumahAspirasiPage({super.key});

  @override
  ConsumerState<TambahRumahAspirasiPage> createState() =>
      _TambahRumahAspirasiPageState();
}

class _TambahRumahAspirasiPageState
    extends ConsumerState<TambahRumahAspirasiPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaKegiatanController = TextEditingController();
  final _tanggalKegiatanController = TextEditingController();
  final _waktuMulaiController = TextEditingController();
  final _waktuSelesaiController = TextEditingController();
  final _tempatController = TextEditingController();
  final _picController = TextEditingController();
  final _kontakPicController = TextEditingController();
  final _jumlahPesertaController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String _selectedStatus = 'direncanakan';
  DateTime? _selectedDate;

  final List<String> _statusOptions = [
    'direncanakan',
    'berlangsung',
    'selesai',
    'dibatalkan',
  ];

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
        title: 'Tambah kegiatan Rumah Aspirasi',
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
              // Data Kegiatan Section
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

              // Tombol Simpan
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      theme.primarySwatch,
                      theme.primarySwatch.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primarySwatch.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    try {
                      final kegiatan = KegiatanRumahAspirasiModel(
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
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      final success = await ref
                          .read(kegiatanRumahAspirasiProvider.notifier)
                          .addKegiatan(
                            namaKegiatan: kegiatan.namaKegiatan,
                            tanggalKegiatan: kegiatan.tanggalKegiatan,
                            waktuMulai: kegiatan.waktuMulai,
                            waktuSelesai: kegiatan.waktuSelesai,
                            tempat: kegiatan.tempat,
                            pic: kegiatan.pic,
                            kontakPic: kegiatan.kontakPic,
                            jumlahPeserta: kegiatan.jumlahPeserta,
                            status: kegiatan.status,
                            deskripsi: kegiatan.deskripsi,
                          );

                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Kegiatan "${kegiatan.namaKegiatan}" berhasil ditambahkan',
                            ),
                            backgroundColor: Colors.green[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                        
                        // Send notification
                        await _showLocalNotification();
                        
                        // Force refresh data dan pop dengan result
                        await ref.read(kegiatanRumahAspirasiProvider.notifier).loadKegiatan();
                        context.pop(true); // Pass true untuk menandakan data berhasil ditambah
                      } else if (mounted) {
                        // Jika addKegiatan return false
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Gagal menambahkan kegiatan'),
                            backgroundColor: Colors.red[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menambahkan kegiatan: $e'),
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
                  icon: const Icon(Icons.save_rounded, size: 20),
                  label: Text(
                    'SIMPAN KEGIATAN',
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

  // Method untuk mengirim notifikasi lokal
  Future<void> _showLocalNotification() async {
    try {
      await NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Kegiatan Rumah Aspirasi Berhasil Ditambahkan',
        body: 'Kegiatan "${_namaKegiatanController.text.trim()}" telah berhasil ditambahkan.',
        payload: 'rumah_aspirasi_${_namaKegiatanController.text.trim()}',
      );
    } catch (e) {
      // Jika notifikasi gagal, tidak perlu mengganggu user
      debugPrint('Gagal mengirim notifikasi: $e');
    }
  }
}
