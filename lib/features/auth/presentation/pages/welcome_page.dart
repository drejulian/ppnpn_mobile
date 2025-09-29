import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/routes.dart';
import 'package:ppnpm_dpr/app/theme.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    context.pushNamed(Routes.login.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  _buildWelcomeHeader(theme),
                  const SizedBox(height: 40),
                  _buildFeatureCards(theme),
                  const SizedBox(height: 40),
                  _buildActionButtons(theme),
                  const SizedBox(height: 30),
                  _buildFooter(theme),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(dynamic theme) {
    final currentTime = DateTime.now();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Logo with enhanced animation
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 25,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.primarySwatch, theme.secondarySwatch],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.apartment,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Main title
            Text(
              'Selamat Datang',
              style: theme.typographyBold.headingMedium.copyWith(
                color: Colors.white,
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'PPNPN DPR RI',
              style: theme.typographyRegular.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Sistem Manajemen Kepegawaian\nDewan Perwakilan Rakyat Republik Indonesia',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16.0,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Time badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat(
                      'EEEE, dd MMMM yyyy • HH:mm',
                      'id_ID',
                    ).format(currentTime),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 12.0,
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

  Widget _buildFeatureCards(dynamic theme) {
    final features = [
      {
        'icon': Icons.person_outline,
        'title': 'Manajemen Data',
        'description': 'Kelola data pribadi dan kepegawaian dengan mudah',
      },
      {
        'icon': Icons.schedule_outlined,
        'title': 'Absensi Digital',
        'description': 'Sistem absensi modern dan terintegrasi',
      },
      {
        'icon': Icons.document_scanner_outlined,
        'title': 'Dokumen Digital',
        'description': 'Akses dan kelola dokumen secara digital',
      },
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Text(
            'Fitur Unggulan',
            style: theme.typographyBold.bodyLarge.copyWith(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            
            return AnimatedContainer(
              duration: Duration(milliseconds: 800 + (index * 200)),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['title'] as String,
                            style: theme.typographyBold.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feature['description'] as String,
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13.0,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Main login button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.primarySwatch,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: Row(
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

            const SizedBox(height: 20),

            // Additional info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sistem dilindungi dengan keamanan tingkat tinggi untuk menjaga data Anda',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12.0,
                        height: 1.3,
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

  Widget _buildFooter(dynamic theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Divider(
            color: Colors.white.withOpacity(0.3),
            thickness: 1,
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.copyright,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '2025 PPNPN DPR RI',
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Text(
            'Dewan Perwakilan Rakyat Republik Indonesia',
            style: theme.typographyRegular.bodyExtraSmall.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Version info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Versi 1.0.0',
              style: theme.typographyRegular.bodyExtraSmall.copyWith(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
