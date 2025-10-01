import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/user_repository.dart';
import '../data/models/user_model.dart';

// Provider untuk UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Provider untuk current logged in user
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  return CurrentUserNotifier(ref.read(userRepositoryProvider));
});

// Provider untuk daftar semua users
final usersProvider = StateNotifierProvider<UsersNotifier, AsyncValue<List<UserModel>>>((ref) {
  return UsersNotifier(ref.read(userRepositoryProvider));
});

// Provider untuk filter users berdasarkan role
final usersByRoleProvider = StateNotifierProvider.family<UsersByRoleNotifier, AsyncValue<List<UserModel>>, UserRole>((ref, role) {
  return UsersByRoleNotifier(ref.read(userRepositoryProvider), role);
});

// Provider untuk search users
final searchUsersProvider = StateNotifierProvider.family<SearchUsersNotifier, AsyncValue<List<UserModel>>, String>((ref, query) {
  return SearchUsersNotifier(ref.read(userRepositoryProvider), query);
});

// Provider untuk user statistics
final userStatisticsProvider = StateNotifierProvider<UserStatisticsNotifier, AsyncValue<Map<UserRole, int>>>((ref) {
  return UserStatisticsNotifier(ref.read(userRepositoryProvider));
});

/// StateNotifier untuk current user yang sedang login
class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final UserRepository _repository;

  CurrentUserNotifier(this._repository) : super(null);

  /// Login user
  Future<bool> login(String usernameOrEmail, String password) async {
    try {
      final user = await _repository.loginUser(usernameOrEmail, password);
      if (user != null) {
        state = user;
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }

  /// Logout user
  void logout() {
    state = null;
  }

  /// Update current user profile
  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      final user = await _repository.updateUser(updatedUser);
      state = user;
    } catch (e) {
      throw Exception('Update profile gagal: $e');
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      if (state?.id == null) {
        throw Exception('User tidak sedang login');
      }
      await _repository.updatePassword(state!.id!, newPassword);
    } catch (e) {
      throw Exception('Update password gagal: $e');
    }
  }

  /// Set user dari data yang sudah ada (untuk restore session)
  void setUser(UserModel user) {
    state = user;
  }

  /// Get current user ID
  int? get currentUserId => state?.id;

  /// Check if user is logged in
  bool get isLoggedIn => state != null;

  /// Check if current user is admin
  bool get isAdmin => state?.role == UserRole.admin;

  /// Check if current user is pegawai
  bool get isPegawai => state?.role == UserRole.pegawai;

  /// Check if current user is magang
  bool get isMagang => state?.role == UserRole.magang;
}

/// StateNotifier untuk daftar semua users
class UsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserRepository _repository;

  UsersNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  /// Load semua users
  Future<void> loadUsers() async {
    try {
      state = const AsyncValue.loading();
      final users = await _repository.getAllUsers();
      state = AsyncValue.data(users);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh data users
  Future<void> refresh() async {
    await loadUsers();
  }

  /// Tambah user baru
  Future<UserModel> addUser(UserModel user) async {
    try {
      final newUser = await _repository.insertUser(user);
      
      // Update state dengan menambahkan user baru
      state.whenData((users) {
        final updatedUsers = [...users, newUser];
        updatedUsers.sort((a, b) => a.nama.compareTo(b.nama));
        state = AsyncValue.data(updatedUsers);
      });
      
      return newUser;
    } catch (e) {
      throw Exception('Gagal menambah user: $e');
    }
  }

  /// Update user
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final updatedUser = await _repository.updateUser(user);
      
      // Update state dengan mengupdate user yang ada
      state.whenData((users) {
        final updatedUsers = users.map((u) => u.id == updatedUser.id ? updatedUser : u).toList();
        updatedUsers.sort((a, b) => a.nama.compareTo(b.nama));
        state = AsyncValue.data(updatedUsers);
      });
      
      return updatedUser;
    } catch (e) {
      throw Exception('Gagal mengupdate user: $e');
    }
  }

  /// Hapus user
  Future<void> deleteUser(int userId) async {
    try {
      await _repository.deleteUser(userId);
      
      // Update state dengan menghapus user
      state.whenData((users) {
        final updatedUsers = users.where((u) => u.id != userId).toList();
        state = AsyncValue.data(updatedUsers);
      });
    } catch (e) {
      throw Exception('Gagal menghapus user: $e');
    }
  }

  /// Get user by ID dari state
  UserModel? getUserById(int id) {
    return state.whenOrNull(
      data: (users) => users.firstWhere((user) => user.id == id, orElse: () => throw Exception('User tidak ditemukan')),
    );
  }
}

/// StateNotifier untuk users berdasarkan role
class UsersByRoleNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserRepository _repository;
  final UserRole _role;

  UsersByRoleNotifier(this._repository, this._role) : super(const AsyncValue.loading()) {
    loadUsersByRole();
  }

  /// Load users berdasarkan role
  Future<void> loadUsersByRole() async {
    try {
      state = const AsyncValue.loading();
      final users = await _repository.getUsersByRole(_role);
      state = AsyncValue.data(users);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadUsersByRole();
  }
}

/// StateNotifier untuk search users
class SearchUsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserRepository _repository;
  final String _query;

  SearchUsersNotifier(this._repository, this._query) : super(const AsyncValue.loading()) {
    if (_query.isNotEmpty) {
      searchUsers();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  /// Search users berdasarkan nama
  Future<void> searchUsers() async {
    try {
      state = const AsyncValue.loading();
      final users = await _repository.searchUsersByName(_query);
      state = AsyncValue.data(users);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// StateNotifier untuk user statistics
class UserStatisticsNotifier extends StateNotifier<AsyncValue<Map<UserRole, int>>> {
  final UserRepository _repository;

  UserStatisticsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadStatistics();
  }

  /// Load statistics
  Future<void> loadStatistics() async {
    try {
      state = const AsyncValue.loading();
      final stats = await _repository.getUserCountByRole();
      state = AsyncValue.data(stats);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh statistics
  Future<void> refresh() async {
    await loadStatistics();
  }

  /// Get total users
  int get totalUsers {
    return state.whenOrNull(
      data: (stats) => stats.values.fold<int>(0, (sum, count) => sum + count),
    ) ?? 0;
  }

  /// Get count for specific role
  int getCountForRole(UserRole role) {
    return state.whenOrNull(
      data: (stats) => stats[role] ?? 0,
    ) ?? 0;
  }
}

/// Utility providers
final totalUsersProvider = Provider<int>((ref) {
  return ref.watch(userStatisticsProvider.notifier).totalUsers;
});

final adminCountProvider = Provider<int>((ref) {
  return ref.watch(userStatisticsProvider.notifier).getCountForRole(UserRole.admin);
});

final pegawaiCountProvider = Provider<int>((ref) {
  return ref.watch(userStatisticsProvider.notifier).getCountForRole(UserRole.pegawai);
});

final magangCountProvider = Provider<int>((ref) {
  return ref.watch(userStatisticsProvider.notifier).getCountForRole(UserRole.magang);
});

/// Provider untuk validasi availability
final usernameAvailabilityProvider = FutureProvider.family<bool, String>((ref, username) async {
  final repository = ref.read(userRepositoryProvider);
  return await repository.isUsernameAvailable(username);
});

final emailAvailabilityProvider = FutureProvider.family<bool, String>((ref, email) async {
  final repository = ref.read(userRepositoryProvider);
  return await repository.isEmailAvailable(email);
});