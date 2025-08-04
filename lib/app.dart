import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: AppContent());
  }
}

class AppContent extends ConsumerStatefulWidget {
  const AppContent({super.key});

  @override
  ConsumerState<AppContent> createState() => _AppContentState();
}

class _AppContentState extends ConsumerState<AppContent> {
  @override
  void initState() {
    super.initState();
    // initPlatformState();
    _handleInitialDeepLink();
    // _setupNotificationHandlers();
  }

  Future<void> _handleInitialDeepLink() async {
    try {
      final initialUri = Uri.base;
      if (initialUri.path != '/') {
        final goRouter = ref.read(routerProvider);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          goRouter.go(initialUri.path);
        });
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  // void _setupNotificationHandlers() {
  //   OneSignal.Notifications.addClickListener((event) {
  //     if (event.notification.additionalData != null) {
  //       final notificationData = event.notification.additionalData!;

  //       if (notificationData.containsKey('navigate')) {
  //         final route = notificationData['navigate'];
  //         _handleDynamicNavigation(route);
  //       }
  //     }
  //   });
  // }

  // Fungsi untuk menangani navigasi dinamis
  // void _handleDynamicNavigation(String route) {
  //   final goRouter = ref.read(routerProvider);
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     try {
  //       // Cek apakah route adalah nama rute yang valid
  //       final routeExists = Routes.values.any((r) => r.name == route);
  //       if (routeExists) {
  //         goRouter.goNamed(route);
  //       } else {
  //         // Alternatif: coba navigasi langsung ke path jika nama rute tidak ditemukan
  //         final path = route.startsWith('/') ? route : '/$route';
  //         goRouter.go(path);
  //       }
  //     } catch (e) {
  //       goRouter.goNamed(Routes.home.name);
  //     }
  //   });
  // }

  // Future<void> initPlatformState() async {
  //   await Future.delayed(const Duration(seconds: 2));

  //   final pushSubscription = OneSignal.User.pushSubscription;
  //   String? playerId = pushSubscription.id;

  //   // log('id one signal : $playerId');

  //   if (playerId != null) {
  //     ref.read(getLocalOneSignalIdProvider.notifier).updateId(playerId);
  //   }

  //   pushSubscription.addObserver((state) {
  //     String? updatedPlayerId = state.current.id;
  //     if (updatedPlayerId != null) {
  //       ref
  //           .read(getLocalOneSignalIdProvider.notifier)
  //           .updateId(updatedPlayerId);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final routerConfig = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: routerConfig,
      debugShowCheckedModeBanner: false,
      title: 'Cakrawala',
      theme: theme.buildLightTheme(context),
    );
  }
}
