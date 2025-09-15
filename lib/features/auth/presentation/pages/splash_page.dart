import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';

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
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        navigateToWelcome();
      }
    } catch (e) {
      debugPrint('Error in splash timer: $e');
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
            Icon(Icons.apartment_rounded, size: 100),
            Text('PPNPN DPR', style: theme.typographyBold.bodyMedium),
          ],
        ),
      ),
    );
  }
}
