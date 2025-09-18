import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_storage_service.dart';

// Auth State Model
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? token;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.token,
    this.userId,
    this.userName,
    this.userEmail,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? token,
    String? userId,
    String? userName,
    String? userEmail,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      errorMessage: errorMessage,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _initializeAuth();
  }

  // Initialize authentication state from secure storage
  Future<void> _initializeAuth() async {
    print('🔄 AuthProvider: Starting auth initialization...');
    state = state.copyWith(isLoading: true);
    
    try {
      // Add small delay to ensure storage is ready
      await Future.delayed(const Duration(milliseconds: 100));
      
      final isLoggedIn = await AuthStorageService.isLoggedIn();
      print('🔍 AuthProvider: isLoggedIn = $isLoggedIn');
      
      if (isLoggedIn) {
        final token = await AuthStorageService.getAuthToken();
        final userData = await AuthStorageService.getUserData();
        
        print('🔑 AuthProvider: Token found = ${token != null ? "YES" : "NO"}');
        print('👤 AuthProvider: User data = ${userData['userName']}');
        
        // Validate token exists and is not empty
        if (token != null && token.isNotEmpty) {
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            token: token,
            userId: userData['userId'],
            userName: userData['userName'],
            userEmail: userData['userEmail'],
          );
          print('✅ AuthProvider: User authenticated successfully');
        } else {
          print('⚠️ AuthProvider: Token is null or empty, clearing auth');
          await AuthStorageService.clearAuthData();
          state = state.copyWith(isLoading: false, isAuthenticated: false);
        }
      } else {
        state = state.copyWith(isLoading: false, isAuthenticated: false);
        print('❌ AuthProvider: No valid login found');
      }
    } catch (e) {
      print('🚨 AuthProvider: Error during initialization: $e');
      
      // Try to clear corrupted data
      try {
        await AuthStorageService.clearAuthData();
      } catch (clearError) {
        print('🚨 AuthProvider: Error clearing auth data: $clearError');
      }
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Error initializing auth: $e',
      );
    }
  }

  // Sign In
  Future<bool> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication logic
      if (email.isNotEmpty && password.isNotEmpty) {
        // Simulasi response dari API
        final token = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
        final userId = 'user_123';
        final userName = email.split('@')[0]; // Extract name from email
        
        print('💾 AuthProvider: Saving login data...');
        print('🔑 Token: $token');
        print('👤 User: $userName ($email)');
        print('💭 Remember me: $rememberMe');
        
        // Save to secure storage
        await AuthStorageService.saveAuthToken(token);
        await AuthStorageService.saveUserData(
          userId: userId,
          userName: userName,
          userEmail: email,
        );
        await AuthStorageService.saveRememberMe(rememberMe);

        // Save login credentials if remember me is checked
        if (rememberMe) {
          await AuthStorageService.saveLoginCredentials(
            email: email,
            password: password,
          );
          print('💾 AuthProvider: Login credentials saved for remember me');
        } else {
          // Clear any previously saved credentials
          await AuthStorageService.clearSavedCredentials();
          print('🗑️ AuthProvider: Previous login credentials cleared');
        }

        print('✅ AuthProvider: Login data saved successfully');

        // Update state
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          token: token,
          userId: userId,
          userName: userName,
          userEmail: email,
        );

        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Email dan password tidak boleh kosong',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login gagal: $e',
      );
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await AuthStorageService.clearAuthData();
      state = const AuthState(isLoading: false, isAuthenticated: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Logout gagal: $e',
      );
    }
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
