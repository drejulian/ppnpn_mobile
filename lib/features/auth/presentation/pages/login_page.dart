import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // SharedPreferences keys
  static const String _keyRememberMe = 'remember_me';
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';
  static const String _keyLastLogin = 'last_login_time';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Load saved credentials from SharedPreferences
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRememberMe = prefs.getBool(_keyRememberMe) ?? false;

      if (savedRememberMe) {
        final savedEmail = prefs.getString(_keyEmail) ?? '';
        final savedPassword = prefs.getString(_keyPassword) ?? '';

        setState(() {
          _rememberMe = savedRememberMe;
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
        });

        if (savedEmail.isNotEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kredensial tersimpan untuk: $savedEmail',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.blue[600],
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Handle error silently in production
    }
  }

  // Save credentials to SharedPreferences
  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentTime = DateTime.now();

      if (_rememberMe) {
        await prefs.setBool(_keyRememberMe, true);
        await prefs.setString(_keyEmail, _emailController.text);
        await prefs.setString(_keyPassword, _passwordController.text);
        await prefs.setString(_keyLastLogin, currentTime.toIso8601String());
      } else {
        // Clear saved credentials if remember me is unchecked
        await prefs.setBool(_keyRememberMe, false);
        await prefs.remove(_keyEmail);
        await prefs.remove(_keyPassword);
        await prefs.remove(_keyLastLogin);
      }
    } catch (e) {
      // Handle error silently in production
    }
  }

  // Clear saved credentials
  Future<void> _clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyRememberMe);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyPassword);
      await prefs.remove(_keyLastLogin);
    } catch (e) {
      // Handle error silently in production
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Save credentials before login attempt
      await _saveCredentials();

      // Simulate login process
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Navigate to home after successful login
      if (mounted) {
        // Update last login time on successful login
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            _keyLastLogin,
            DateTime.now().toIso8601String(),
          );
        } catch (e) {
          // Handle error silently
        }

        // Check if widget is still mounted before using context
        if (mounted) {
          context.goNamed(Routes.home.name);
        }
      }
    }
  }

  void _handleForgotPassword() {
    context.pushNamed(Routes.lupaPassword.name);
  }

  // Handle remember me toggle
  void _handleRememberMeChanged(bool? value) {
    setState(() {
      _rememberMe = value ?? false;
    });

    // If unchecked, show option to clear saved data
    if (!_rememberMe) {
      _showClearCredentialsDialog();
    }
  }

  // Show dialog to clear saved credentials
  void _showClearCredentialsDialog() {
    // Capture necessary values before showing dialog
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.cleaning_services,
                color: Colors.orange[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text('Hapus Data Tersimpan?'),
            ],
          ),
          content: const Text(
            'Apakah Anda ingin menghapus email dan password yang tersimpan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close dialog first
                Navigator.pop(dialogContext);

                // Perform async operation
                await _clearSavedCredentials();

                // Show success message using captured ScaffoldMessenger
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text('Data tersimpan berhasil dihapus'),
                      ],
                    ),
                    backgroundColor: Colors.green[600],
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  40,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _buildLogoSection(theme),
                  const SizedBox(height: 40),
                  _buildLoginForm(theme),
                  const SizedBox(height: 30),
                  _buildBottomSection(theme),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(dynamic theme) {
    final currentTime = DateTime.now();

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.primarySwatch, theme.secondarySwatch],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.primarySwatch.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.apartment, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 20),

        Text(
          'PPNPN DPR RI',
          style: theme.typographyRegular.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primarySwatch,
            fontSize: 26.0,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          'Sistem Manajemen Kepegawaian',
          style: theme.typographyRegular.bodyMedium.copyWith(
            color: Colors.grey[600],
            fontSize: 15.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.primarySwatch.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            DateFormat(
              'EEEE, dd MMMM yyyy • HH:mm',
              'id_ID',
            ).format(currentTime),
            style: theme.typographyRegular.bodyExtraSmall.copyWith(
              color: theme.primarySwatch,
              fontWeight: FontWeight.w500,
              fontSize: 11.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(dynamic theme) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Masuk ke Akun Anda',
              style: theme.typographyRegular.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan masukkan email dan password Anda',
              style: theme.typographyRegular.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontSize: 13.0,
              ),
            ),
            const SizedBox(height: 24),

            _buildInputField(
              controller: _emailController,
              label: 'Email',
              hint: 'Masukkan email Anda',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
              theme: theme,
            ),
            const SizedBox(height: 16),

            _buildInputField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Masukkan password Anda',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Remember Me and Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: _handleRememberMeChanged,
                        activeColor: theme.primarySwatch,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _handleRememberMeChanged(!_rememberMe),
                      child: Row(
                        children: [
                          Text(
                            'Ingat saya',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[700],
                              fontSize: 12.0,
                            ),
                          ),
                          if (_rememberMe)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.verified,
                                size: 14,
                                color: theme.primarySwatch,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _handleForgotPassword,
                  child: Text(
                    'Lupa password?',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: theme.primarySwatch,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          'Masuk',
                          style: theme.typographyRegular.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 20),

            // User context info with saved data indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _rememberMe ? Icons.save : Icons.info_outline,
                    size: 14,
                    color: _rememberMe ? Colors.green[600] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _rememberMe
                          ? 'Data tersimpan untuk: miftahul01 (Demo Mode)'
                          : 'Login sebagai: miftahul01 (Demo Mode)',
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: Colors.grey[600],
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                ],
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
          obscureText: isPassword && !_isPasswordVisible,
          validator: validator,
          style: theme.typographyRegular.bodyMedium.copyWith(fontSize: 14.0),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0),
            prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            isDense: true,
          ),
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

        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur login tamu akan segera tersedia'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
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
                  Icons.person_outline,
                  color: theme.primarySwatch,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Masuk sebagai Tamu',
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
