import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/common/theme/my_theme.dart';

class TambahMediaSosialAnggotaPage extends ConsumerStatefulWidget {
  const TambahMediaSosialAnggotaPage({super.key});

  @override
  ConsumerState<TambahMediaSosialAnggotaPage> createState() =>
      _TambahMediaSosialAnggotaPageState();
}

class _TambahMediaSosialAnggotaPageState
    extends ConsumerState<TambahMediaSosialAnggotaPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  @override
  void dispose() {
    _facebookController.dispose();
    _twitterController.dispose();
    _linkedinController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    final theme = MyTheme().primarySwatch;
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
              keyboardType: TextInputType.url,
            ),
          ),
        ),
      ],
    );
  }

  void _simpanData() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'facebook': _facebookController.text,
        'twitter': _twitterController.text,
        'linkedin': _linkedinController.text,
        'instagram': _instagramController.text,
        'website': _websiteController.text,
      };
      print('Media Sosial Data: $data');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data media sosial berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MyTheme().primarySwatch;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Media Sosial",
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
                icon: FontAwesomeIcons.facebook,
                iconColor: const Color(0xFF1877F2),
                label: 'Facebook URL',
                hint: 'https://facebook.com/username',
                controller: _facebookController,
              ),
              const SizedBox(height: 16),
              _buildField(
                icon: FontAwesomeIcons.twitter,
                iconColor: const Color(0xFF1DA1F2),
                label: 'Twitter URL',
                hint: 'https://twitter.com/username',
                controller: _twitterController,
              ),
              const SizedBox(height: 16),
              _buildField(
                icon: FontAwesomeIcons.linkedin,
                iconColor: const Color(0xFF0077B5),
                label: 'LinkedIn URL',
                hint: 'https://linkedin.com/in/username',
                controller: _linkedinController,
              ),
              const SizedBox(height: 16),
              _buildField(
                icon: FontAwesomeIcons.instagram,
                iconColor: const Color(0xFFE1306C),
                label: 'Instagram URL',
                hint: 'https://instagram.com/username',
                controller: _instagramController,
              ),
              const SizedBox(height: 16),
              _buildField(
                icon: FontAwesomeIcons.globe,
                iconColor: Colors.blueGrey,
                label: 'Website URL',
                hint: 'https://websiteanda.com',
                controller: _websiteController,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _simpanData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Simpan"),
                    ),
                  ),
                  const SizedBox(width: 1),
                  
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
