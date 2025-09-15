import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/common/widgets/notifikasi.dart';

mixin SectionPageMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _hasUnsavedChanges = false;
  
  // Subclasses harus implement method ini untuk cek apakah ada perubahan
  bool hasDataChanged();
  
  // Method untuk set hasUnsavedChanges dari subclass
  void setHasUnsavedChanges(bool value) {
    setState(() {
      _hasUnsavedChanges = value;
    });
  }
  
  // Method untuk handle back button dengan warning
  Future<bool> handleBackButton() async {
    if (_hasUnsavedChanges || hasDataChanged()) {
      final shouldLeave = await NotificationUtils.showConfirmationDialog(
        context,
        title: 'Perubahan Belum Disimpan',
        message: 'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?',
        confirmButtonText: 'Keluar Tanpa Menyimpan',
        cancelButtonText: 'Batal',
        icon: Icons.warning_amber_rounded,
        isDangerous: true,
      );
      if (shouldLeave == true) {
        context.pop(false); // Return false untuk indicate tidak disimpan
        return true;
      }
      return false;
    } else {
      context.pop(false); // Return false untuk indicate tidak disimpan
      return true;
    }
  }
  
  // Method untuk handle save dengan proper return value
  void handleSaveSuccess() {
    setState(() {
      _hasUnsavedChanges = false;
    });
    context.pop('saved'); // Return 'saved' untuk indicate data tersimpan
  }
  
  // Getter untuk access hasUnsavedChanges
  bool get hasUnsavedChanges => _hasUnsavedChanges;
}
