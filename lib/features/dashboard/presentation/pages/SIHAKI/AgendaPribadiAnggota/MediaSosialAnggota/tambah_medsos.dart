import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'daftar_medsos.dart';

class TambahMediaSosialAnggotaPage extends ConsumerStatefulWidget {
  const TambahMediaSosialAnggotaPage({super.key});

  @override
  ConsumerState<TambahMediaSosialAnggotaPage> createState() =>
      _TambahMediaSosialAnggotaPageState();
}

class _TambahMediaSosialAnggotaPageState
    extends ConsumerState<TambahMediaSosialAnggotaPage> {
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
        title: 'Tambah Media Sosial',
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
                title: 'Form Tambah Media Sosial',
                titleIcon: Icons.share,
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

                  // Add to provider
                  ref.read(mediaSosialDataProvider.notifier).addMediaSosial({
                    'platform': platform,
                    'username': username,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Media sosial "$platform" berhasil ditambahkan',
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
                saveButtonText: 'TAMBAH MEDIA SOSIAL',
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
