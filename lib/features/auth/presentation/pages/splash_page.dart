import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../providers/auth_provider.dart';
import '../../data/services/auth_storage_service.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  void _startTimer() async {
    try {
      // Debug test Flutter Secure Storage
      await AuthStorageService.debugStorage();
      
      // Wait for splash animation (reduce from 2s to 1s for better UX)
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        await _checkAuthAndNavigate();
      }
    } catch (e) {
      debugPrint('Error in splash timer: $e');
      if (mounted) {
        context.pushReplacementNamed(Routes.login.name);
      }
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Wait for auth initialization to complete properly
      debugPrint('🔍 Checking auth state...');
      
      // Poll auth state until it's no longer loading
      AuthState authState = ref.read(authProvider);
      int attempts = 0;
      const maxAttempts = 20; // Max 10 seconds waiting
      
      while (authState.isLoading && attempts < maxAttempts) {
        debugPrint('⏳ Auth still loading, waiting... (attempt ${attempts + 1})');
        await Future.delayed(const Duration(milliseconds: 500));
        authState = ref.read(authProvider);
        attempts++;
      }
      
      if (attempts >= maxAttempts) {
        debugPrint('⚠️ Auth loading timeout, navigating to welcome');
        navigateToWelcome();
        return;
      }
      
      debugPrint('✅ Auth state loaded: isAuthenticated=${authState.isAuthenticated}');
      debugPrint('📋 Token: ${authState.token != null ? "Present" : "None"}');
      debugPrint('👤 User: ${authState.userName ?? "None"}');
      
      if (authState.isAuthenticated && authState.token != null) {
        // User sudah login, langsung ke home
        debugPrint('🏠 User sudah login, navigasi ke home');
        if (mounted) {
          context.pushReplacementNamed(Routes.home.name);
        }
      } else {
        // User belum login, ke welcome page
        debugPrint('👋 User belum login, navigasi ke welcome');
        if (mounted) {
          navigateToWelcome();
        }
      }
    } catch (e) {
      // Jika error, ke login page
      debugPrint('❌ Error checking auth: $e');
      if (mounted) {
        context.pushReplacementNamed(Routes.login.name);
      }
    }
  }

  void navigateToWelcome() {
    try {
      context.pushReplacementNamed(Routes.welcome.name);
    } catch (e) {
      // Jika welcome gagal, redirect ke login
      debugPrint('Error navigating to welcome: $e');
      context.pushReplacementNamed(Routes.login.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading indicator with app logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primarySwatch.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.apartment_rounded,
                size: 80,
                color: theme.primarySwatch,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'PPNPN DPR',
              style: theme.typographyBold.bodyLarge.copyWith(
                color: theme.primarySwatch,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 10),
            
            Text(
              'Sistem Informasi Pegawai',
              style: theme.typographyRegular.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Loading indicator
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primarySwatch),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
