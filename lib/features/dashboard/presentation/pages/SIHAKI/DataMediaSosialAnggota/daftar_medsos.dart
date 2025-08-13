import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';

class MediaSosialAnggota extends ConsumerStatefulWidget {
  const MediaSosialAnggota({super.key});

  @override
  ConsumerState<MediaSosialAnggota> createState() => _MediaSosialAnggotaState();
}

class _MediaSosialAnggotaState extends ConsumerState<MediaSosialAnggota> {
  final List<Map<String, String>> _daftarMedsos = [
    {'platform': 'Facebook', 'username': 'https://facebook.com/username'},
    {'platform': 'Twitter', 'username': 'https://twitter.com/username'},
    {'platform': 'LinkedIn', 'username': 'https://linkedin.com/in/username'},
    {'platform': 'Instagram', 'username': 'https://instagram.com/username'},
    {'platform': 'Website', 'username': 'https://websiteanda.com'},
  ];

  void _hapusData(int index) {
    final medsos = _daftarMedsos[index];
    _showDeleteConfirmationDialog(context, medsos, index);
  }

  void _editData(int index) {
    final medsos = _daftarMedsos[index];
    context.push('/edit-media-sosial-anggota', extra: medsos).then((value) {
      if (mounted && value != null && value is Map<String, String>) {
        setState(() {
          _daftarMedsos[index] = value;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data ${value['platform']} berhasil diperbarui'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, Map<String, String> medsos, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Konfirmasi Hapus",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Apakah kamu yakin ingin menghapus \"${medsos['platform']}\"?",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text("Batal", style: TextStyle(fontSize: 16)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                "Hapus",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              onPressed: () {
                setState(() => _daftarMedsos.removeAt(index));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Media sosial "${medsos['platform']}" telah dihapus'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  IconData? _getIcon(String nama) {
    switch (nama.toLowerCase()) {
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

  Color _getColor(String nama) {
    switch (nama.toLowerCase()) {
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
        return const Color.fromARGB(255, 178, 0, 191);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Media Sosial Anggota',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 178, 0, 191),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _daftarMedsos.isEmpty
          ? Center(
              child: Text(
                'Belum ada data media sosial.',
                style: theme.typographyRegular.bodyMedium,
              ),
            )
          : ListView.builder(
              itemCount: _daftarMedsos.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
  final medsos = _daftarMedsos[index];
  final icon = _getIcon(medsos['platform']!);
  final color = _getColor(medsos['platform']!);

  return Card(
    elevation: 3,
    shadowColor: Colors.black26,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  medsos['platform'] ?? '',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            medsos['username'] ?? '',
            style: theme.typographyRegular.bodyMedium.copyWith(
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                backgroundColor: theme.primarySwatch.withOpacity(0.1),
                radius: 18,
                child: IconButton(
                  icon: Icon(Icons.edit,
                      size: 18, color: theme.primarySwatch),
                  onPressed: () => _editData(index),
                  tooltip: 'Edit',
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.red.withOpacity(0.1),
                radius: 18,
                child: IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => _hapusData(index),
                  tooltip: 'Hapus',
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
},
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 178, 0, 191),
        onPressed: () {
          context.push('/tambah-media-sosial-anggota');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
