import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Keys untuk menyimpan data
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _rememberMeKey = 'remember_me';
  static const String _lastLoginKey = 'last_login';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';

  // Simpan token autentikasi
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Ambil token autentikasi
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Simpan data user
  static Future<void> saveUserData({
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    await Future.wait([
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _userNameKey, value: userName),
      _storage.write(key: _userEmailKey, value: userEmail),
      _storage.write(key: _lastLoginKey, value: DateTime.now().toIso8601String()),
    ]);
  }

  // Ambil data user
  static Future<Map<String, String?>> getUserData() async {
    final results = await Future.wait([
      _storage.read(key: _userIdKey),
      _storage.read(key: _userNameKey),
      _storage.read(key: _userEmailKey),
      _storage.read(key: _lastLoginKey),
    ]);

    return {
      'userId': results[0],
      'userName': results[1],
      'userEmail': results[2],
      'lastLogin': results[3],
    };
  }

  // Simpan status "Remember Me"
  static Future<void> saveRememberMe(bool remember) async {
    await _storage.write(key: _rememberMeKey, value: remember.toString());
  }

  // Cek status "Remember Me"
  static Future<bool> getRememberMe() async {
    final value = await _storage.read(key: _rememberMeKey);
    return value == 'true';
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Simpan login credentials ketika "Remember Me" dicentang
  static Future<void> saveLoginCredentials({
    required String email,
    required String password,
  }) async {
    await Future.wait([
      _storage.write(key: _savedEmailKey, value: email),
      _storage.write(key: _savedPasswordKey, value: password),
    ]);
  }

  // Ambil login credentials yang tersimpan
  static Future<Map<String, String?>> getSavedCredentials() async {
    final results = await Future.wait([
      _storage.read(key: _savedEmailKey),
      _storage.read(key: _savedPasswordKey),
    ]);

    return {
      'email': results[0],
      'password': results[1],
    };
  }

  // Hapus login credentials yang tersimpan
  static Future<void> clearSavedCredentials() async {
    await Future.wait([
      _storage.delete(key: _savedEmailKey),
      _storage.delete(key: _savedPasswordKey),
    ]);
  }

  // Hapus semua data autentikasi (logout) - tapi keep saved credentials jika remember me true
  static Future<void> clearAuthData() async {
    final rememberMe = await getRememberMe();
    
    final futures = <Future>[
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userNameKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _lastLoginKey),
    ];
    
    // Hanya hapus remember me jika false
    if (!rememberMe) {
      futures.addAll([
        _storage.delete(key: _rememberMeKey),
        clearSavedCredentials(),
      ]);
    }
    
    await Future.wait(futures);
  }

  // Hapus semua data storage
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Debug method untuk testing storage
  static Future<void> debugStorage() async {
    try {
      print('🔧 DEBUG: Testing Flutter Secure Storage...');

      // Test write
      await _storage.write(key: 'test_key', value: 'test_value');
      print('✅ DEBUG: Write test passed');

      // Test read
      final value = await _storage.read(key: 'test_key');
      print('✅ DEBUG: Read test passed - value: $value');

      // Test delete
      await _storage.delete(key: 'test_key');
      print('✅ DEBUG: Delete test passed');

      // Test read after delete
      final deletedValue = await _storage.read(key: 'test_key');
      print('✅ DEBUG: Read after delete - value: ${deletedValue ?? "null"}');

      // Test remember me functionality
      print('🔧 DEBUG: Testing Remember Me functionality...');
      
      // Check current saved credentials
      final savedCredentials = await getSavedCredentials();
      final rememberMe = await getRememberMe();
      
      print('💾 DEBUG: Current saved email: ${savedCredentials['email'] ?? "none"}');
      print('💾 DEBUG: Current saved password: ${savedCredentials['password'] != null ? "***saved***" : "none"}');
      print('💾 DEBUG: Remember me status: $rememberMe');

      print('🎉 DEBUG: All Flutter Secure Storage tests passed!');
    } catch (e) {
      print('❌ DEBUG: Flutter Secure Storage test failed: $e');
    }
  }
}
