import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/riwayat_pekerjaan_page.dart';
import 'package:flutter/services.dart';

class AddWorkHistoryPage extends ConsumerStatefulWidget {
  final WorkHistoryData? workHistoryToEdit;
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

      if (widget.workHistoryToEdit == null) {
  
        final newWorkHistory = WorkHistoryData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          position: position,
          company: company,
          startYear: startYear,
          endYear: endYear,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data riwayat pekerjaan berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        final resultData = {
          'id': newWorkHistory.id,
          'position': newWorkHistory.position,
          'company': newWorkHistory.company,
          'startYear': newWorkHistory.startYear,
          'endYear': newWorkHistory.endYear,
        
        };
        
        print('=== RETURNING ADD DATA TO PARENT ===');
        print('Result data: $resultData');
        print('Contains isDummy: ${resultData.containsKey('isDummy')}');
        print('isDummy value: ${resultData['isDummy']}');
        print('namaPerusahaan: ${resultData['namaPerusahaan']}');
        
        final returnPayload = {
          'action': 'add',
          'data': resultData,
        };
        
        print('Final return payload:');
        print('  action: ${returnPayload['action']}');
        print('  data.isDummy: ${(returnPayload['data'] as Map?)?['isDummy']}');
        print('  complete payload: $returnPayload');
        
        Navigator.pop(context, returnPayload);
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data riwayat pekerjaan berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        
        final resultData = {
          'id': widget.workHistoryToEdit!.id,
          'position': position,
          'company': company,
          'startYear': startYear,
          'endYear': endYear,
   
        };
        
        print('=== RETURNING EDIT DATA TO PARENT ===');
        print('Edit result data: $resultData');
        print('Contains isDummy: ${resultData.containsKey('isDummy')}');
        print('isDummy value: ${resultData['isDummy']}');
        print('namaPerusahaan: ${resultData['company']}');
        
        final editPayload = {
          'action': 'edit',
          'data': resultData,
        };
        
        print('Final edit payload:');
        print('  action: ${editPayload['action']}');
        print('  data.isDummy: ${(editPayload['data'] as Map?)?['isDummy']}');
        print('  complete payload: $editPayload');
        
        Navigator.pop(context, editPayload);
        return;
      }
   
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Data Pekerjaan card
              _buildCard(
                theme,
                title:
                    isEditing ? 'Edit Data Pekerjaan' : 'Tambah Data Pekerjaan',
                icon: isEditing ? Icons.edit_note : Icons.work_outline,
                child: Column(
                  children: [
                    _buildFieldWithIcon(
                      'Posisi',
                      _positionController,
                      Icons.work,
                      theme,
                      isRequired: true,
                      hintText: 'Masukkan posisi, contoh: PROGRAMMER',
                      validator:
                          (v) =>
                              (v == null || v.isEmpty)
                                  ? 'Posisi tidak boleh kosong'
                                  : null,
                    ),
                    _buildFieldWithIcon(
                      'Perusahaan',
                      _companyController,
                      Icons.business,
                      theme,
                      isRequired: true,
                      hintText: 'Masukkan nama perusahaan',
                      validator:
                          (v) =>
                              (v == null || v.isEmpty)
                                  ? 'Perusahaan tidak boleh kosong'
                                  : null,
                    ),
                    _buildFieldWithIcon(
                      'Tahun Mulai',
                      _startYearController,
                      Icons.calendar_today,
                      theme,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      hintText: 'contoh: 2006',
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Tahun Mulai tidak boleh kosong';
                        if (int.tryParse(v) == null)
                          return 'Tahun Mulai harus berupa angka';
                        return null;
                      },
                    ),
                    _buildFieldWithIcon(
                      'Tahun Selesai',
                      _endYearController,
                      Icons.event_available,
                      theme,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      hintText: 'contoh: 2009',
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Tahun Selesai tidak boleh kosong';
                        if (int.tryParse(v) == null)
                          return 'Tahun Selesai harus berupa angka';
                        return null;
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveWorkHistoryData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                    isEditing ? 'SIMPAN PERUBAHAN' : 'TAMBAH RIWAYAT PEKERJAAN',
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
      ),
    );
  }


  Widget _buildCard(
    dynamic theme, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
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
                    colors: [theme.primarySwatch, theme.secondarySwatch],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

 
  Widget _buildFieldWithIcon(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall
                                .copyWith(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    validator: validator,
                    decoration: InputDecoration(
                      hintText: hintText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
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
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
