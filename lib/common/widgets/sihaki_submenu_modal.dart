import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/app/theme.dart';

/// Convenience helper to present the SIHAKI Submenu as a Bottom Sheet with
/// consistent defaults. Usage remains optional; existing usages that directly
/// pass [SihakiSubMenuModal] to `showModalBottomSheet` still work.
Future<T?> showSihakiSubMenuModal<T>(
  BuildContext context, {
  required String title,
  required List<SubMenuItemData> items,
  bool isDismissible = true,
  bool useRootNavigator = true,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SihakiSubMenuModal(title: title, subMenuItems: items),
  );
}

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

    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color surfaceColor = cs.surface;
    final Color onSurface = cs.onSurface;
    final Color outlineVariant = cs.outlineVariant;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.typographyRegular.headingSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  icon: Icon(
                    Icons.close,
                    color: onSurface.withValues(alpha: 0.7),
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Divider(height: 20, thickness: 1, color: outlineVariant),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subMenuItems.length,
                separatorBuilder:
                    (_, __) => Divider(
                      height: 1,
                      color: outlineVariant.withValues(alpha: 0.6),
                    ),
                itemBuilder: (context, index) {
                  final item = subMenuItems[index];
                  final bool enabled = item.enabled;
                  final Color baseText = onSurface.withValues(
                    alpha: enabled ? 0.9 : 0.4,
                  );
                  final Color titleColor =
                      item.isDestructive ? cs.error : baseText;
                  return ListTile(
                    enabled: enabled,
                    leading: Icon(item.icon, color: item.color),
                    title: Text(
                      item.title,
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle:
                        item.subtitle == null
                            ? null
                            : Text(
                              item.subtitle!,
                              style: theme.typographyRegular.bodySmall.copyWith(
                                color: onSurface.withValues(
                                  alpha: enabled ? 0.7 : 0.35,
                                ),
                              ),
                            ),
                    trailing:
                        item.trailing ??
                        const Icon(Icons.chevron_right, size: 18),
                    onTap:
                        !enabled
                            ? null
                            : () {
                              Navigator.of(context).maybePop();
                              item.onTap?.call();
                            },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubMenuItemData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trailing;
  final bool enabled;
  final bool isDestructive;

  const SubMenuItemData(
    this.title,
    this.icon,
    this.color, {
    this.onTap,
    this.subtitle,
    this.trailing,
    this.enabled = true,
    this.isDestructive = false,
  });
}
