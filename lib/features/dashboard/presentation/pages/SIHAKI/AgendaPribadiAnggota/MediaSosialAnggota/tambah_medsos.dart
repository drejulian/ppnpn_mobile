import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/sihaki/media_sosial_anggota_provider.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/providers/MenuUtama/notification_provider.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';

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
  final _urlController = TextEditingController();
  final _followersController = TextEditingController();


  String? _selectedPlatform;
  String _selectedStatus = 'aktif'; // Default ke aktif
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
  void dispose() {
    _platformController.dispose();
    _usernameController.dispose();
    _urlController.dispose();
    _followersController.dispose();
    super.dispose();
  }

  // Method untuk mengirim notifikasi lokal
  // Method untuk mengirim notifikasi lokal
  Future<void> _showLocalNotification(String platform, String username, {int? followers, bool isVerified = false}) async {
    try {
      final followersText = followers != null ? ' ($followers followers)' : '';
      final verifiedText = isVerified ? ' ✓' : '';
      
      await NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Media Sosial Berhasil Ditambahkan',
        body: 'Akun $platform ($username)$followersText$verifiedText telah berhasil ditambahkan ke media sosial Anda.',
        payload: 'medsos_${platform}_$username',
      );
      print('DEBUG: 📱 Local notification sent for $platform @$username');
    } catch (e) {
      // Jika notifikasi gagal, tidak perlu mengganggu user
      print('DEBUG: ❌ Failed to send local notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

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
                    type: FormFieldType.dropdown,
                    options: const ['aktif', 'tidak_aktif'],
                    value: _selectedStatus,
                    isRequired: true,
                    hintText: 'Pilih status',
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? 'aktif';
                      });
                    },
                    isLast: true,
                  ),
                ],
                onSave: () async {
                  if (!_validateForm()) return;

                  final platform =
                      _selectedPlatform == 'Other'
                          ? _platformController.text
                          : _selectedPlatform!;

                  final username = _usernameController.text;
                  final url = _urlController.text;
                  final followers = int.tryParse(_followersController.text) ?? 0;

                  print('DEBUG: 💾 Saving media sosial - Platform: $platform, Username: @$username');

                  final success = await ref
                      .read(mediaSosialAnggotaProvider.notifier)
                      .addMediaSosial(
                        platform: platform,
                        username: username,
                        url: url,
                        followers: followers,
                        isVerified: _isVerified,
                        status: _selectedStatus,
                      );

                  if (success && mounted) {
                    print('DEBUG: ✅ Media sosial saved successfully');

                    // Tambahkan notifikasi ke dalam app (page notifikasi)
                    ref.read(notificationProvider.notifier).addMediaSosialNotification(
                      platform: platform,
                      username: username,
                      url: url,
                      followers: followers,
                      isVerified: _isVerified,
                    );

                    print('DEBUG: 🔔 Added notification to notification provider');

                    // Kirim notifikasi lokal langsung
                    await _showLocalNotification(platform, username, 
                        followers: followers, isVerified: _isVerified);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Media sosial "$platform" berhasil ditambahkan dan notifikasi dikirim',
                          ),
                          backgroundColor: Colors.green[600],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );

                      context.pop(true);
                    }
                  } else if (mounted) {
                    print('DEBUG: ❌ Failed to save media sosial');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Gagal menambahkan media sosial'),
                        backgroundColor: Colors.red[600],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
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

    // Status validation (tidak diperlukan karena menggunakan dropdown dengan default)

    return isValid;
  }
}
