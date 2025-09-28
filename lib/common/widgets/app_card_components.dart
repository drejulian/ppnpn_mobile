import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';

// Field types for form card components
enum FormFieldType {
  text,
  textRequired,
  dropdown,
  autocomplete,
  disabled,
  datePicker,
  multiline,
}

// Configuration class for form field
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
  final List<TextInputFormatter>? inputFormatters;

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
    this.inputFormatters,
  });
}

class AppFormCard extends ConsumerWidget {
  final String title;
  final IconData titleIcon;
  final List<FormFieldConfig> fields;
  final VoidCallback? onSave;
  final String saveButtonText;
  final bool showSaveButton;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final String? infoText;

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
    this.infoText,
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
                    inputFormatters: field.inputFormatters,
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
                    inputFormatters: field.inputFormatters,
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
                        inputFormatters: field.inputFormatters,
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
                        inputFormatters: field.inputFormatters,
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
                    inputFormatters: field.inputFormatters,
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
class AppFilterBar extends ConsumerWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry cardMargin;
  final Widget? prefixIcon;

  final String? headerTitle;
  final bool? showHeader;
  final bool hasActiveFilters;
  final VoidCallback? onReset;
  final Widget? filterSection;

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

class CardMenuComponent extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;
  final int animationDelay;
  final bool isTablet;
  final dynamic theme;

