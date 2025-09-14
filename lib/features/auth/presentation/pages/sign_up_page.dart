import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaLengkapController = TextEditingController();
  final _nikController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomorTeleponController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  // Dropdown values
  String _selectedJabatan = 'PPNPN';
  String _selectedUnit = 'Sekretariat Jenderal';

  // Dropdown options
  final List<String> _jabatanOptions = [
    'PPNPN',
    'ASN',
    'Honorer',
    'Kontrak',
  ];

  final List<String> _unitOptions = [
    'Sekretariat Jenderal',
    'Badan Keahlian DPR RI',
    'Badan Sosialisasi MPR',
    'Sekretariat Komisi I',
    'Sekretariat Komisi II',
    'Sekretariat Komisi III',
    'Sekretariat Komisi IV',
    'Sekretariat Komisi V',
    'Sekretariat Komisi VI',
    'Sekretariat Komisi VII',
    'Sekretariat Komisi VIII',
    'Sekretariat Komisi IX',
    'Sekretariat Komisi X',
    'Sekretariat Komisi XI',
  ];

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _nomorTeleponController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        _showErrorSnackBar('Anda harus menyetujui syarat dan ketentuan');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simulate registration process
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _isLoading = false;
      });

      // Show success dialog
      if (mounted) {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Registrasi Berhasil'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Akun Anda telah berhasil didaftarkan!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, 
                             color: Colors.blue[600], size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Informasi Penting:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Akun Anda perlu diverifikasi oleh admin\n'
                      '• Proses verifikasi membutuhkan 1-2 hari kerja\n'
                      '• Anda akan menerima notifikasi via email',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pushReplacementNamed(Routes.login.name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Kembali ke Login'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _navigateToLogin() {
    context.pushReplacementNamed(Routes.login.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 48.0 : 24.0,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildHeader(theme),
              const SizedBox(height: 30),
              _buildSignUpForm(theme),
              const SizedBox(height: 20),
              _buildBottomSection(theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.primarySwatch, theme.secondarySwatch],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.primarySwatch.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.person_add, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),

        Text(
          'Daftar Akun Baru',
          style: theme.typographyRegular.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primarySwatch,
            fontSize: 24.0,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          'PPNPN DPR RI',
          style: theme.typographyRegular.bodyMedium.copyWith(
            color: Colors.grey[600],
            fontSize: 16.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignUpForm(dynamic theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Pribadi',
              style: theme.typographyRegular.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lengkapi data diri Anda dengan benar',
              style: theme.typographyRegular.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontSize: 13.0,
              ),
            ),
            const SizedBox(height: 20),

            // Nama Lengkap
            _buildInputField(
              controller: _namaLengkapController,
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkap sesuai KTP',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama lengkap tidak boleh kosong';
                }
                if (value.length < 3) {
                  return 'Nama lengkap minimal 3 karakter';
                }
                return null;
              },
              theme: theme,
            ),
            const SizedBox(height: 16),

            // NIK
            _buildInputField(
              controller: _nikController,
              label: 'NIK (Nomor Induk Kependudukan)',
              hint: 'Masukkan 16 digit NIK',
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'NIK tidak boleh kosong';
                }
                if (value.length != 16) {
                  return 'NIK harus 16 digit';
                }
                return null;
              },
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Email
            _buildInputField(
              controller: _emailController,
              label: 'Email',
              hint: 'Masukkan alamat email aktif',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Nomor Telepon
            _buildInputField(
              controller: _nomorTeleponController,
              label: 'Nomor Telepon',
              hint: 'Masukkan nomor telepon aktif',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor telepon tidak boleh kosong';
                }
                if (value.length < 10) {
                  return 'Nomor telepon minimal 10 digit';
                }
                return null;
              },
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Jabatan Dropdown
            _buildDropdownField(
              label: 'Jabatan',
              value: _selectedJabatan,
              items: _jabatanOptions,
              icon: Icons.work_outline,
              onChanged: (value) {
                setState(() {
                  _selectedJabatan = value!;
                });
              },
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Unit Kerja Dropdown
            _buildDropdownField(
              label: 'Unit Kerja',
              value: _selectedUnit,
              items: _unitOptions,
              icon: Icons.business_outlined,
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value!;
                });
              },
              theme: theme,
            ),
            const SizedBox(height: 20),

            // Divider
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 20),

            // Security Section
            Text(
              'Keamanan Akun',
              style: theme.typographyRegular.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Buat password yang kuat untuk melindungi akun Anda',
              style: theme.typographyRegular.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontSize: 13.0,
              ),
            ),
            const SizedBox(height: 20),

            // Password
            _buildInputField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Minimal 8 karakter dengan huruf dan angka',
              icon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _isPasswordVisible,
              onTogglePassword: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                if (value.length < 8) {
                  return 'Password minimal 8 karakter';
                }
                if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(value)) {
                  return 'Password harus mengandung huruf dan angka';
                }
                return null;
              },
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Confirm Password
            _buildInputField(
              controller: _confirmPasswordController,
              label: 'Konfirmasi Password',
              hint: 'Masukkan ulang password Anda',
              icon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _isConfirmPasswordVisible,
              onTogglePassword: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password tidak boleh kosong';
                }
                if (value != _passwordController.text) {
                  return 'Password tidak cocok';
                }
                return null;
              },
              theme: theme,
            ),
            const SizedBox(height: 20),

            // Terms and Conditions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: theme.primarySwatch,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreeToTerms = !_agreeToTerms;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.grey[700],
                          fontSize: 12.0,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'Saya menyetujui '),
                          TextSpan(
                            text: 'Syarat dan Ketentuan',
                            style: TextStyle(
                              color: theme.primarySwatch,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' serta '),
                          TextSpan(
                            text: 'Kebijakan Privasi',
                            style: TextStyle(
                              color: theme.primarySwatch,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' yang berlaku'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Daftar Sekarang',
                        style: theme.typographyRegular.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required dynamic theme,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 13.0,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !isPasswordVisible,
          validator: validator,
          style: theme.typographyRegular.bodyMedium.copyWith(fontSize: 14.0),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0),
            prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.primarySwatch, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
    required dynamic theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 13.0,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.primarySwatch, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            isDense: true,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: theme.typographyRegular.bodyMedium.copyWith(fontSize: 14.0),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildBottomSection(dynamic theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'atau',
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11.0,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 16),

        // Login Button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: _navigateToLogin,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.primarySwatch),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.login,
                  color: theme.primarySwatch,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sudah punya akun? Masuk di sini',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    color: theme.primarySwatch,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'PPNPN DPR RI © 2025',
          style: theme.typographyRegular.bodySmall.copyWith(
            color: Colors.grey[500],
            fontSize: 11.0,
          ),
        ),
      ],
    );
  }
}
