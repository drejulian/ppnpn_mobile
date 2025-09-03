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
    final Color primaryColor = cs.primary;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, -8),
            ),
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.05),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern drag handle with gradient
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.6),
                      primaryColor.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // Enhanced header with modern styling
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Modern icon container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withValues(alpha: 0.15),
                          primaryColor.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.typographyRegular.headingSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${subMenuItems.length} opsi tersedia',
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Modern close button
                  Container(
                    decoration: BoxDecoration(
                      color: outlineVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      tooltip: 'Tutup',
                      icon: Icon(
                        Icons.close_rounded,
                        color: onSurface.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Modern divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    outlineVariant.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: subMenuItems.length,
                itemBuilder: (context, index) {
                  final item = subMenuItems[index];
                  final bool enabled = item.enabled;
                  final Color baseText = onSurface.withValues(
                    alpha: enabled ? 0.9 : 0.4,
                  );
                  final Color titleColor =
                      item.isDestructive ? cs.error : baseText;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color:
                          enabled
                              ? surfaceColor
                              : surfaceColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: outlineVariant.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow:
                          enabled
                              ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap:
                            !enabled
                                ? null
                                : () {
                                  Navigator.of(context).maybePop();
                                  item.onTap?.call();
                                },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              // Modern icon container
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      enabled
                                          ? item.color.withValues(alpha: 0.1)
                                          : outlineVariant.withValues(
                                            alpha: 0.2,
                                          ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        enabled
                                            ? item.color.withValues(alpha: 0.2)
                                            : outlineVariant.withValues(
                                              alpha: 0.3,
                                            ),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  item.icon,
                                  color:
                                      enabled
                                          ? item.color
                                          : onSurface.withValues(alpha: 0.4),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: theme.typographyRegular.bodyMedium
                                          .copyWith(
                                            color: titleColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                    ),
                                    if (item.subtitle != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.subtitle!,
                                        style: theme.typographyRegular.bodySmall
                                            .copyWith(
                                              color: onSurface.withValues(
                                                alpha: enabled ? 0.6 : 0.35,
                                              ),
                                              fontSize: 13,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Modern trailing icon
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color:
                                      enabled
                                          ? primaryColor.withValues(alpha: 0.08)
                                          : outlineVariant.withValues(
                                            alpha: 0.2,
                                          ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:
                                    item.trailing ??
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color:
                                          enabled
                                              ? primaryColor.withValues(
                                                alpha: 0.7,
                                              )
                                              : onSurface.withValues(
                                                alpha: 0.3,
                                              ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
