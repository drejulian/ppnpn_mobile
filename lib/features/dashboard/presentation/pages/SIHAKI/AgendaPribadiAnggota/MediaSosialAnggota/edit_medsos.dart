import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/media_sosial_anggota_provider.dart';
import 'package:ppnpm_dpr/common/data/models/sihaki/media_sosial_anggota_model.dart';

class EditMediaSosialAnggotaPage extends ConsumerStatefulWidget {
  final MediaSosialAnggotaModel medsos;

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
  final _urlController = TextEditingController();
  final _followersController = TextEditingController();
  final _statusController = TextEditingController();

  String? _selectedPlatform;
  bool _isVerified = false;
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
    final platform = widget.medsos.platform;
    if (_platforms.contains(platform)) {
      _selectedPlatform = platform;
    } else {
      _selectedPlatform = 'Other';
      _platformController.text = platform;
    }

    _usernameController.text = widget.medsos.username;
    _urlController.text = widget.medsos.url;
    _followersController.text = widget.medsos.followers.toString();
    _statusController.text = widget.medsos.status;
    _isVerified = widget.medsos.isVerified;
  }

  @override
  void dispose() {
    _platformController.dispose();
    _usernameController.dispose();
    _urlController.dispose();
    _followersController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Media Sosial - ${widget.medsos.id}',
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
                    label: 'Username',
                    icon: Icons.person,
                    type: FormFieldType.textRequired,
                    controller: _usernameController,
                    isRequired: true,
                    hintText: 'Username atau handle akun',
                  ),
                  FormFieldConfig(
                    label: 'URL',
                    icon: Icons.link,
                    type: FormFieldType.textRequired,
                    controller: _urlController,
                    isRequired: true,
                    hintText: 'https://platform.com/username',
                  ),
                  FormFieldConfig(
                    label: 'Jumlah Followers',
                    icon: Icons.people,
                    type: FormFieldType.text,
                    controller: _followersController,
                    isRequired: true,
                    hintText: 'Contoh: 1000',
                  ),
                  FormFieldConfig(
                    label: 'Status',
                    icon: Icons.info,
                    type: FormFieldType.text,
                    controller: _statusController,
                    isRequired: true,
                    hintText: 'Aktif / Tidak Aktif',
                    isLast: true,
                  ),
                ],
                onSave: () async {
                  if (!_validateForm()) return;

                  final platform =
                      _selectedPlatform == 'Other'
                          ? _platformController.text
                          : _selectedPlatform!;

                  final updatedMediaSosial = widget.medsos.copyWith(
                    platform: platform,
                    username: _usernameController.text,
                    url: _urlController.text,
                    followers: int.tryParse(_followersController.text) ?? 0,
                    isVerified: _isVerified,
                    status: _statusController.text,
                  );

                  final success = await ref
                      .read(mediaSosialAnggotaProvider.notifier)
                      .updateMediaSosial(updatedMediaSosial);

                  if (success && mounted) {
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
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Gagal memperbarui media sosial'),
                        backgroundColor: Colors.red[600],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
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
          content: Text('Username harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }

    // URL validation
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }

    // Followers validation
    if (_followersController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah followers harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }

    // Status validation
    if (_statusController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }

    return isValid;
  }
}
