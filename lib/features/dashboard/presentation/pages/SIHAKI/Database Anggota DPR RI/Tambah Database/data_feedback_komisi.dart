import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'package:ppnpm_dpr/features/dashboard/presentation/pages/SIHAKI/Database%20Anggota%20DPR%20RI/providers.dart';
// SQLite imports
import 'package:ppnpm_dpr/common/data/models/sihaki/feedback_komisi_model.dart';
import 'package:ppnpm_dpr/common/data/repositories/sihaki/feedback_komisi_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataFeedbackKomisiPage extends ConsumerStatefulWidget {
  const DataFeedbackKomisiPage({super.key});

  @override
  ConsumerState<DataFeedbackKomisiPage> createState() =>
      _DataFeedbackKomisiPageState();
}

class _DataFeedbackKomisiPageState
    extends ConsumerState<DataFeedbackKomisiPage> {
  final _formKey = GlobalKey<FormState>();
  final _topikController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _saranController = TextEditingController();
  String? _ratingKinerja;
  bool _isEditing = false;
  bool _isLoadingData = false;
  FeedbackKomisiModel? _existingFeedback;
  late final FeedbackKomisiRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = FeedbackKomisiRepository();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedData();
    });
  }

  Future<void> _testRatingKinerjaSpecifically() async {
    try {
      print('DEBUG: 🎯 ========== TESTING RATING KINERJA SPECIFICALLY ==========');
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id') ?? 'current_user';
      
      // Test 1: Check current UI state
      print('DEBUG: 1️⃣ Current UI state:');
      print('   - _ratingKinerja variable: "$_ratingKinerja"');
      print('   - _ratingKinerja is null? ${_ratingKinerja == null}');
      print('   - _ratingKinerja is empty? ${_ratingKinerja?.isEmpty ?? true}');
      
      // Test 2: Check database
      final userFeedbacks = await _repository.getFeedbackKomisiByUserId(userId);
      if (userFeedbacks.isNotEmpty) {
        final recent = userFeedbacks.first;
        print('DEBUG: 2️⃣ Database state:');
        print('   - Database rating: "${recent.ratingKinerja}"');
        print('   - Database rating is empty? ${recent.ratingKinerja.isEmpty}');
        print('   - UI vs DB match? ${_ratingKinerja == recent.ratingKinerja}');
      }
      
      // Test 3: Check SharedPreferences 
      final savedRating = prefs.getString('feedback_rating');
      print('DEBUG: 3️⃣ SharedPreferences state:');
      print('   - Saved rating: "$savedRating"');
      print('   - Saved rating is null? ${savedRating == null}');
      
      // Test 4: Try manual assignment
      print('DEBUG: 4️⃣ Testing manual assignment:');
      final testRating = 'Baik (4)';
      setState(() {
        _ratingKinerja = testRating;
      });
      print('   - Manual assignment to "$testRating"');
      print('   - After assignment: "$_ratingKinerja"');
      
      print('DEBUG: ========================================');
      
    } catch (e) {
      print('DEBUG: ❌ Error testing rating kinerja: $e');
    }
  }

  Future<void> _loadSavedData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      // Load from SharedPreferences for current user
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id') ?? 'current_user';
      
      // Load from database
      final userFeedbacks = await _repository.getFeedbackKomisiByUserId(userId);
      
      if (userFeedbacks.isNotEmpty) {
        // Use the most recent feedback
        final recentFeedback = userFeedbacks.first;
        
        print('DEBUG: 📊 Loading feedback from database:');
        print('  - ID: ${recentFeedback.id}');
        print('  - Topik: "${recentFeedback.topik}"');
        print('  - Feedback: "${recentFeedback.feedback}"');
        print('  - Rating Kinerja: "${recentFeedback.ratingKinerja}"');
        print('  - Saran: "${recentFeedback.saranPerbaikan ?? 'Kosong'}"');
        
        // EXPLICIT RATING TEST
        print('DEBUG: 🎯 BEFORE setState - _ratingKinerja: "$_ratingKinerja"');
        
        setState(() {
          _existingFeedback = recentFeedback;
          _topikController.text = recentFeedback.topik;
          _feedbackController.text = recentFeedback.feedback;
          _saranController.text = recentFeedback.saranPerbaikan ?? '';
          _ratingKinerja = recentFeedback.ratingKinerja.isEmpty ? null : recentFeedback.ratingKinerja;
        });
        
        print('DEBUG: 🎯 AFTER setState - _ratingKinerja: "$_ratingKinerja"');
        print('DEBUG: 🎯 Rating empty check: ${recentFeedback.ratingKinerja.isEmpty}');
        
        // Save to SharedPreferences as backup
        await prefs.setString('feedback_topik', recentFeedback.topik);
        await prefs.setString('feedback_content', recentFeedback.feedback);
        await prefs.setString('feedback_rating', recentFeedback.ratingKinerja);
        await prefs.setString('feedback_saran', recentFeedback.saranPerbaikan ?? '');
        
        print('DEBUG: 💾 Backup to SharedPreferences completed');
      } else {
        // Load from SharedPreferences as fallback
        final savedRating = prefs.getString('feedback_rating');
        setState(() {
          _topikController.text = prefs.getString('feedback_topik') ?? '';
          _feedbackController.text = prefs.getString('feedback_content') ?? '';
          _saranController.text = prefs.getString('feedback_saran') ?? '';
          _ratingKinerja = savedRating?.isEmpty == true ? null : savedRating;
        });
        
        print('DEBUG: 📦 Loaded feedback data from SharedPreferences (fallback)');
        print('DEBUG: 📦 Fallback rating: "$savedRating"');
      }

      _updateFilledStatus();
    } catch (e) {
      print('ERROR: Failed to load feedback data: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  void _updateFilledStatus() {
    if (_isAllRequiredFilled()) {
      ref.read(dataFeedbackKomisiFilledProvider.notifier).state = true;
    } else {
      ref.read(dataFeedbackKomisiFilledProvider.notifier).state = false;
    }
  }

  @override
  void dispose() {
    _topikController.dispose();
    _feedbackController.dispose();
    _saranController.dispose();
    // Jangan close repository di sini karena mungkin masih digunakan oleh halaman lain
    // _repository.close();
    super.dispose();
  }

  bool _isAllRequiredFilled() {
    return _topikController.text.isNotEmpty &&
        _feedbackController.text.isNotEmpty &&
        _ratingKinerja != null;
  }

  Future<void> _saveData(
    BuildContext context,
    WidgetRef ref,
    dynamic theme,
  ) async {
    if (_formKey.currentState!.validate()) {
      List<String> errors = [];

      if (_topikController.text.isEmpty) {
        errors.add('Topik harus diisi');
      }
      if (_feedbackController.text.isEmpty) {
        errors.add('Feedback harus diisi');
      }
      if (_ratingKinerja == null || _ratingKinerja!.isEmpty) {
        errors.add('Rating Kinerja harus dipilih');
      }

      if (errors.isNotEmpty) {
        _showErrorDialog(context, theme, errors.join('\n'));
        return;
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('current_user_id') ?? 'current_user';

        print('DEBUG: 💾 Saving feedback data:');
        print('  - Topik: "${_topikController.text}"');
        print('  - Feedback: "${_feedbackController.text}"');
        print('  - Rating Kinerja: "$_ratingKinerja"');
        print('  - Saran: "${_saranController.text}"');

        if (_existingFeedback != null) {
          // Update existing feedback
          print('DEBUG: 📝 Updating existing feedback with ID: ${_existingFeedback!.id}');
          
          final updatedFeedback = await _repository.updateFeedbackKomisiData(
            id: _existingFeedback!.id!,
            topik: _topikController.text,
            feedback: _feedbackController.text,
            ratingKinerja: _ratingKinerja!,
            saranPerbaikan: _saranController.text.trim().isEmpty ? null : _saranController.text,
          );
          
          print('DEBUG: ✅ Update completed, verifying rating: "${updatedFeedback.ratingKinerja}"');
        } else {
          // Add new feedback
          print('DEBUG: ➕ Adding new feedback');
          
          final newFeedback = await _repository.addFeedbackKomisi(
            topik: _topikController.text,
            feedback: _feedbackController.text,
            ratingKinerja: _ratingKinerja!,
            saranPerbaikan: _saranController.text.trim().isEmpty ? null : _saranController.text,
            userId: userId,
          );
          
          setState(() {
            _existingFeedback = newFeedback;
          });
          
          print('DEBUG: ✅ New feedback saved with ID: ${newFeedback.id}, rating: "${newFeedback.ratingKinerja}"');
        }

        // Save to SharedPreferences as backup
        await prefs.setString('feedback_topik', _topikController.text);
        await prefs.setString('feedback_content', _feedbackController.text);
        await prefs.setString('feedback_rating', _ratingKinerja!);
        await prefs.setString('feedback_saran', _saranController.text);

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Simpan Data Feedback Komisi',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(_existingFeedback?.id == null 
                ? 'Data feedback komisi berhasil ditambahkan ke database.'
                : 'Data feedback komisi berhasil diperbarui di database.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );

        await Future.delayed(Duration.zero, () {
          ref.read(dataFeedbackKomisiFilledProvider.notifier).state = true;
        });

        setState(() {
          _isEditing = false;
        });

        // Reload data to verify save
        await _loadSavedData();

        if (context.mounted) {
          context.go(
            '/dataKomisi',
            extra: {'justSaved': true, 'sourcePage': '/data-feedback-komisi'},
          );
        }
      } catch (e) {
        print('ERROR: Failed to save feedback: $e');
        _showErrorDialog(context, theme, 'Gagal menyimpan data: $e');
      }
    }
  }

  void _showErrorDialog(BuildContext context, dynamic theme, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Error',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _testDatabaseDirectly() async {
    try {
      print('DEBUG: 🔍 ========== TESTING DATABASE DIRECTLY ==========');
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id') ?? 'current_user';
      
      // Get all feedback from database
      final allFeedbacks = await _repository.getAllFeedbackKomisi();
      print('DEBUG: 📋 All feedback in database: ${allFeedbacks.length}');
      
      for (final feedback in allFeedbacks) {
        print('DEBUG: Feedback ID ${feedback.id}:');
        print('  - Topik: "${feedback.topik}"');
        print('  - Feedback: "${feedback.feedback}"');
        print('  - Rating Kinerja: "${feedback.ratingKinerja}"');
        print('  - Saran: "${feedback.saranPerbaikan ?? 'Kosong'}"');
        print('  - User ID: "${feedback.userId}"');
        print('  - Created: ${feedback.createdAt}');
        print('  - Updated: ${feedback.updatedAt}');
        print('  ----');
      }
      
      // Get user specific feedback
      final userFeedbacks = await _repository.getFeedbackKomisiByUserId(userId);
      print('DEBUG: � User $userId feedback count: ${userFeedbacks.length}');
      
      if (userFeedbacks.isNotEmpty) {
        final recent = userFeedbacks.first;
        print('DEBUG: 📊 Most recent user feedback:');
        print('  - Rating from DB: "${recent.ratingKinerja}"');
        print('  - Rating in UI: "$_ratingKinerja"');
        print('  - Are they equal? ${recent.ratingKinerja == _ratingKinerja}');
      }
      
      print('DEBUG: ============================');
      
    } catch (e) {
      print('DEBUG: ❌ Error testing database directly: $e');
    }
  }

  Future<void> _showDebugInfo() async {
    try {
      print('DEBUG: ========== FEEDBACK KOMISI DEBUG INFO ==========');
      
      // Test database directly first
      await _testDatabaseDirectly();
      
      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id') ?? 'current_user';
      print('DEBUG: User ID: $userId');
      print('DEBUG: SharedPreferences data:');
      print('  - topik: ${prefs.getString('feedback_topik')}');
      print('  - feedback: ${prefs.getString('feedback_content')}');
      print('  - rating: ${prefs.getString('feedback_rating')}');
      print('  - saran: ${prefs.getString('feedback_saran')}');
      
      // Check database
      final allFeedbacks = await _repository.getAllFeedbackKomisi();
      print('DEBUG: Total feedback in database: ${allFeedbacks.length}');
      
      final userFeedbacks = await _repository.getFeedbackKomisiByUserId(userId);
      print('DEBUG: User feedback count: ${userFeedbacks.length}');
      
      for (final feedback in userFeedbacks) {
        print('DEBUG: Feedback - ID: ${feedback.id}, Topik: "${feedback.topik}", Rating: "${feedback.ratingKinerja}"');
      }
      
      // Current state
      print('DEBUG: Current UI state:');
      print('  - Existing feedback ID: ${_existingFeedback?.id}');
      print('  - Is editing: $_isEditing');
      print('  - Is loading: $_isLoadingData');
      print('  - Topik: "${_topikController.text}"');
      print('  - Rating: "$_ratingKinerja"');
      
      print('DEBUG: =========================================');
      
      final theme = ref.read(themeProvider);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Debug Information',
            style: theme.typographyRegular.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('User ID: $userId'),
                const SizedBox(height: 8),
                Text('Database feedbacks: ${allFeedbacks.length}'),
                const SizedBox(height: 8),
                Text('User feedbacks: ${userFeedbacks.length}'),
                const SizedBox(height: 8),
                Text('Current feedback ID: ${_existingFeedback?.id ?? 'None'}'),
                const SizedBox(height: 8),
                Text('Current rating: $_ratingKinerja'),
                const SizedBox(height: 8),
                const Text('Check console for detailed logs'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('DEBUG: Error showing debug info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Data Feedback Komisi',
        onBackPressed: () => context.go('/dataKomisi'),
        backTooltip: 'Kembali',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 16.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loading indicator
              if (_isLoadingData)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[100]!, Colors.blue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Memuat Data Feedback',
                              style: theme.typographyRegular.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sedang mengambil data dari database...',
                              style: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Data persistence indicator
              if (_existingFeedback != null && !_isLoadingData)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[100]!, Colors.green[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data Tersimpan di Database',
                              style: theme.typographyRegular.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${_existingFeedback!.id} • Terakhir diubah: ${_existingFeedback!.formattedUpdatedAt}',
                              style: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              AppFormCard(
                title: 'Feedback Komisi',
                titleIcon: Icons.feedback,
                showSaveButton: false,
                fields: [
                  FormFieldConfig(
                    label: 'Topik',
                    icon: Icons.topic,
                    type:
                        _isEditing
                            ? FormFieldType.textRequired
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _topikController,
                    hintText: 'Masukkan topik feedback',
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Feedback',
                    icon: Icons.comment,
                    type:
                        _isEditing
                            ? FormFieldType.multiline
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    controller: _feedbackController,
                    hintText: 'Masukkan feedback detail',
                    maxLines: 4,
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Rating Kinerja',
                    icon: Icons.star_rate,
                    type:
                        _isEditing
                            ? FormFieldType.dropdown
                            : FormFieldType.disabled,
                    isRequired: true,
                    enabled: _isEditing,
                    value: _ratingKinerja,
                    options: const [
                      'Sangat Baik (5)',
                      'Baik (4)',
                      'Cukup (3)',
                      'Kurang (2)',
                      'Sangat Kurang (1)',
                    ],
                    hintText: 'Pilih rating kinerja',
                    onChanged: (value) {
                      print('DEBUG: 🎯 Rating dropdown changed to: "$value"');
                      setState(() {
                        _ratingKinerja = value;
                      });
                      print('DEBUG: ✅ Rating state updated to: "$_ratingKinerja"');
                    },
                    validator: (value) {
                      if (_isEditing && (value == null || value.isEmpty)) {
                        return 'Field ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  FormFieldConfig(
                    label: 'Saran Perbaikan',
                    icon: Icons.lightbulb_outline,
                    type:
                        _isEditing
                            ? FormFieldType.multiline
                            : FormFieldType.disabled,
                    isRequired: false,
                    enabled: _isEditing,
                    controller: _saranController,
                    hintText: 'Masukkan saran perbaikan (opsional)',
                    maxLines: 3,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tombol EDIT dan SIMPAN
              Column(
                children: [
                  if (!_isEditing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primarySwatch,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'EDIT',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_isEditing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _saveData(context, ref, theme),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primarySwatch,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'SIMPAN',
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