  const CardMenuComponent({
    super.key,
    required this.title,
    required this.icon,
    required this.gradientColors,
    this.onTap,
    this.animationDelay = 0,
    this.isTablet = false,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + animationDelay),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap ?? () {},
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.25),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 1,
                        spreadRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon Container with enhanced glassmorphism effect
                          Container(
                            padding: EdgeInsets.all(isTablet ? 18 : 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 1,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              icon,
                              size: isTablet ? 32 : 28,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: isTablet ? 14 : 12),

                          // Title with enhanced typography
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: theme.typographyRegular.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: isTablet ? 13.0 : 11.0,
                              height: 1.2,
                              letterSpacing: 0.2,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HeaderCardComponent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData? icon;
  final Widget? leadingWidget; 
  final bool isTablet;
  final bool isLargeTablet;
  final dynamic theme;
  final Widget? additionalInfo;
  final String? nik;

  const HeaderCardComponent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    this.icon,
    this.leadingWidget,
    this.isTablet = false,
    this.isLargeTablet = false,
    required this.theme,
    this.additionalInfo,
    this.nik,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primarySwatch,
            theme.secondarySwatch,
            theme.primarySwatch.shade300,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primarySwatch.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (leadingWidget != null) leadingWidget!,
                  if (leadingWidget == null && icon != null)
                  Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: isTablet ? 44 : 36,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: isTablet ? 24 : 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.typographyRegular.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: isTablet ? 40.0 : 32.0,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.typographyRegular.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 18.0 : 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 28 : 24),
               if (additionalInfo != null) additionalInfo!,
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        size: isTablet ? 24 : 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: Text(
                        description,
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: isTablet ? 16.0 : 14.0,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderCardProfileComponent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData? icon;
  final Widget? leadingWidget;
  final bool isTablet;
  final bool isLargeTablet;
  final dynamic theme;
  final Widget? additionalInfo;
  final String? nik;

  const HeaderCardProfileComponent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    this.icon,
    this.leadingWidget,
    this.isTablet = false,
    this.isLargeTablet = false,
    required this.theme,
    this.additionalInfo,
    this.nik,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primarySwatch,
            theme.secondarySwatch,
            theme.primarySwatch.shade300,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primarySwatch.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto profil di tengah atas
              Center(
                child: leadingWidget ?? (icon != null
                    ? Container(
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: isTablet ? 44 : 36,
                          color: Colors.white,
                        ),
                      )
                    : null),
              ),
              const SizedBox(height: 16),
              // Nama di tengah
              Center(
                child: Text(
                  title,
                  style: theme.typographyRegular.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: isTablet ? 40.0 : 32.0,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              // Bidang keahlian di tengah
              Center(
                child: Text(
                  subtitle,
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 18.0 : 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              // NIK di tengah
              if (nik != null && nik!.isNotEmpty)
                Center(
                  child: Text(
                    'NIK: $nik',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: isTablet ? 14.0 : 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: isTablet ? 28 : 24),
              if (additionalInfo != null) additionalInfo!,
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        size: isTablet ? 24 : 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: Text(
                        description,
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: isTablet ? 16.0 : 14.0,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeaderComponent extends StatelessWidget {
  final String title;
  final String counter;
  final IconData icon;
  final bool isTablet;
  final dynamic theme;

  const SectionHeaderComponent({
    super.key,
    required this.title,
    required this.counter,
    required this.icon,
    this.isTablet = false,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 4, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primarySwatch.withOpacity(0.1),
                  theme.secondarySwatch.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.primarySwatch.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: isTablet ? 24 : 20,
              color: theme.primarySwatch,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Text(
            title,
            style: theme.typographyRegular.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              fontSize: isTablet ? 24.0 : 20.0,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: theme.primarySwatch.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.primarySwatch.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              counter,
              style: theme.typographyRegular.bodySmall.copyWith(
                color: theme.primarySwatch,
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 13.0 : 11.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SIHAKICard extends ConsumerWidget {
  final String title;
  final String periode;
  final String penghasilan;
  final String tahun;
  final String bulan;
  final VoidCallback? onTap;
  final VoidCallback? onPrint;
  final VoidCallback? onWhatsApp;
  final bool isTablet;

  const SIHAKICard({
    super.key,
    required this.title,
    required this.periode,
    required this.penghasilan,
    required this.tahun,
    required this.bulan,
    this.onTap,
    this.onPrint,
    this.onWhatsApp,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isTablet ? 12 : 10),
                      decoration: BoxDecoration(
                        color: theme.primarySwatch.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: isTablet ? 24 : 20,
                        color: theme.primarySwatch,
                      ),
                    ),
                    SizedBox(width: isTablet ? 14 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.typographyRegular.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              fontSize: isTablet ? 17.0 : 15.0,
                            ),
                          ),
                          SizedBox(height: isTablet ? 4 : 3),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 10 : 8,
                              vertical: isTablet ? 4 : 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.blue[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: isTablet ? 14 : 12,
                                  color: Colors.blue[700],
                                ),
                                SizedBox(width: isTablet ? 4 : 3),
                                Text(
                                  periode,
                                  style: theme.typographyRegular.bodySmall
                                      .copyWith(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                        fontSize: isTablet ? 12.0 : 11.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 10 : 8,
                        vertical: isTablet ? 4 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green[200]!, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: isTablet ? 14 : 12,
                            color: Colors.green[700],
                          ),
                          SizedBox(width: isTablet ? 4 : 3),
                          Text(
                            'Tersedia',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                              fontSize: isTablet ? 11.0 : 10.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 14 : 12),

                // Detail penghasilan
                Container(
                  padding: EdgeInsets.all(isTablet ? 14 : 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            size: isTablet ? 16 : 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: isTablet ? 6 : 5),
                          Text(
                            'Jenis Penghasilan',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontSize: isTablet ? 12.0 : 11.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 8 : 6),
                      Text(
                        penghasilan,
                        style: theme.typographyRegular.bodyMedium.copyWith(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 14.0 : 13.0,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 14 : 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        theme: theme,
                        icon: Icons.print_rounded,
                        label: 'Cetak',
                        color: Colors.blue,
                        onPressed: onPrint,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: isTablet ? 10 : 8),
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        theme: theme,
                        icon: Icons.phone_android_rounded,
                        label: 'WhatsApp',
                        color: Colors.green,
                        onPressed: onWhatsApp,
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required dynamic theme,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required bool isTablet,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 14 : 12,
            vertical: isTablet ? 10 : 8,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isTablet ? 16 : 14, color: color),
              SizedBox(width: isTablet ? 6 : 5),
              Text(
                label,
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 12.0 : 11.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SIHAKIPageHeader extends ConsumerWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget>? quickActions;
  final Widget? statsSection;
  final bool isTablet;

  const SIHAKIPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.quickActions,
    this.statsSection,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: theme.primarySwatch,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primarySwatch.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isTablet ? 28 : 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.typographyRegular.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 24.0 : 20.0,
                      ),
                    ),
                    SizedBox(height: isTablet ? 4 : 3),
                    Text(
                      subtitle,
                      style: theme.typographyRegular.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: isTablet ? 14.0 : 12.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (quickActions != null) ...[
            SizedBox(height: isTablet ? 16 : 14),
            Wrap(
              spacing: isTablet ? 10 : 8,
              runSpacing: isTablet ? 8 : 6,
              children: quickActions!,
            ),
          ],

          if (statsSection != null) ...[
            SizedBox(height: isTablet ? 16 : 14),
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: statsSection!,
            ),
          ],
        ],
      ),
    );
  }
}

class SIHAKIActionButton extends ConsumerWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isTablet;

  const SIHAKIActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 14 : 12,
            vertical: isTablet ? 8 : 7,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: isTablet ? 16 : 14, color: Colors.white),
              SizedBox(width: isTablet ? 6 : 5),
              Text(
                label,
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 12.0 : 11.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SIHAKIDataCard extends ConsumerWidget {
  final String title;
  final String subtitle;
  final List<SIHAKIDataField> fields;
  final List<SIHAKICardAction> actions;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  final Color? statusColor;
  final String? statusText;
  final bool isTablet;

  const SIHAKIDataCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.actions,
    this.onTap,
    this.leadingIcon,
    this.statusColor,
    this.statusText,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    if (leadingIcon != null) ...[
                      Container(
                        padding: EdgeInsets.all(isTablet ? 10 : 8),
                        decoration: BoxDecoration(
                          color: theme.primarySwatch.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          leadingIcon,
                          size: isTablet ? 20 : 18,
                          color: theme.primarySwatch,
                        ),
                      ),
                      SizedBox(width: isTablet ? 12 : 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.typographyRegular.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              fontSize: isTablet ? 16.0 : 15.0,
                            ),
                          ),
                          if (subtitle.isNotEmpty) ...[
                            SizedBox(height: isTablet ? 4 : 3),
                            Text(
                              subtitle,
                              style: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.grey[600],
                                fontSize: isTablet ? 13.0 : 12.0,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (statusText != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 10,
                          vertical: isTablet ? 6 : 5,
                        ),
                        decoration: BoxDecoration(
                          color: (statusColor ?? theme.primarySwatch)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (statusColor ?? theme.primarySwatch)
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          statusText!,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: statusColor ?? theme.primarySwatch,
                            fontWeight: FontWeight.w500,
                            fontSize: isTablet ? 12.0 : 11.0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (fields.isNotEmpty) ...[
                  SizedBox(height: isTablet ? 14 : 12),
                  Container(
                    padding: EdgeInsets.all(isTablet ? 14 : 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      children:
                          fields
                              .map(
                                (field) =>
                                    _buildDataField(field, theme, isTablet),
                              )
                              .toList(),
                    ),
                  ),
                ],

                if (actions.isNotEmpty) ...[
                  SizedBox(height: isTablet ? 14 : 12),
                  Wrap(
                    spacing: isTablet ? 10 : 8,
                    runSpacing: isTablet ? 8 : 6,
                    children:
                        actions
                            .map(
                              (action) =>
                                  _buildActionButton(action, theme, isTablet),
                            )
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataField(SIHAKIDataField field, dynamic theme, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: field.isLast ? 0 : (isTablet ? 10 : 8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 100 : 80,
            child: Text(
              field.label,
              style: theme.typographyRegular.bodySmall.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: isTablet ? 12.0 : 11.0,
              ),
            ),
          ),
          Text(
            ': ',
            style: theme.typographyRegular.bodySmall.copyWith(
              color: Colors.grey[600],
              fontSize: isTablet ? 12.0 : 11.0,
            ),
          ),
          Expanded(
            child: Text(
              field.value,
              style: theme.typographyRegular.bodySmall.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
                fontSize: isTablet ? 12.0 : 11.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    SIHAKICardAction action,
    dynamic theme,
    bool isTablet,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 14 : 12,
            vertical: isTablet ? 8 : 7,
          ),
          decoration: BoxDecoration(
            color: action.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: action.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: isTablet ? 14 : 12, color: action.color),
              SizedBox(width: isTablet ? 6 : 4),
              Text(
                action.label,
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: action.color,
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 11.0 : 10.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Model untuk field data di SIHAKI cards
class SIHAKIDataField {
  final String label;
  final String value;
  final bool isLast;

  const SIHAKIDataField({
    required this.label,
    required this.value,
    this.isLast = false,
  });
}

/// Model untuk action button di SIHAKI cards
class SIHAKICardAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const SIHAKICardAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });
}

/// SIHAKI List Card Component - Untuk tampilan list dengan multiple data
class SIHAKIListCard extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String? description;
  final IconData? leadingIcon;
  final String? statusText;
  final Color? statusColor;
  final List<Widget> chips;
  final List<SIHAKICardAction> actions;
  final VoidCallback? onTap;
  final bool isTablet;

  const SIHAKIListCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    this.leadingIcon,
    this.statusText,
    this.statusColor,
    this.chips = const [],
    this.actions = const [],
    this.onTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    if (leadingIcon != null) ...[
                      Container(
                        padding: EdgeInsets.all(isTablet ? 12 : 10),
                        decoration: BoxDecoration(
                          color: theme.primarySwatch.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          leadingIcon,
                          size: isTablet ? 24 : 20,
                          color: theme.primarySwatch,
                        ),
                      ),
                      SizedBox(width: isTablet ? 14 : 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.typographyRegular.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              fontSize: isTablet ? 16.0 : 15.0,
                            ),
                          ),
                          SizedBox(height: isTablet ? 4 : 3),
                          Text(
                            subtitle,
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontSize: isTablet ? 13.0 : 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (statusText != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 10,
                          vertical: isTablet ? 6 : 5,
                        ),
                        decoration: BoxDecoration(
                          color: (statusColor ?? theme.primarySwatch)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (statusColor ?? theme.primarySwatch)
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          statusText!,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: statusColor ?? theme.primarySwatch,
                            fontWeight: FontWeight.w500,
                            fontSize: isTablet ? 12.0 : 11.0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (description != null) ...[
                  SizedBox(height: isTablet ? 12 : 10),
                  Text(
                    description!,
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[700],
                      fontSize: isTablet ? 13.0 : 12.0,
                      height: 1.4,
                    ),
                  ),
                ],

                if (chips.isNotEmpty) ...[
                  SizedBox(height: isTablet ? 12 : 10),
                  Wrap(
                    spacing: isTablet ? 8 : 6,
                    runSpacing: isTablet ? 6 : 4,
                    children: chips,
                  ),
                ],

                if (actions.isNotEmpty) ...[
                  SizedBox(height: isTablet ? 14 : 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:
                        actions
                            .map(
                              (action) => Padding(
                                padding: EdgeInsets.only(
                                  left: isTablet ? 8 : 6,
                                ),
                                child: _buildActionButton(
                                  action,
                                  theme,
                                  isTablet,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    SIHAKICardAction action,
    dynamic theme,
    bool isTablet,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 10,
            vertical: isTablet ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: action.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: action.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: isTablet ? 16 : 14, color: action.color),
              SizedBox(width: isTablet ? 6 : 4),
              Text(
                action.label,
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: action.color,
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 12.0 : 11.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SIHAKIPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Color primaryColor;
  final dynamic theme;
  final bool isTablet;

  const SIHAKIPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
    required this.primaryColor,
    required this.theme,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: isTablet ? 20 : 16),
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 14 : 12,
        horizontal: isTablet ? 18 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPrevious,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color:
                      currentPage > 1
                          ? primaryColor.withValues(alpha: 0.1)
                          : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        currentPage > 1
                            ? primaryColor.withValues(alpha: 0.2)
                            : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: currentPage > 1 ? primaryColor : Colors.grey[400],
                  size: isTablet ? 20 : 18,
                ),
              ),
            ),
          ),

          SizedBox(width: isTablet ? 16 : 14),

          // Page indicator
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 14,
              vertical: isTablet ? 10 : 8,
            ),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.apps_rounded,
                  color: Colors.white,
                  size: isTablet ? 16 : 14,
                ),
                SizedBox(width: isTablet ? 6 : 5),
                Text(
                  '$currentPage / $totalPages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 14.0 : 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: isTablet ? 16 : 14),

          // Next button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onNext,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color:
                      currentPage < totalPages
                          ? primaryColor.withValues(alpha: 0.1)
                          : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        currentPage < totalPages
                            ? primaryColor.withValues(alpha: 0.2)
                            : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color:
                      currentPage < totalPages
                          ? primaryColor
                          : Colors.grey[400],
                  size: isTablet ? 20 : 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// SIHAKI Dialog Components
class SIHAKIDialogData {
  final String title;
  final List<SIHAKIDialogField> fields;
  final List<SIHAKIDialogAction> actions;
  final Widget? additionalContent;

  const SIHAKIDialogData({
    required this.title,
    required this.fields,
    required this.actions,
    this.additionalContent,
  });
}

class SIHAKIDialogField {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Color? labelColor;
  final Color? valueColor;

  const SIHAKIDialogField({
    required this.label,
    required this.value,
    this.valueStyle,
    this.labelColor,
    this.valueColor,
  });
}

class SIHAKIDialogAction {
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isDestructive;

  const SIHAKIDialogAction({
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isDestructive = false,
  });
}

class SIHAKIDetailDialog extends StatelessWidget {
  final SIHAKIDialogData data;

  const SIHAKIDetailDialog({super.key, required this.data});

  static Future<void> show(BuildContext context, SIHAKIDialogData data) {
    return showDialog(
      context: context,
      builder: (context) => SIHAKIDetailDialog(data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 500 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header dengan close button
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: isTablet ? 24 : 20,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(width: isTablet ? 14 : 12),
                  Expanded(
                    child: Text(
                      data.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                        fontSize: isTablet ? 20.0 : 18.0,
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 10 : 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey[600],
                          size: isTablet ? 20 : 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 20 : 18),

              // Fields Section
              Container(
                padding: EdgeInsets.all(isTablet ? 18 : 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title with icon
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTablet ? 8 : 7),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.assignment_rounded,
                            size: isTablet ? 18 : 16,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: isTablet ? 10 : 8),
                        Text(
                          'Detail Informasi',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                            fontSize: isTablet ? 15.0 : 14.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 14 : 12),

                    // Fields
                    ...data.fields
                        .where(
                          (field) =>
                              field.label.isNotEmpty && field.value.isNotEmpty,
                        )
                        .map((field) {
                          final isLast = data.fields.last == field;
                          return _buildDetailRow(
                            field,
                            theme,
                            isTablet,
                            isLast,
                          );
                        })
                        .toList(),
                  ],
                ),
              ),

              // Additional Content
              if (data.additionalContent != null) ...[
                SizedBox(height: isTablet ? 16 : 14),
                data.additionalContent!,
              ],

              // Actions Section
              if (data.actions.isNotEmpty) ...[
                SizedBox(height: isTablet ? 20 : 18),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? 16 : 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings_rounded,
                            size: isTablet ? 18 : 16,
                            color: primaryColor,
                          ),
                          SizedBox(width: isTablet ? 8 : 6),
                          Text(
                            'Aksi Tersedia',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              fontSize: isTablet ? 15.0 : 14.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 14 : 12),

                      // Action Buttons
                      ...data.actions.map((action) {
                        final isLast = data.actions.last == action;
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: _buildDialogActionButton(
                                context: context,
                                theme: theme,
                                action: action,
                                isTablet: isTablet,
                              ),
                            ),
                            if (!isLast) SizedBox(height: isTablet ? 10 : 8),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    SIHAKIDialogField field,
    ThemeData theme,
    bool isTablet,
    bool isLast,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: field.labelColor ?? Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: isTablet ? 12.0 : 11.0,
          ),
        ),
        SizedBox(height: isTablet ? 6 : 5),
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Text(
            field.value,
            style:
                field.valueStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: field.valueColor ?? Colors.grey[800],
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 14.0 : 13.0,
                ),
          ),
        ),
        if (!isLast) SizedBox(height: isTablet ? 12 : 10),
      ],
    );
  }

  Widget _buildDialogActionButton({
    required BuildContext context,
    required ThemeData theme,
    required SIHAKIDialogAction action,
    required bool isTablet,
  }) {
    final color =
        action.isDestructive
            ? Colors.red[600]!
            : action.backgroundColor ?? theme.primaryColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 16 : 14),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    action.icon ?? Icons.touch_app,
                    size: isTablet ? 20 : 18,
                    color: color,
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 10),
                Expanded(
                  child: Text(
                    action.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      fontSize: isTablet ? 15.0 : 14.0,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: isTablet ? 16 : 14,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SIHAKIConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final bool isDestructive;

  const SIHAKIConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText = 'Batal',
    this.onCancel,
    this.icon,
    this.iconColor,
    this.isDestructive = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    String cancelText = 'Batal',
    VoidCallback? onCancel,
    IconData? icon,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => SIHAKIConfirmationDialog(
            title: title,
            message: message,
            confirmText: confirmText,
            cancelText: cancelText,
            onConfirm: onConfirm,
            onCancel: onCancel,
            icon: icon,
            iconColor: iconColor,
            isDestructive: isDestructive,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(maxWidth: isTablet ? 400 : double.infinity),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 14),
                decoration: BoxDecoration(
                  color:
                      isDestructive
                          ? Colors.red[50]
                          : primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon ??
                      (isDestructive
                          ? Icons.warning_rounded
                          : Icons.help_outline_rounded),
                  size: isTablet ? 32 : 28,
                  color:
                      iconColor ??
                      (isDestructive ? Colors.red[600] : primaryColor),
                ),
              ),

              SizedBox(height: isTablet ? 20 : 18),

              // Title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                  fontSize: isTablet ? 20.0 : 18.0,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isTablet ? 12 : 10),

              // Message
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontSize: isTablet ? 15.0 : 14.0,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isTablet ? 24 : 20),

              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop(false);
                            onCancel?.call();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 14 : 12,
                            ),
                            child: Text(
                              cancelText,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                fontSize: isTablet ? 15.0 : 14.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: isTablet ? 12 : 10),

                  // Confirm Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors:
                              isDestructive
                                  ? [Colors.red[600]!, Colors.red[700]!]
                                  : [
                                    primaryColor,
                                    primaryColor.withValues(alpha: 0.8),
                                  ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDestructive
                                    ? Colors.red[600]!
                                    : primaryColor)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop(true);
                            onConfirm();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 14 : 12,
                            ),
                            child: Text(
                              confirmText,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: isTablet ? 15.0 : 14.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCompletionNotifierCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;
  final IconData? icon;
  final Color? iconColor;
  final bool isDestructive;

  const ProfileCompletionNotifierCard({
    super.key,
    required this.title,
    required this.message,
    this.onConfirm,
    this.icon,
    this.iconColor,
    this.isDestructive = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onConfirm,
    IconData? icon,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ProfileCompletionNotifierCard(
        title: title,
        message: message,
        onConfirm: onConfirm,
        icon: icon,
        iconColor: iconColor,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(maxWidth: isTablet ? 400 : double.infinity),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 14),
                decoration: BoxDecoration(
                  color: Colors.green[50], // Latar belakang hijau muda
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon ?? Icons.check_circle_rounded,
                  size: isTablet ? 32 : 28,
                  color: Colors.green[600], // Ikon hijau
                ),
              ),

              SizedBox(height: isTablet ? 20 : 18),

              // Title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                  fontSize: isTablet ? 20.0 : 18.0,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isTablet ? 12 : 10),

              // Message
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontSize: isTablet ? 15.0 : 14.0,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isTablet ? 24 : 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onConfirm?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 178, 0, 191), // Warna manual dari MyTheme
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 14 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: isTablet ? 15.0 : 14.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorUploadDialogCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;
  final IconData? icon;
  final Color? iconColor;

  const ErrorUploadDialogCard({
    super.key,
    required this.title,
    required this.message,
    this.onConfirm,
    this.icon,
    this.iconColor,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onConfirm,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ErrorUploadDialogCard(
        title: title,
        message: message,
        onConfirm: onConfirm,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(maxWidth: isTablet ? 400 : double.infinity),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 14),
                decoration: BoxDecoration(
                  color: Colors.red[50], // Latar belakang merah muda untuk error
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon ?? Icons.error_outline_rounded,
                  size: isTablet ? 32 : 28,
                  color: iconColor ?? Colors.red[600], // Ikon merah
                ),
              ),

              SizedBox(height: isTablet ? 20 : 18),

              // Title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                  fontSize: isTablet ? 20.0 : 18.0,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isTablet ? 12 : 10),

              // Message
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontSize: isTablet ? 15.0 : 14.0,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isTablet ? 24 : 20),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onConfirm?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600], // Warna merah untuk error
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 14 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: isTablet ? 15.0 : 14.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}