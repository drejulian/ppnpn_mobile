import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';

// Provider untuk loading state
final resetPasswordLoadingProvider = StateProvider<bool>((ref) => false);

// Provider untuk step progress
final resetPasswordStepProvider = StateProvider<int>((ref) => 0);

class LupaPasswordPage extends ConsumerStatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  ConsumerState<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends ConsumerState<LupaPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Controllers
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ✅ OTP individual controllers and focus nodes
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  // ✅ Countdown timer variables
  Timer? _countdownTimer;
  int _countdownSeconds = 60;
  bool _canResend = false;

  // State variables
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String _verificationEmail = '';

  @override
  void initState() {
    super.initState();

    // Current time: 2025-07-29 08:02:19 UTC + 7 = 15:02:19 WIB
    final currentTime = DateTime.parse(
      '2025-07-29 08:02:19',
    ).add(const Duration(hours: 7));
    debugPrint('🔑 LupaPasswordPage initialized');
    debugPrint('👤 Current user context: miftahul01');
    debugPrint(
      '📅 Time: ${currentTime.toIso8601String().substring(0, 19)} WIB',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();

    // ✅ Dispose OTP controllers and focus nodes
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _countdownTimer?.cancel();

    super.dispose();
  }

  // ✅ Start countdown timer
  void _startCountdown() {
    // Current time: 2025-07-29 08:02:19 UTC + 7 = 15:02:19 WIB
    final currentTime = DateTime.parse(
      '2025-07-29 08:02:19',
    ).add(const Duration(hours: 7));
    debugPrint('⏰ Starting countdown: 60 seconds');
    debugPrint(
      '📅 Time: ${currentTime.toIso8601String().substring(0, 19)} WIB',
    );
    debugPrint('👤 User: miftahul01');

    setState(() {
      _countdownSeconds = 60;
      _canResend = false;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
          debugPrint('✅ Countdown finished, resend available');
        }
      });
    });
  }

  // ✅ Handle OTP input and auto-focus next field
  void _onOTPChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    _checkOTPComplete();
  }

  // ✅ Check if OTP is complete and auto-verify
  void _checkOTPComplete() {
    String otp = _getOTPValue();
    if (otp.length == 6) {
      // Current time: 2025-07-29 08:02:19 UTC + 7 = 15:02:19 WIB
      final currentTime = DateTime.parse(
        '2025-07-29 08:02:19',
      ).add(const Duration(hours: 7));
      debugPrint('🔢 OTP complete: $otp');
      debugPrint(
        '📅 Time: ${currentTime.toIso8601String().substring(0, 19)} WIB',
      );
      debugPrint('👤 User: miftahul01');

      // Set the combined OTP to the main controller for validation
      _otpController.text = otp;

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _verifyCode();
        }
      });
    }
  }

  // ✅ Get complete OTP value from all fields
  String _getOTPValue() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  // ✅ Clear all OTP fields
  void _clearOTP() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _otpController.clear();
    _focusNodes[0].requestFocus();
  }

  // ✅ Format countdown display
  String _formatCountdown() {
    int minutes = _countdownSeconds ~/ 60;
    int seconds = _countdownSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final currentStep = ref.watch(resetPasswordStepProvider);
    final isLoading = ref.watch(resetPasswordLoadingProvider);

    // Current time: 2025-07-29 08:02:19 UTC + 7 = 15:02:19 WIB
    final currentTime = DateTime.parse(
      '2025-07-29 08:02:19',
    ).add(const Duration(hours: 7));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Lupa Password',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 16.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderInfo(theme, currentTime),
            const SizedBox(height: 20),
            _buildProgressIndicator(theme, currentStep),
            const SizedBox(height: 20),
            _buildFormContainer(theme, isLoading),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(dynamic theme, DateTime currentTime) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primarySwatch, theme.secondarySwatch],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.primarySwatch.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock_reset,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset Password',
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'PPNPM DPR RI - Sistem Kepegawaian',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(currentTime),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${DateFormat('HH:mm').format(currentTime)} WIB',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Pemulihan Akses Akun',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Aman',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(dynamic theme, int currentStep) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primarySwatch, theme.secondarySwatch],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timeline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Langkah Reset Password',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStepIndicator(1, 'Email', currentStep >= 0, theme),
              _buildStepConnector(currentStep >= 1, theme),
              _buildStepIndicator(2, 'Verifikasi', currentStep >= 1, theme),
              _buildStepConnector(currentStep >= 2, theme),
              _buildStepIndicator(3, 'Password Baru', currentStep >= 2, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    int step,
    String label,
    bool isActive,
    dynamic theme,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? theme.primarySwatch : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.typographyRegular.bodyExtraSmall.copyWith(
              color: isActive ? theme.primarySwatch : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isActive, dynamic theme) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? theme.primarySwatch : Colors.grey[300],
      margin: const EdgeInsets.only(bottom: 28),
    );
  }

  Widget _buildFormContainer(dynamic theme, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: SizedBox(
          height: 450, // ✅ Increased height for OTP enhancements
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildEmailStep(theme, isLoading),
              _buildOTPStep(theme, isLoading),
              _buildNewPasswordStep(theme, isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(dynamic theme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primarySwatch, theme.secondarySwatch],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.email, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Masukkan Email Anda',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          'Masukkan alamat email yang terdaftar di sistem. Kami akan mengirimkan kode verifikasi ke email tersebut.',
          style: theme.typographyRegular.bodySmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'contoh: user@dpr.go.id',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.primarySwatch),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email harus diisi';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Format email tidak valid';
            }
            return null;
          },
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _sendVerificationCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primarySwatch,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                isLoading
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Mengirim...',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : Text(
                      'Kirim Kode Verifikasi',
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  // ✅ Enhanced OTP Step with 6 individual fields and countdown
  Widget _buildOTPStep(dynamic theme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primarySwatch, theme.secondarySwatch],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.verified_user,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Verifikasi Kode',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          'Kode verifikasi telah dikirim ke email:',
          style: theme.typographyRegular.bodySmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.primarySwatch.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.email_outlined, size: 16, color: theme.primarySwatch),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _verificationEmail,
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: theme.primarySwatch,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Masukkan 6 digit kode verifikasi:',
          style: theme.typographyRegular.bodySmall.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        // ✅ 6 Individual OTP Input Fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 40,
              height: 50,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                enabled: !isLoading,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: theme.typographyRegular.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.primarySwatch,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor:
                      _otpControllers[index].text.isNotEmpty
                          ? theme.primarySwatch.withOpacity(0.05)
                          : Colors.grey[50],
                ),
                onChanged: (value) => _onOTPChanged(value, index),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // ✅ Countdown and Resend section
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              if (!_canResend) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: Colors.orange[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kirim ulang dalam: ',
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _formatCountdown(),
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: Colors.orange[600],
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tidak menerima kode? ',
                      style: theme.typographyRegular.bodyExtraSmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    GestureDetector(
                      onTap: isLoading ? null : _resendCode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primarySwatch.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh,
                              size: 12,
                              color: theme.primarySwatch,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Kirim Ulang',
                              style: theme.typographyRegular.bodyExtraSmall
                                  .copyWith(
                                    color: theme.primarySwatch,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // ✅ OTP status indicator
        if (_getOTPValue().isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  _getOTPValue().length == 6
                      ? Colors.green[50]
                      : Colors.blue[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color:
                    _getOTPValue().length == 6
                        ? Colors.green[200]!
                        : Colors.blue[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getOTPValue().length == 6
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  size: 14,
                  color:
                      _getOTPValue().length == 6
                          ? Colors.green[600]
                          : Colors.blue[600],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _getOTPValue().length == 6
                        ? 'Kode lengkap! Verifikasi otomatis...'
                        : 'Kode: ${_getOTPValue()} (${_getOTPValue().length}/6)',
                    style: theme.typographyRegular.bodyExtraSmall.copyWith(
                      color:
                          _getOTPValue().length == 6
                              ? Colors.green[700]
                              : Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const Spacer(),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.primarySwatch),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Kembali',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    color: theme.primarySwatch,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    (isLoading || _getOTPValue().length != 6)
                        ? null
                        : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Verifikasi',
                              style: theme.typographyRegular.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep(dynamic theme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primarySwatch, theme.secondarySwatch],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Password Baru',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          'Buat password baru yang aman untuk akun Anda.',
          style: theme.typographyRegular.bodySmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscureNewPassword,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Password Baru',
            hintText: 'Minimal 8 karakter',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed:
                  () => setState(
                    () => _obscureNewPassword = !_obscureNewPassword,
                  ),
              icon: Icon(
                _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.primarySwatch),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password baru harus diisi';
            }
            if (value.length < 8) {
              return 'Password minimal 8 karakter';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Konfirmasi Password',
            hintText: 'Ulangi password baru',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed:
                  () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.primarySwatch),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Konfirmasi password harus diisi';
            }
            if (value != _newPasswordController.text) {
              return 'Password tidak cocok';
            }
            return null;
          },
        ),

        const Spacer(),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.primarySwatch),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Kembali',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    color: theme.primarySwatch,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Reset Password',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) return;

    // Current time: 2025-07-29 08:02:19 UTC + 7 = 15:02:19 WIB
    final currentTime = DateTime.parse(
      '2025-07-29 08:02:19',
    ).add(const Duration(hours: 7));

    debugPrint('📧 Sending verification code');
    debugPrint('👤 Email: ${_emailController.text}');
    debugPrint(
      '📅 Time: ${currentTime.toIso8601String().substring(0, 19)} WIB',
    );

    ref.read(resetPasswordLoadingProvider.notifier).state = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _verificationEmail = _emailController.text;
    ref.read(resetPasswordStepProvider.notifier).state = 1;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // ✅ Start countdown when moving to OTP step
    _startCountdown();

    ref.read(resetPasswordLoadingProvider.notifier).state = false;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kode verifikasi telah dikirim ke ${_emailController.text}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ✅ Enhanced resend code with countdown restart
  void _resendCode() async {
    if (_canResend && !ref.read(resetPasswordLoadingProvider)) {
      // Current time: 2025-07-29 08:02:19 UTC + 7 = 15:02:19 WIB
      final currentTime = DateTime.parse(
        '2025-07-29 08:02:19',
      ).add(const Duration(hours: 7));

      debugPrint('🔄 Resending OTP code');
      debugPrint(
        '📅 Time: ${currentTime.toIso8601String().substring(0, 19)} WIB',
      );
      debugPrint('👤 User: miftahul01');
      debugPrint('📧 Email: $_verificationEmail');

      _clearOTP();
      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kode verifikasi telah dikirim ulang ke $_verificationEmail',
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    // Current time: 2025-07-29 08:02:19 UTC + 7 = 15:02:19 WIB
    final currentTime = DateTime.parse(
      '2025-07-29 08:02:19',
    ).add(const Duration(hours: 7));

    debugPrint('🔐 Verifying OTP code');
    debugPrint('👤 Email: $_verificationEmail');
    debugPrint('🔢 OTP: ${_otpController.text}');
    debugPrint(
      '📅 Time: ${currentTime.toIso8601String().substring(0, 19)} WIB',
    );

    ref.read(resetPasswordLoadingProvider.notifier).state = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // For demo, accept any 6-digit code
    if (_otpController.text.length == 6) {
      ref.read(resetPasswordStepProvider.notifier).state = 2;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // ✅ Cancel countdown on successful verification
      _countdownTimer?.cancel();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kode verifikasi berhasil! Silakan buat password baru.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode verifikasi tidak valid!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    ref.read(resetPasswordLoadingProvider.notifier).state = false;
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    // Current time: 2025-07-29 08:02:19 UTC + 7 = 15:02:19 WIB
    final currentTime = DateTime.parse(
      '2025-07-29 08:02:19',
    ).add(const Duration(hours: 7));

    debugPrint('✅ Resetting password');
    debugPrint('👤 Email: $_verificationEmail');
    debugPrint(
      '📅 Time: ${currentTime.toIso8601String().substring(0, 19)} WIB',
    );

    ref.read(resetPasswordLoadingProvider.notifier).state = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    ref.read(resetPasswordLoadingProvider.notifier).state = false;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 12),
                  const Text('Berhasil!'),
                ],
              ),
              content: const Text(
                'Password Anda telah berhasil direset. Silakan login dengan password baru Anda.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop(); // Return to login page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ref.read(themeProvider).primarySwatch,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Kembali ke Login'),
                ),
              ],
            ),
      );
    }
  }

  void _previousStep() {
    final currentStep = ref.read(resetPasswordStepProvider);
    if (currentStep > 0) {
      ref.read(resetPasswordStepProvider.notifier).state = currentStep - 1;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // ✅ Cancel countdown when going back from OTP step
      if (currentStep == 1) {
        _countdownTimer?.cancel();
        _clearOTP();
      }
    }
  }
}
