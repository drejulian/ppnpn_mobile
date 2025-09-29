import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'daftar_medsos.dart';

class EditMediaSosialAnggotaPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> medsos;

  const EditMediaSosialAnggotaPage({super.key, required this.medsos});

  @override
  ConsumerState<EditMediaSosialAnggotaPage> createState() =>
      _EditMediaSosialAnggotaPageState();
}

class _EditMediaSosialAnggotaPageState
    extends ConsumerState<EditMediaSosialAnggotaPage> {
  final _formKey = GlobalKey<FormState>();
  final _platformController = TextEditingController();
  final _usernameController = TextEditingController();

  String? _selectedPlatform;
  final List<String> _platforms = [
    'Facebook',
    'Twitter',
    'LinkedIn',
    'Instagram',
    'Website',
    'TikTok',
    'YouTube',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize form with existing data
    final platform = widget.medsos['platform'] as String;
    if (_platforms.contains(platform)) {
      _selectedPlatform = platform;
    } else {
      _selectedPlatform = 'Other';
      _platformController.text = platform;
    }

    _usernameController.text = widget.medsos['username'] as String;
  }

  @override
  void dispose() {
    _platformController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Ubah Media Sosial',
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
                title: 'Form Edit Media Sosial',
                titleIcon: Icons.edit,
                fields: [
                  FormFieldConfig(
                    label: 'Platform',
                    icon: Icons.devices,
                    type: FormFieldType.dropdown,
                    options: _platforms,
                    value: _selectedPlatform,
                    isRequired: true,
                    hintText: 'Pilih platform media sosial',
                    onChanged: (value) {
                      setState(() {
                        _selectedPlatform = value;
                        if (value != 'Other') {
                          _platformController.clear();
                        }
                      });
                    },
                  ),
                  if (_selectedPlatform == 'Other')
                    FormFieldConfig(
                      label: 'Nama Platform Custom',
                      icon: Icons.edit,
                      type: FormFieldType.textRequired,
                      controller: _platformController,
                      isRequired: true,
                      hintText: 'Masukkan nama platform',
                    ),
                  FormFieldConfig(
                    label: 'Username/URL',
                    icon: Icons.link,
                    type: FormFieldType.textRequired,
                    controller: _usernameController,
                    isRequired: true,
                    hintText: 'Contoh: https://facebook.com/username',
                    isLast: true,
                  ),
                ],
                onSave: () {
                  if (!_validateForm()) return;

                  final platform =
                      _selectedPlatform == 'Other'
                          ? _platformController.text
                          : _selectedPlatform!;
                  final username = _usernameController.text;

                  // Update the provider
                  ref.read(mediaSosialDataProvider.notifier).updateMediaSosial(
                    widget.medsos['id'],
                    {'platform': platform, 'username': username},
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Media sosial "$platform" berhasil diperbarui',
                      ),
                      backgroundColor: Colors.green[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );

                  context.pop();
                },
                saveButtonText: 'PERBARUI MEDIA SOSIAL',
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateForm() {
    bool isValid = true;

    // Platform validation
    if (_selectedPlatform == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Platform harus dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }

    if (_selectedPlatform == 'Other' && _platformController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama platform harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }

    // Username validation
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username/URL harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }

    return isValid;
  }
}
