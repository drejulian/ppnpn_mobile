import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';

/// Field types for form card components
enum FormFieldType {
  text,
  textRequired,
  dropdown,
  autocomplete,
  disabled,
  datePicker,
  multiline,
}

/// Configuration class for form field
class FormFieldConfig {
  final String label;
  final IconData icon;
  final FormFieldType type;
  final bool isRequired;
  final String? hintText;
  final String? helperText;
  final TextInputType? keyboardType;
  final bool isLast;
  final TextEditingController? controller;
  final String? value;
  final List<String>? options;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final VoidCallback? onTap;
  final int maxLines;
  final IconData? suffixIcon;

  const FormFieldConfig({
    required this.label,
    required this.icon,
    this.type = FormFieldType.text,
    this.isRequired = false,
    this.hintText,
    this.helperText,
    this.keyboardType,
    this.isLast = false,
    this.controller,
    this.value,
    this.options,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.onTap,
    this.maxLines = 1,
    this.suffixIcon,
  });
}

/// Reusable Form Card Component with consistent styling and multiple field types
class AppFormCard extends ConsumerWidget {
  final String title;
  final IconData titleIcon;
  final List<FormFieldConfig> fields;
  final VoidCallback? onSave;
  final String saveButtonText;
  final bool showSaveButton;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const AppFormCard({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.fields,
    this.onSave,
    this.saveButtonText = 'SIMPAN',
    this.showSaveButton = true,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Container(
      margin: margin ?? const EdgeInsets.all(0),
      padding: padding ?? const EdgeInsets.all(20),
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
          // Section Title
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
                child: Icon(titleIcon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Form Fields
          ...fields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;
            final isLast = index == fields.length - 1;

            return _buildFormField(field, theme, isLast || field.isLast);
          }).toList(),

          // Save Button
          if (showSaveButton && onSave != null) ...[
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  saveButtonText,
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
    );
  }

  Widget _buildFormField(FormFieldConfig field, dynamic theme, bool isLast) {
    switch (field.type) {
      case FormFieldType.disabled:
        return _buildTextField(field, theme, isLast, enabled: false);
      case FormFieldType.text:
        return _buildTextField(field, theme, isLast);
      case FormFieldType.textRequired:
        return _buildTextFieldWithRequired(field, theme, isLast);
      case FormFieldType.dropdown:
        return _buildDropdownField(field, theme, isLast);
      case FormFieldType.autocomplete:
        return _buildAutocompleteField(field, theme, isLast);
      case FormFieldType.datePicker:
        return _buildDatePickerField(field, theme, isLast);
      case FormFieldType.multiline:
        return _buildMultilineTextField(field, theme, isLast);
    }
  }

  Widget _buildTextField(
    FormFieldConfig field,
    dynamic theme,
    bool isLast, {
    bool enabled = true,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    enabled
                        ? theme.primarySwatch.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                field.icon,
                color: enabled ? theme.primarySwatch : Colors.grey,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.label,
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: field.controller,
                    enabled: enabled && field.enabled,
                    keyboardType: field.keyboardType,
                    decoration: InputDecoration(
                      hintText: field.hintText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
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
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: !enabled || !field.enabled,
                      fillColor:
                          !enabled || !field.enabled ? Colors.grey[100] : null,
                      hintStyle: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color:
                          enabled && field.enabled
                              ? Colors.grey[800]
                              : Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                    validator: field.validator,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildTextFieldWithRequired(
    FormFieldConfig field,
    dynamic theme,
    bool isLast,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(field.icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          field.label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (field.isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall
                                .copyWith(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: field.controller,
                    keyboardType: field.keyboardType,
                    decoration: InputDecoration(
                      hintText: field.hintText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                      hintStyle: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    validator:
                        field.validator ??
                        (field.isRequired
                            ? (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field ini wajib diisi';
                              }
                              return null;
                            }
                            : null),
                  ),
                  if (field.helperText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        field.helperText!,
                        style: theme.typographyRegular.bodyExtraSmall.copyWith(
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildDropdownField(
    FormFieldConfig field,
    dynamic theme,
    bool isLast,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(field.icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          field.label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (field.isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall
                                .copyWith(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: field.value,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
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
                    ),
                    items:
                        field.options?.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.grey[800],
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: field.onChanged,
                    validator:
                        field.validator ??
                        (field.isRequired
                            ? (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field ini wajib diisi';
                              }
                              return null;
                            }
                            : null),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildAutocompleteField(
    FormFieldConfig field,
    dynamic theme,
    bool isLast,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(field.icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          field.label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (field.isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall
                                .copyWith(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Autocomplete<String>(
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return field.options?.where((option) {
                            return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          }) ??
                          const Iterable<String>.empty();
                    },
                    onSelected: (selection) {
                      field.controller?.text = selection;
                    },
                    fieldViewBuilder: (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      textEditingController.text = field.controller?.text ?? '';
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        onFieldSubmitted: (value) {
                          onFieldSubmitted();
                          field.controller?.text = value;
                        },
                        onChanged: (value) {
                          field.controller?.text = value;
                        },
                        decoration: InputDecoration(
                          hintText: field.hintText,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red[400]!),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red[400]!),
                          ),
                          hintStyle: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[400],
                          ),
                        ),
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                        validator:
                            field.validator ??
                            (field.isRequired
                                ? (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Field ini wajib diisi';
                                  }
                                  return null;
                                }
                                : null),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildDatePickerField(
    FormFieldConfig field,
    dynamic theme,
    bool isLast,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(field.icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          field.label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (field.isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall
                                .copyWith(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: field.onTap,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: field.controller,
                        decoration: InputDecoration(
                          hintText: field.hintText,
                          suffixIcon:
                              field.suffixIcon != null
                                  ? Icon(
                                    field.suffixIcon,
                                    color: Colors.grey[400],
                                  )
                                  : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red[400]!),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red[400]!),
                          ),
                          hintStyle: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[400],
                          ),
                        ),
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                        validator:
                            field.validator ??
                            (field.isRequired
                                ? (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Field ini wajib diisi';
                                  }
                                  return null;
                                }
                                : null),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildMultilineTextField(
    FormFieldConfig field,
    dynamic theme,
    bool isLast,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(field.icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          field.label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (field.isRequired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Wajib diisi',
                            style: theme.typographyRegular.bodyExtraSmall
                                .copyWith(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: field.controller,
                    maxLines: field.maxLines,
                    decoration: InputDecoration(
                      hintText: field.hintText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red[400]!),
                      ),
                      hintStyle: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    validator:
                        field.validator ??
                        (field.isRequired
                            ? (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field ini wajib diisi';
                              }
                              return null;
                            }
                            : null),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

/// Global reusable card with consistent radius, padding, shadow,
/// optional left accent stripe, and optional background gradient.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.radius = 12,
    this.color,
    this.clipBehavior = Clip.antiAlias,
    this.leftAccentColor,
    this.leftAccentWidth = 4.0,
    this.gradient,
    this.elevation = 2.0,
  });

  final Widget? child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double radius;
  final Color? color;
  final Clip clipBehavior;
  final Color? leftAccentColor;
  final double leftAccentWidth;
  final Gradient? gradient;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Colors.white;
    final r = Radius.circular(radius);

    final boxShadow =
        elevation <= 0
            ? const <BoxShadow>[]
            : <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ];

    Widget content = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.all(r),
        boxShadow: boxShadow,
      ),
      clipBehavior: clipBehavior,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.all(r),
          child: Stack(
            children: [
              if (leftAccentColor != null)
                Positioned.fill(
                  left: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: leftAccentWidth,
                      decoration: BoxDecoration(
                        color: leftAccentColor,
                        borderRadius: BorderRadius.only(
                          topLeft: r,
                          bottomLeft: r,
                        ),
                      ),
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.all(r),
                ),
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      child: content,
    );
  }
}

/// A reusable search/filter bar for app pages.
/// Wraps a styled Card + TextField with clear button and theme-aware borders.
class AppFilterBar extends ConsumerWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry cardMargin;
  final Widget? prefixIcon;
  // New: optional header + filter section like "Daftar Cuti"
  final String? headerTitle; // e.g., 'Pencarian & Filter'
  final bool?
  showHeader; // default auto when headerTitle/filterSection provided
  final bool hasActiveFilters; // controls Reset visibility
  final VoidCallback? onReset; // Reset button callback
  final Widget? filterSection; // extra filter widgets (chips, dropdowns, etc.)

  const AppFilterBar({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.padding = const EdgeInsets.all(16),
    this.cardMargin = EdgeInsets.zero,
    this.prefixIcon,
    this.headerTitle,
    this.showHeader,
    this.hasActiveFilters = false,
    this.onReset,
    this.filterSection,
  });

  bool get _computedShowHeader =>
      (showHeader ?? false) ||
      headerTitle != null ||
      filterSection != null ||
      onReset != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final color = theme.primarySwatch;

    return Card(
      margin: cardMargin,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_computedShowHeader) ...[
              Row(
                children: [
                  Icon(Icons.filter_list_rounded, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    headerTitle ?? 'Pencarian & Filter',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  if (hasActiveFilters && onReset != null)
                    TextButton.icon(
                      onPressed: onReset,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Reset'),
                      style: TextButton.styleFrom(
                        foregroundColor: color,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final hasText = value.text.isNotEmpty;
                return TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: labelText,
                    hintText: hintText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: color, width: 1.5),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon:
                        prefixIcon ?? const Icon(Icons.search, size: 20),
                    suffixIcon:
                        hasText
                            ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                controller.clear();
                                onClear?.call();
                                onChanged?.call('');
                              },
                            )
                            : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: onChanged,
                );
              },
            ),
            if (filterSection != null) ...[
              const SizedBox(height: 12),
              filterSection!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A standardized list-item card layout built on top of [AppCard],
/// matching the look-and-feel used by "Daftar Cuti":
/// - Top row: leading avatar/icon, title + subtitle, trailing status chip
/// - Middle: wrap of small "pill" chips
/// - Bottom-right: row of action buttons (icon/text)
class AppListCard extends StatelessWidget {
  const AppListCard({
    super.key,
    this.onTap,
    this.leftAccentColor,
    this.gradient,
    this.padding,
    // Header
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    // Content chips
    this.chips = const <Widget>[],
    // Bottom actions
    this.actions = const <Widget>[],
  });

  final VoidCallback? onTap;
  final Color? leftAccentColor;
  final Gradient? gradient;
  final EdgeInsets? padding;

  // Header
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  // Content
  final List<Widget> chips;

  // Bottom-right action widgets (e.g. IconButtons or OutlinedButtons)
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      leftAccentColor: leftAccentColor,
      gradient: gradient,
      padding: padding ?? const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),

          if (chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
          ],

          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  actions[i],
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Small rounded "pill" chip used under the header inside [AppListCard].
class AppPillChip extends StatelessWidget {
  const AppPillChip({
    super.key,
    required this.icon,
    required this.label,
    this.maxLabelWidth,
    this.color,
  });

  final IconData icon;
  final String label;
  final double? maxLabelWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? theme.colorScheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status chip to be placed on the top-right of [AppListCard].
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A reusable card component for displaying transaction-like items
/// (izin, reimburse, cuti, etc.) with consistent design
class TransactionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime date;
  final String status;
  final Color statusColor;
  final IconData iconData;
  final List<TransactionChip> chips;
  final List<TransactionAction> actions;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.iconData,
    required this.chips,
    required this.actions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      onTap: onTap,
      leftAccentColor: statusColor,
      gradient: LinearGradient(
        colors: [Colors.white, Colors.grey[50]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle.isNotEmpty 
                        ? subtitle 
                        : DateFormat('dd MMMM yyyy', 'id_ID').format(date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(status, statusColor, theme),
            ],
          ),

          // Chips Section
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips.map((chip) => _buildPillChip(
                icon: chip.icon,
                label: chip.label,
                theme: theme,
              )).toList(),
            ),
          ],

          // Actions Section
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ...actions.map((action) => IconButton(
                  tooltip: action.tooltip,
                  icon: Icon(
                    action.icon,
                    color: action.isEnabled ? action.color : Colors.grey,
                  ),
                  onPressed: action.isEnabled ? action.onPressed : null,
                )).toList(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color, ThemeData theme) {
    IconData icon;
    switch (text) {
      case 'Disetujui':
        icon = Icons.check_circle;
        break;
      case 'Ditolak':
        icon = Icons.cancel;
        break;
      case 'Menunggu':
      case 'Menunggu Persetujuan':
        icon = Icons.hourglass_bottom;
        break;
      default:
        icon = Icons.info;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.primaryColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for chip items
class TransactionChip {
  final IconData icon;
  final String label;

  const TransactionChip({
    required this.icon,
    required this.label,
  });
}

/// Data class for action buttons
class TransactionAction {
  final String type; // 'edit', 'delete', 'download', etc.
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isEnabled;

  const TransactionAction({
    required this.type,
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onPressed,
    this.isEnabled = true,
  });

  /// Factory constructor for edit action
  factory TransactionAction.edit({
    required VoidCallback? onPressed,
    bool isEnabled = true,
  }) {
    return TransactionAction(
      type: 'edit',
      icon: Icons.edit,
      color: isEnabled ? Colors.blue : Colors.grey,
      tooltip: isEnabled ? 'Edit' : 'Tidak dapat diedit',
      onPressed: onPressed,
      isEnabled: isEnabled,
    );
  }

  /// Factory constructor for delete action
  factory TransactionAction.delete({
    required VoidCallback? onPressed,
  }) {
    return TransactionAction(
      type: 'delete',
      icon: Icons.delete,
      color: Colors.redAccent,
      tooltip: 'Hapus',
      onPressed: onPressed,
    );
  }

  /// Factory constructor for download action
  factory TransactionAction.download({
    required VoidCallback? onPressed,
  }) {
    return TransactionAction(
      type: 'download',
      icon: Icons.download,
      color: Colors.green,
      tooltip: 'Download Bukti',
      onPressed: onPressed,
    );
  }
}

/// Helper class for creating common transaction cards
class TransactionCardHelper {
  /// Create card for Izin (Leave)
  static TransactionCard izin({
    required Map<String, dynamic> data,
    VoidCallback? onEdit,
    VoidCallback? onDownload,
    VoidCallback? onDetail,
    bool showEdit = true,
    bool showDownload = true,
    bool showDetail = true,
  }) {
    // Parse data from map
    final type = data['type']?.toString() ?? 'Tidak diketahui';
    final status = data['status']?.toString() ?? 'Menunggu Persetujuan';
    final duration = data['duration']?.toString() ?? '';
    final reason = data['reason']?.toString() ?? '';
    final fileName = data['fileName']?.toString();
    
    // Parse date
    DateTime date = DateTime.now();
    if (data['date'] != null) {
      if (data['date'] is DateTime) {
        date = data['date'] as DateTime;
      } else {
        try {
          date = DateTime.parse(data['date'].toString());
        } catch (e) {
          date = DateTime.now();
        }
      }
    }
    
    // Get status color
    Color statusColor = Colors.orange;
    switch (status) {
      case 'Disetujui':
        statusColor = Colors.green;
        break;
      case 'Ditolak':
        statusColor = Colors.red;
        break;
      case 'Menunggu Persetujuan':
      default:
        statusColor = Colors.orange;
    }

    return TransactionCard(
      title: type,
      subtitle: '',
      date: date,
      status: status,
      statusColor: statusColor,
      iconData: Icons.event_busy,
      chips: [
        TransactionChip(
          icon: Icons.calendar_today,
          label: DateFormat('dd MMM yyyy', 'id_ID').format(date),
        ),
        TransactionChip(
          icon: Icons.timelapse,
          label: duration,
        ),
        TransactionChip(
          icon: Icons.notes,
          label: reason,
        ),
        if (fileName != null)
          TransactionChip(
            icon: Icons.attach_file,
            label: fileName,
          ),
      ],
      actions: [
        if (showEdit && onEdit != null)
          TransactionAction.edit(onPressed: onEdit),
        if (showDownload && onDownload != null)
          TransactionAction.download(onPressed: onDownload),
        if (showDetail && onDetail != null)
          TransactionAction(
            type: 'detail',
            icon: Icons.visibility,
            color: Colors.grey[600]!,
            tooltip: 'Detail',
            onPressed: onDetail,
          ),
      ],
    );
  }

  /// Create card for Reimburse
  static TransactionCard reimburse({
    required Map<String, dynamic> data,
    VoidCallback? onEdit,
    VoidCallback? onDownload,
    VoidCallback? onDetail,
    bool showEdit = true,
    bool showDownload = true,
    bool showDetail = true,
  }) {
    // Parse data from map
    final category = data['category']?.toString() ?? 'Tidak diketahui';
    final status = data['status']?.toString() ?? 'Menunggu Persetujuan';
    final description = data['description']?.toString();
    final fileName = data['fileName']?.toString();
    
    // Parse date
    DateTime date = DateTime.now();
    if (data['date'] != null) {
      if (data['date'] is DateTime) {
        date = data['date'] as DateTime;
      } else {
        try {
          date = DateTime.parse(data['date'].toString());
        } catch (e) {
          date = DateTime.now();
        }
      }
    }
    
    // Format amount
    String formattedAmount = '';
    if (data['amount'] != null) {
      final amount = data['amount'];
      if (amount is num) {
        formattedAmount = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(amount);
      } else {
        formattedAmount = amount.toString();
      }
    }
    
    // Get status color
    Color statusColor = Colors.orange;
    switch (status) {
      case 'Disetujui':
        statusColor = Colors.green;
        break;
      case 'Ditolak':
        statusColor = Colors.red;
        break;
      case 'Menunggu Persetujuan':
      default:
        statusColor = Colors.orange;
    }

    return TransactionCard(
      title: category,
      subtitle: '',
      date: date,
      status: status,
      statusColor: statusColor,
      iconData: Icons.receipt_long,
      chips: [
        TransactionChip(
          icon: Icons.monetization_on,
          label: formattedAmount,
        ),
        TransactionChip(
          icon: Icons.calendar_today,
          label: DateFormat('dd MMM yyyy', 'id_ID').format(date),
        ),
        if (description != null && description.isNotEmpty)
          TransactionChip(
            icon: Icons.description,
            label: description,
          ),
        if (fileName != null)
          TransactionChip(
            icon: Icons.attach_file,
            label: fileName,
          ),
      ],
      actions: [
        if (showEdit && onEdit != null)
          TransactionAction.edit(onPressed: onEdit),
        if (showDownload && onDownload != null)
          TransactionAction.download(onPressed: onDownload),
        if (showDetail && onDetail != null)
          TransactionAction(
            type: 'detail',
            icon: Icons.visibility,
            color: Colors.grey[600]!,
            tooltip: 'Detail',
            onPressed: onDetail,
          ),
      ],
    );
  }

  /// Create card for Cuti (Leave)
  static TransactionCard cuti({
    required Map<String, dynamic> data,
    VoidCallback? onEdit,
    VoidCallback? onDownload,
    VoidCallback? onDetail,
    bool showEdit = true,
    bool showDownload = true,
    bool showDetail = true,
  }) {
    // Parse data from map
    final type = data['type']?.toString() ?? 'Tidak diketahui';
    final status = data['status']?.toString() ?? 'Menunggu Persetujuan';
    final duration = data['duration']?.toString() ?? '';
    final reason = data['reason']?.toString() ?? '';
    final fileName = data['fileName']?.toString();
    
    // Parse date
    DateTime date = DateTime.now();
    if (data['date'] != null) {
      if (data['date'] is DateTime) {
        date = data['date'] as DateTime;
      } else {
        try {
          date = DateTime.parse(data['date'].toString());
        } catch (e) {
          date = DateTime.now();
        }
      }
    }
    
    // Get status color
    Color statusColor = Colors.orange;
    switch (status) {
      case 'Disetujui':
        statusColor = Colors.green;
        break;
      case 'Ditolak':
        statusColor = Colors.red;
        break;
      case 'Menunggu Persetujuan':
      default:
        statusColor = Colors.orange;
    }

    return TransactionCard(
      title: type,
      subtitle: '',
      date: date,
      status: status,
      statusColor: statusColor,
      iconData: Icons.event_busy,
      chips: [
        TransactionChip(
          icon: Icons.calendar_today,
          label: DateFormat('dd MMM yyyy', 'id_ID').format(date),
        ),
        TransactionChip(
          icon: Icons.timelapse,
          label: duration,
        ),
        TransactionChip(
          icon: Icons.notes,
          label: reason,
        ),
        if (fileName != null)
          TransactionChip(
            icon: Icons.attach_file,
            label: fileName,
          ),
      ],
      actions: [
        if (showEdit && onEdit != null)
          TransactionAction.edit(onPressed: onEdit),
        if (showDownload && onDownload != null)
          TransactionAction.download(onPressed: onDownload),
        if (showDetail && onDetail != null)
          TransactionAction(
            type: 'detail',
            icon: Icons.visibility,
            color: Colors.grey[600]!,
            tooltip: 'Detail',
            onPressed: onDetail,
          ),
      ],
    );
  }

  /// Create card for Lembur (Overtime)
  static TransactionCard lembur({
    required Map<String, dynamic> data,
    VoidCallback? onEdit,
    VoidCallback? onDownload,
    VoidCallback? onDetail,
    bool showEdit = true,
    bool showDownload = true,
    bool showDetail = true,
  }) {
    // Parse data from map
    final type = data['type']?.toString() ?? 'Tidak diketahui';
    final status = data['status']?.toString() ?? 'Menunggu Persetujuan';
    final duration = data['duration']?.toString() ?? '';
    final reason = data['reason']?.toString() ?? '';
    final fileName = data['fileName']?.toString();
    
    // Parse date
    DateTime date = DateTime.now();
    if (data['date'] != null) {
      if (data['date'] is DateTime) {
        date = data['date'] as DateTime;
      } else {
        try {
          date = DateTime.parse(data['date'].toString());
        } catch (e) {
          date = DateTime.now();
        }
      }
    }
    
    // Get status color
    Color statusColor = Colors.orange;
    switch (status) {
      case 'Disetujui':
        statusColor = Colors.green;
        break;
      case 'Ditolak':
        statusColor = Colors.red;
        break;
      case 'Menunggu Persetujuan':
      default:
        statusColor = Colors.orange;
    }

    return TransactionCard(
      title: type,
      subtitle: '',
      date: date,
      status: status,
      statusColor: statusColor,
      iconData: Icons.schedule,
      chips: [
        TransactionChip(
          icon: Icons.calendar_today,
          label: DateFormat('dd MMM yyyy', 'id_ID').format(date),
        ),
        TransactionChip(
          icon: Icons.timelapse,
          label: duration,
        ),
        TransactionChip(
          icon: Icons.notes,
          label: reason,
        ),
        if (fileName != null)
          TransactionChip(
            icon: Icons.attach_file,
            label: fileName,
          ),
      ],
      actions: [
        if (showEdit && onEdit != null)
          TransactionAction.edit(onPressed: onEdit),
        if (showDownload && onDownload != null)
          TransactionAction.download(onPressed: onDownload),
        if (showDetail && onDetail != null)
          TransactionAction(
            type: 'detail',
            icon: Icons.visibility,
            color: Colors.grey[600]!,
            tooltip: 'Detail',
            onPressed: onDetail,
          ),
      ],
    );
  }
}
