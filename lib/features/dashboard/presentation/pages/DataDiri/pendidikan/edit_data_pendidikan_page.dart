import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart'; // Assuming this path is correct

// Education data model (from your original code)
class EducationData {
  final String id;
  final String jenjang;
  final String jurusan;
  final String institusi;
  final String kota;
  final String tahun;

  EducationData({
    required this.id,
    required this.jenjang,
    required this.jurusan,
    required this.institusi,
    required this.kota,
    required this.tahun,
  });

  // Helper to create a copy with new values
  EducationData copyWith({
    String? id,
    String? jenjang,
    String? jurusan,
    String? institusi,
    String? kota,
    String? tahun,
  }) {
    return EducationData(
      id: id ?? this.id,
      jenjang: jenjang ?? this.jenjang,
      jurusan: jurusan ?? this.jurusan,
      institusi: institusi ?? this.institusi,
      kota: kota ?? this.kota,
      tahun: tahun ?? this.tahun,
    );
  }
}

// Provider with education data (from your original code)
final educationDataProvider = StateProvider<List<EducationData>>((ref) {
  return [
    EducationData(
      id: '1',
      jenjang: 'Sarjana/S1',
      jurusan: 'TEKNIK INFORMATIKA',
      institusi: 'INSTITUT TEKNOLOGI SEPULUH NOPEMBER (ITSI)',
      kota: 'SURABAYA',
      tahun: '2004',
    ),
  ];
});

class EditDataPendidikanPage extends ConsumerStatefulWidget {
  final EducationData? educationToEdit; // Optional: for editing existing data

  const EditDataPendidikanPage({super.key, this.educationToEdit});

  @override
  ConsumerState<EditDataPendidikanPage> createState() =>
      _EditDataPendidikanPageState();
}

class _EditDataPendidikanPageState
    extends ConsumerState<EditDataPendidikanPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _jenjangController;
  late TextEditingController _jurusanController;
  late TextEditingController _institusiController;
  late TextEditingController _kotaController;
  late TextEditingController _tahunController;

  @override
  void initState() {
    super.initState();
    _jenjangController = TextEditingController(
      text: widget.educationToEdit?.jenjang ?? '',
    );
    _jurusanController = TextEditingController(
      text: widget.educationToEdit?.jurusan ?? '',
    );
    _institusiController = TextEditingController(
      text: widget.educationToEdit?.institusi ?? '',
    );
    _kotaController = TextEditingController(
      text: widget.educationToEdit?.kota ?? '',
    );
    _tahunController = TextEditingController(
      text: widget.educationToEdit?.tahun ?? '',
    );
  }

  @override
  void dispose() {
    _jenjangController.dispose();
    _jurusanController.dispose();
    _institusiController.dispose();
    _kotaController.dispose();
    _tahunController.dispose();
    super.dispose();
  }

  void _saveEducationData() {
    if (_formKey.currentState!.validate()) {
      final String jenjang = _jenjangController.text;
      final String jurusan = _jurusanController.text;
      final String institusi = _institusiController.text;
      final String kota = _kotaController.text;
      final String tahun = _tahunController.text;

      final currentData = ref.read(educationDataProvider);

      if (widget.educationToEdit == null) {
        // Add new education data
        final newEducation = EducationData(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
          jenjang: jenjang,
          jurusan: jurusan,
          institusi: institusi,
          kota: kota,
          tahun: tahun,
        );
        ref.read(educationDataProvider.notifier).state = [
          ...currentData,
          newEducation,
        ];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data pendidikan berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Edit existing education data
        final updatedData =
            currentData.map((education) {
              if (education.id == widget.educationToEdit!.id) {
                return education.copyWith(
                  jenjang: jenjang,
                  jurusan: jurusan,
                  institusi: institusi,
                  kota: kota,
                  tahun: tahun,
                );
              }
              return education;
            }).toList();
        ref.read(educationDataProvider.notifier).state = updatedData;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data pendidikan berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      context.pop(); // Go back to the previous page (PendidikanPage)
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final isEditing = widget.educationToEdit != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Data Pendidikan' : 'Tambah Data Pendidikan',
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
            context.pop(); // Go back to the previous page
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
                              ? 'Form Edit Data Pendidikan'
                              : 'Form Tambah Data Pendidikan',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _jenjangController,
                      labelText: 'Jenjang (e.g., Sarjana/S1)',
                      theme: theme,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jenjang tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _jurusanController,
                      labelText: 'Jurusan (e.g., TEKNIK INFORMATIKA)',
                      theme: theme,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jurusan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _institusiController,
                      labelText:
                          'Institusi (e.g., INSTITUT TEKNOLOGI SEPULUH NOPEMBER (ITSI))',
                      theme: theme,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Institusi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _kotaController,
                      labelText: 'Kota (e.g., SURABAYA)',
                      theme: theme,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kota tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _tahunController,
                      labelText: 'Tahun (e.g., 2004)',
                      theme: theme,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tahun tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Tahun harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveEducationData,
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
                              : 'TAMBAH DATA PENDIDIKAN',
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
