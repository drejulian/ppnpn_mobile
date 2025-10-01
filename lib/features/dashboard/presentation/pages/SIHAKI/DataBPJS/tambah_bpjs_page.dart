import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/MenuUtama/notification_provider.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/bpjs_provider.dart';

class TambahBpjsPage extends ConsumerStatefulWidget {
  const TambahBpjsPage({super.key});

  @override
  ConsumerState<TambahBpjsPage> createState() => _TambahBpjsPageState();
}

class _TambahBpjsPageState extends ConsumerState<TambahBpjsPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _noBPJSController = TextEditingController();
  final _nikController = TextEditingController();
  final _hubunganKeluargaController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _namaFaskesTingkat1Controller = TextEditingController();
  DateTime? _selectedDate;
  String _selectedStatus = 'aktif';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(now.year - 30),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noBPJSController.dispose();
    _nikController.dispose();
    _hubunganKeluargaController.dispose();
    _tanggalLahirController.dispose();
    _namaFaskesTingkat1Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppCustomAppBar(
        title: 'Tambah Data BPJS',
        onBackPressed: () => context.pop(),
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
                title: 'Form Tambah BPJS',
                titleIcon: Icons.medical_services,
                fields: [
                  FormFieldConfig(
                    label: 'Nama',
                    icon: Icons.person,
                    controller: _namaController,
                    hintText: 'Nama lengkap',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'Nomor BPJS',
                    icon: Icons.confirmation_num,
                    controller: _noBPJSController,
                    hintText: 'Nomor BPJS (13 digit)',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nomor BPJS harus diisi';
                      }
                      if (value.trim().length != 13) {
                        return 'Nomor BPJS harus 13 digit';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'NIK',
                    icon: Icons.badge,
                    controller: _nikController,
                    hintText: 'Nomor Induk Kependudukan (16 digit)',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'NIK harus diisi';
                      }
                      if (value.trim().length != 16) {
                        return 'NIK harus 16 digit';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Hubungan Keluarga',
                    icon: Icons.family_restroom,
                    controller: _hubunganKeluargaController,
                    hintText: 'Kepala Keluarga/Suami/Istri/Anak',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                  FormFieldConfig(
                    label: 'Tanggal Lahir',
                    icon: Icons.cake,
                    controller: _tanggalLahirController,
                    hintText: 'dd-mm-yyyy',
                    type: FormFieldType.datePicker,
                    suffixIcon: Icons.calendar_today,
                    isRequired: true,
                    onTap: () => _pickDate(),
                  ),
                  FormFieldConfig(
                    label: 'Nama Faskes Tingkat 1',
                    icon: Icons.local_hospital,
                    controller: _namaFaskesTingkat1Controller,
                    hintText: 'Nama Puskesmas/Klinik',
                    type: FormFieldType.textRequired,
                    isRequired: true,
                  ),
                ],
                onSave: () async {
                  if (!_formKey.currentState!.validate()) return;
                  
                  final success = await ref
                      .read(bpjsProvider.notifier)
                      .addBPJS(
                        nama: _namaController.text.trim(),
                        noBPJS: _noBPJSController.text.trim(),
                        nik: _nikController.text.trim(),
                        hubunganKeluarga: _hubunganKeluargaController.text.trim(),
                        tanggalLahir: _tanggalLahirController.text.trim(),
                        namaFaskesTingkat1: _namaFaskesTingkat1Controller.text.trim(),
                        status: _selectedStatus,
                      );
                  
                  if (!success) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal menambahkan data BPJS'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }
                  
                  // Tambahkan notifikasi ke dalam app (page notifikasi)
                  ref.read(notificationProvider.notifier).addBPJSNotification(
                    nama: _namaController.text.trim(),
                    hubunganKeluarga: _hubunganKeluargaController.text.trim(),
                    noBPJS: _noBPJSController.text.trim(),
                    namaFaskes: _namaFaskesTingkat1Controller.text.trim(),
                  );
                  
                  // Kirim notifikasi lokal langsung
                  _showLocalNotification();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data BPJS berhasil ditambahkan dan notifikasi dikirim'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    context.pop(true); // Return true to indicate success
                  }
                },
                saveButtonText: 'TAMBAH DATA',
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
        title: 'Data BPJS Berhasil Ditambahkan',
        body: 'Data BPJS untuk ${_namaController.text.trim()} telah berhasil ditambahkan.',
        payload: 'bpjs_${_namaController.text.trim()}',
      );
    } catch (e) {
      // Jika notifikasi gagal, tidak perlu mengganggu user
      debugPrint('Gagal mengirim notifikasi: $e');
    }
  }
}
