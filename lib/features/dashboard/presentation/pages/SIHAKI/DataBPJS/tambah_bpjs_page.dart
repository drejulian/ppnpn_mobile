import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/bpjs_provider.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/bpjs_model.dart';

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
  bool _isLoading = false;

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
    final theme = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Data BPJS',
          style: theme.typographyBold.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
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
                onSave: _isLoading ? null : _saveBPJSData,
                saveButtonText: _isLoading ? 'MENYIMPAN...' : 'TAMBAH DATA',
              ),
              const SizedBox(height: 16),
              // Status Dropdown
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Status BPJS',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: ['aktif', 'non-aktif', 'pending']
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status.toUpperCase()),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBPJSData() async {
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }
    
    // Additional validation
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tanggal lahir harus dipilih'),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      
      // Debug: Print all data before saving
      print('📝 Data yang akan disimpan:');
      print('   Nama: ${_namaController.text.trim()}');
      print('   No BPJS: ${_noBPJSController.text.trim()}');
      print('   NIK: ${_nikController.text.trim()}');
      print('   Hubungan: ${_hubunganKeluargaController.text.trim()}');
      print('   Tanggal Lahir: ${_tanggalLahirController.text.trim()}');
      print('   Faskes: ${_namaFaskesTingkat1Controller.text.trim()}');
      print('   Status: $_selectedStatus');
      
      final bpjsData = BPJSModel(
        nama: _namaController.text.trim(),
        noBPJS: _noBPJSController.text.trim(),
        nik: _nikController.text.trim(),
        hubunganKeluarga: _hubunganKeluargaController.text.trim(),
        tanggalLahir: _tanggalLahirController.text.trim(),
        namaFaskesTingkat1: _namaFaskesTingkat1Controller.text.trim(),
        status: _selectedStatus,
        createdAt: now,
        updatedAt: now,
      );

      print('🔄 Memanggil addBPJS provider...');
      final success = await ref.read(bpjsProvider.notifier).addBPJS(
        nama: bpjsData.nama,
        noBPJS: bpjsData.noBPJS,
        nik: bpjsData.nik,
        hubunganKeluarga: bpjsData.hubunganKeluarga,
        tanggalLahir: bpjsData.tanggalLahir,
        namaFaskesTingkat1: bpjsData.namaFaskesTingkat1,
        status: bpjsData.status,
      );
      
      print('📊 Hasil addBPJS: $success');
      
      if (mounted) {
        if (success) {
          print('✅ Data berhasil disimpan');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Data BPJS "${_namaController.text}" berhasil ditambahkan',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.pop(true); // Return true to indicate success
        } else {
          print('❌ Data gagal disimpan');
          // Check for error message from provider
          final errorMessage = ref.read(bpjsProvider).errorMessage;
          print('Error message: $errorMessage');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage ?? 'Gagal menambahkan data BPJS',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('💥 Exception terjadi: $e');
      print('Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
