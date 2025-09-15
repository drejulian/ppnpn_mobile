import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/DataDiri/riwayat_pekerjaan_page.dart';
import 'package:flutter/services.dart';

class EditDataPekerjaanPage extends ConsumerStatefulWidget {
  final WorkHistoryData data;
  const EditDataPekerjaanPage({super.key, required this.data});

  @override
  ConsumerState<EditDataPekerjaanPage> createState() =>
      _EditDataPekerjaanPageState();
}

class _EditDataPekerjaanPageState extends ConsumerState<EditDataPekerjaanPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _positionCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _startYearCtrl;
  late final TextEditingController _endYearCtrl;

  @override
  void initState() {
    super.initState();
    _positionCtrl = TextEditingController(text: widget.data.position);
    _companyCtrl = TextEditingController(text: widget.data.company);
    _startYearCtrl = TextEditingController(text: widget.data.startYear);
    _endYearCtrl = TextEditingController(text: widget.data.endYear);
  }

  @override
  void dispose() {
    _positionCtrl.dispose();
    _companyCtrl.dispose();
    _startYearCtrl.dispose();
    _endYearCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final list = ref.read(workHistoryDataProvider);
    final updated =
        list
            .map(
              (e) =>
                  e.id == widget.data.id
                      ? e.copyWith(
                        position: _positionCtrl.text.trim(),
                        company: _companyCtrl.text.trim(),
                        startYear: _startYearCtrl.text.trim(),
                        endYear: _endYearCtrl.text.trim(),
                      )
                      : e,
            )
            .toList();
    ref.read(workHistoryDataProvider.notifier).state = updated;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data riwayat pekerjaan berhasil diperbarui!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Return data to parent page
    Navigator.pop(context, {
      'action': 'edit',
      'data': {
        'id': widget.data.id,
        'position': _positionCtrl.text.trim(),
        'company': _companyCtrl.text.trim(),
        'startYear': _startYearCtrl.text.trim(),
        'endYear': _endYearCtrl.text.trim(),
      }
    }); 
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Edit Riwayat Pekerjaan',
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job ID Card
              _buildInfoCard(theme),

              const SizedBox(height: 16),

              // Job Details Card
              _buildCard(
                theme,
                title: 'Data Pekerjaan',
                icon: Icons.business_center,
                child: Column(
                  children: [
                    _buildFieldWithIcon(
                      'Posisi',
                      _positionCtrl,
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
                      _companyCtrl,
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
                      _startYearCtrl,
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
                      _endYearCtrl,
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
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.save, size: 20),
                  label: Text(
                    'SIMPAN PERUBAHAN',
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

  // Info card showing job ID
  Widget _buildInfoCard(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primarySwatch.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primarySwatch.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.badge, color: theme.primarySwatch),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID Riwayat',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(widget.data.id, style: theme.typographyBold.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Kunker-style card container with gradient header
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

  // Kunker-style field with left icon and "Wajib diisi" indicator
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
