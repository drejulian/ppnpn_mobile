import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/common/theme/my_theme.dart';

class EditSosialMediaAnggotaPage extends ConsumerStatefulWidget {
  final String namaPlatform;
  final String username;

  const EditSosialMediaAnggotaPage({
    super.key,
    required this.namaPlatform,
    required this.username,
  });

  @override
  ConsumerState<EditSosialMediaAnggotaPage> createState() =>
      _EditSosialMediaAnggotaPageState();
}

class _EditSosialMediaAnggotaPageState
    extends ConsumerState<EditSosialMediaAnggotaPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaPlatformController;
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _namaPlatformController =
        TextEditingController(text: widget.namaPlatform);
    _usernameController = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    _namaPlatformController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 12),
          child: FaIcon(icon, color: iconColor, size: 20),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: label,
                hintText: hint,
              ),
              validator: validator,
              keyboardType: keyboardType,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'website':
        return FontAwesomeIcons.globe;
      default:
        return FontAwesomeIcons.shareAlt;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'linkedin':
        return const Color(0xFF0077B5);
      case 'instagram':
        return const Color(0xFFE1306C);
      case 'website':
        return Colors.blueGrey;
      default:
        return MyTheme().primarySwatch;
    }
  }

  void _simpanPerubahan() {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'platform': _namaPlatformController.text,
        'username': _usernameController.text,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Data ${updatedData['platform']} berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );

      context.pop(updatedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MyTheme().primarySwatch;
    final icon = _getPlatformIcon(widget.namaPlatform);
    final iconColor = _getPlatformColor(widget.namaPlatform);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Media Sosial",
        style: TextStyle(color: Colors.white)),
        backgroundColor: theme,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField(
                icon: icon,
                iconColor: iconColor,
                label: "Nama Platform",
                hint: "Contoh: Facebook",
                controller: _namaPlatformController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nama platform tidak boleh kosong";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                icon: Icons.link,
                iconColor: Colors.grey,
                label: "Username / Link",
                hint: "https://example.com/username",
                controller: _usernameController,
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Username / Link tidak boleh kosong";
                  }
                  if (!Uri.tryParse(value)!.hasAbsolutePath) {
                    return 'Masukkan URL yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _simpanPerubahan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Simpan"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme,
                        side: BorderSide(color: theme),
                      ),
                      child: const Text("Batal"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
