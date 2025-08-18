// lib/widgets/sihaki_submenu_modal.dart (You can create this file)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ppnpm_dpr/app/theme.dart'; // Assuming you have this theme file

class SihakiSubMenuModal extends ConsumerWidget {
  final String title;
  final List<SubMenuItemData> subMenuItems;

  const SihakiSubMenuModal({
    super.key,
    required this.title,
    required this.subMenuItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.typographyRegular.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subMenuItems.length,
            itemBuilder: (context, index) {
              final item = subMenuItems[index];
              return ListTile(
                leading: Icon(item.icon, color: item.color),
                title: Text(
                  item.title,
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop(); // Close the modal
                  item.onTap?.call(); // Execute the specific action
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// Define a new data class for sub-menu items if needed, or reuse MenuItemData
class SubMenuItemData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  SubMenuItemData(this.title, this.icon, this.color, {this.onTap});
}