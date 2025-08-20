import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'daftar_cuti_page.dart';

class EditCutiPage extends ConsumerStatefulWidget {
  const EditCutiPage({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  ConsumerState<EditCutiPage> createState() => _EditCutiPageState();
}

class _EditCutiPageState extends ConsumerState<EditCutiPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _jenisCtrl;
  late final TextEditingController _awalCtrl;
  late final TextEditingController _akhirCtrl;
  late final TextEditingController _alasanCtrl;

  Future<void> _pickDate(TextEditingController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
    }
  }

  @override
  void initState() {
    super.initState();
    _jenisCtrl = TextEditingController(text: widget.data['jenis'] ?? '');
    _awalCtrl = TextEditingController(text: widget.data['tanggal_awal'] ?? '');
    _akhirCtrl = TextEditingController(
      text: widget.data['tanggal_akhir'] ?? '',
    );
    _alasanCtrl = TextEditingController(text: widget.data['alasan'] ?? '');
  }

  @override
  void dispose() {
    _jenisCtrl.dispose();
    _awalCtrl.dispose();
    _akhirCtrl.dispose();
    _alasanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final String status = (widget.data['status'] ?? 'Menunggu') as String;
    final bool isLocked = status == 'Disetujui';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ubah Pengajuan Cuti',
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
              // Status chip on top
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statusChip('Status: $status', _statusColor(status), theme),
                ],
              ),
              const SizedBox(height: 12),
              if (isLocked)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pengajuan ini sudah disetujui dan tidak dapat diedit.',
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              _sectionCard(
                title: 'Data Cuti',
                icon: Icons.event_available,
                theme: theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldWithIcon(
                      label: 'Jenis Cuti',
                      icon: Icons.category,
                      theme: theme,
                      child: TextFormField(
                        controller: _jenisCtrl,
                        enabled: !isLocked,
                        decoration: _decor(
                          theme,
                          hint: 'Cuti Tahunan',
                          enabled: !isLocked,
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                    _fieldWithIcon(
                      label: 'Tanggal Mulai',
                      icon: Icons.event,
                      theme: theme,
                      child: GestureDetector(
                        onTap: isLocked ? null : () => _pickDate(_awalCtrl),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _awalCtrl,
                            enabled: !isLocked,
                            decoration: _decor(
                              theme,
                              hint: 'dd-mm-yyyy',
                              suffixIcon: Icons.calendar_today,
                              enabled: !isLocked,
                            ),
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Wajib diisi'
                                        : null,
                          ),
                        ),
                      ),
                    ),
                    _fieldWithIcon(
                      label: 'Tanggal Selesai',
                      icon: Icons.event,
                      theme: theme,
                      child: GestureDetector(
                        onTap: isLocked ? null : () => _pickDate(_akhirCtrl),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _akhirCtrl,
                            enabled: !isLocked,
                            decoration: _decor(
                              theme,
                              hint: 'dd-mm-yyyy',
                              suffixIcon: Icons.calendar_today,
                              enabled: !isLocked,
                            ),
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Wajib diisi'
                                        : null,
                          ),
                        ),
                      ),
                    ),
                    _fieldWithIcon(
                      label: 'Alasan',
                      icon: Icons.assignment,
                      theme: theme,
                      child: TextFormField(
                        controller: _alasanCtrl,
                        maxLines: 3,
                        enabled: !isLocked,
                        decoration: _decor(
                          theme,
                          hint: 'Tuliskan alasan',
                          enabled: !isLocked,
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Perubahan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed:
                      isLocked
                          ? null
                          : () {
                            if (!_formKey.currentState!.validate()) return;
                            ref
                                .read(cutiProvider.notifier)
                                .update(widget.data['id'], {
                                  'jenis': _jenisCtrl.text.trim(),
                                  'tanggal_awal': _awalCtrl.text.trim(),
                                  'tanggal_akhir': _akhirCtrl.text.trim(),
                                  'alasan': _alasanCtrl.text.trim(),
                                });
                            context.pop();
                          },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldWithIcon({
    required String label,
    required IconData icon,
    required Widget child,
    required dynamic theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.primarySwatch.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.primarySwatch, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    required dynamic theme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.primarySwatch,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
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

  // Outlined Input decoration (Kunker style)
  InputDecoration _decor(
    dynamic theme, {
    String? hint,
    IconData? suffixIcon,
    bool enabled = true,
  }) {
    final borderColor = Colors.grey[300]!;
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.primarySwatch),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      filled: !enabled,
      fillColor: !enabled ? Colors.grey[100] : null,
    );
  }

  // Status helpers
  Color _statusColor(String s) {
    switch (s) {
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _statusChip(String label, Color color, dynamic theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.typographyRegular.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
