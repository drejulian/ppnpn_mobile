import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import '../providers/auth_provider.dart';
import '../../data/services/auth_storage_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    // Debug storage for testing
    AuthStorageService.debugStorage();
  }

  // Load saved credentials if remember me was checked previously
  Future<void> _loadSavedCredentials() async {
    try {
      final rememberMe = await AuthStorageService.getRememberMe();
      if (rememberMe) {
        final credentials = await AuthStorageService.getSavedCredentials();
        if (credentials['email'] != null && credentials['password'] != null) {
          setState(() {
            _emailController.text = credentials['email']!;
            _passwordController.text = credentials['password']!;
            _rememberMe = true;
          });
          print('✅ LoginPage: Loaded saved credentials for ${credentials['email']}');
        }
      }
    } catch (e) {
      print('⚠️ LoginPage: Error loading saved credentials: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (mounted && success) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primarySwatch.shade300,
              theme.primarySwatch.shade600,
              theme.secondarySwatch.shade700,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 48.0 : 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Header Section
                _buildHeader(theme),
                
                const SizedBox(height: 40),
                
                // Login Form
                _buildLoginForm(theme),
                
                const SizedBox(height: 30),
                
                // Footer
                _buildFooter(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic theme) {
    return Column(
      children: [
        // App Logo/Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.account_circle_outlined,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        
        // Title
        Text(
          'PPNPN DPR RI',
          style: theme.typographyBold.headingLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 28.0,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Masuk ke Akun Anda',
          style: theme.typographyRegular.bodyLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Remember Me dan Lupa Password
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) async {
                    setState(() => _rememberMe = value ?? false);
                    
                    // If unchecked, clear saved credentials
                    if (!_rememberMe) {
                      try {
                        await AuthStorageService.clearSavedCredentials();
                        await AuthStorageService.saveRememberMe(false);
                        print('🗑️ LoginPage: Cleared saved credentials');
                      } catch (e) {
                        print('⚠️ LoginPage: Error clearing credentials: $e');
                      }
                    }
                  },
                  activeColor: Colors.white,
                  checkColor: theme.primarySwatch,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  'Ingat saya',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/lupa-password'),
                  child: Text(
                    'Lupa Password?',
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Login Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.primarySwatch,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primarySwatch,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login,
                            color: theme.primarySwatch,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Masuk ke Akun',
                            style: theme.typographyBold.bodyLarge.copyWith(
                              color: theme.primarySwatch,
                              fontWeight: FontWeight.w600,
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(dynamic theme) {
    return Column(
      children: [
        // Back to Welcome Button
        TextButton.icon(
          onPressed: () => context.go('/welcome'),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          label: Text(
            'Kembali ke Halaman Utama',
            style: theme.typographyRegular.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Security Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sistem dilindungi dengan keamanan tingkat tinggi untuk menjaga data Anda',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12.0,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Footer Copyright
        Divider(
          color: Colors.white.withValues(alpha: 0.3),
          thickness: 1,
        ),
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.copyright,
              color: Colors.white.withValues(alpha: 0.7),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '2025 PPNPN DPR RI',
              style: theme.typographyRegular.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
