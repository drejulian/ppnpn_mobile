import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/riwayat_pekerjaan_page.dart';

class AddWorkHistoryPage extends ConsumerStatefulWidget {
  final WorkHistoryData?
  workHistoryToEdit; // Optional: for editing existing data

  const AddWorkHistoryPage({super.key, this.workHistoryToEdit});

  @override
  ConsumerState<AddWorkHistoryPage> createState() =>
      _WorkHistoryFormPageState();
}

class _WorkHistoryFormPageState extends ConsumerState<AddWorkHistoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _positionController;
  late TextEditingController _companyController;
  late TextEditingController _startYearController;
  late TextEditingController _endYearController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if editing, otherwise empty
    _positionController = TextEditingController(
      text: widget.workHistoryToEdit?.position ?? '',
    );
    _companyController = TextEditingController(
      text: widget.workHistoryToEdit?.company ?? '',
    );
    _startYearController = TextEditingController(
      text: widget.workHistoryToEdit?.startYear ?? '',
    );
    _endYearController = TextEditingController(
      text: widget.workHistoryToEdit?.endYear ?? '',
    );
  }

  @override
  void dispose() {
    _positionController.dispose();
    _companyController.dispose();
    _startYearController.dispose();
    _endYearController.dispose();
    super.dispose();
  }

  void _saveWorkHistoryData() {
    if (_formKey.currentState!.validate()) {
      final String position = _positionController.text;
      final String company = _companyController.text;
      final String startYear = _startYearController.text;
      final String endYear = _endYearController.text;

      final currentData = ref.read(workHistoryDataProvider);

      if (widget.workHistoryToEdit == null) {
        // Add new work history data
        final newWorkHistory = WorkHistoryData(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
          position: position,
          company: company,
          startYear: startYear,
          endYear: endYear,
        );
        ref.read(workHistoryDataProvider.notifier).state = [
          ...currentData,
          newWorkHistory,
        ];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data riwayat pekerjaan berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Edit existing work history data
        final updatedData =
            currentData.map((work) {
              if (work.id == widget.workHistoryToEdit!.id) {
                return work.copyWith(
                  position: position,
                  company: company,
                  startYear: startYear,
                  endYear: endYear,
                );
              }
              return work;
            }).toList();
        ref.read(workHistoryDataProvider.notifier).state = updatedData;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data riwayat pekerjaan berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      context.pop(); // Go back to the previous page (AddWorkHistoryPage)
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final isEditing = widget.workHistoryToEdit != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Riwayat Pekerjaan' : 'Tambah Riwayat Pekerjaan',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go("/riwayat-pekerjaan"); // Go back to the previous page
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
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
                              colors: [
                                theme.primarySwatch,
                                theme.secondarySwatch,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isEditing ? Icons.edit : Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEditing
                              ? 'Form Edit Riwayat Pekerjaan'
                              : 'Form Tambah Riwayat Pekerjaan',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _positionController,
                      labelText: 'Posisi (e.g., PROGRAMMER)',
                      theme: theme,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Posisi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _companyController,
                      labelText: 'Perusahaan (e.g., PT INSIGHT SYSTEM)',
                      theme: theme,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Perusahaan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _startYearController,
                      labelText: 'Tahun Mulai (e.g., 2006)',
                      theme: theme,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tahun Mulai tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Tahun Mulai harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _endYearController,
                      labelText: 'Tahun Selesai (e.g., 2009 / Sekarang)',
                      theme: theme,
                      keyboardType: TextInputType.text, // Allow "Sekarang"
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tahun Selesai tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveWorkHistoryData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primarySwatch,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        icon: Icon(
                          isEditing ? Icons.save : Icons.add_circle,
                          size: 20,
                        ),
                        label: Text(
                          isEditing
                              ? 'SIMPAN PERUBAHAN'
                              : 'TAMBAH RIWAYAT PEKERJAAN',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required dynamic theme,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: validator,
    );
  }
}
