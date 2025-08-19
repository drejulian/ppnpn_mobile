# AppFormCard Component Documentation

## Overview
`AppFormCard` adalah komponen reusable yang dirancang untuk membuat form dengan styling konsisten di seluruh aplikasi. Component ini mendukung berbagai jenis field input dengan validasi otomatis dan theme yang seragam.

## Features
- ✅ Konsisten styling untuk semua form
- ✅ Support multiple field types (text, dropdown, autocomplete, date picker, multiline)
- ✅ Built-in validation dengan indikator "Wajib diisi"
- ✅ Automatic layout dengan dividers
- ✅ Customizable save button
- ✅ Icon-based field identification
- ✅ Responsive design
- ✅ Theme integration

## Field Types

### 1. FormFieldType.text
Field teks biasa tanpa validasi khusus
```dart
FormFieldConfig(
  label: 'Nama Field',
  icon: Icons.text_fields,
  type: FormFieldType.text,
  controller: textController,
  hintText: 'Masukkan teks',
)
```

### 2. FormFieldType.textRequired
Field teks dengan validasi required dan badge "Wajib diisi"
```dart
FormFieldConfig(
  label: 'Nama',
  icon: Icons.person,
  type: FormFieldType.textRequired,
  controller: namaController,
  isRequired: true,
  hintText: 'Masukkan nama lengkap',
)
```

### 3. FormFieldType.dropdown
Dropdown selection field
```dart
FormFieldConfig(
  label: 'Pendidikan Terakhir',
  icon: Icons.school,
  type: FormFieldType.dropdown,
  value: selectedValue,
  options: ['S1', 'S2', 'S3'],
  isRequired: true,
  onChanged: (value) => setState(() => selectedValue = value!),
)
```

### 4. FormFieldType.autocomplete
Field dengan autocomplete suggestions
```dart
FormFieldConfig(
  label: 'Bidang Keahlian',
  icon: Icons.work,
  type: FormFieldType.autocomplete,
  controller: bidangController,
  options: ['IT', 'Hukum', 'Ekonomi'],
  isRequired: true,
  hintText: 'Ketik untuk mencari',
)
```

### 5. FormFieldType.datePicker
Date picker field dengan calendar icon
```dart
FormFieldConfig(
  label: 'Tanggal Mulai',
  icon: Icons.event,
  type: FormFieldType.datePicker,
  controller: tanggalController,
  isRequired: true,
  hintText: 'dd-mm-yyyy',
  suffixIcon: Icons.calendar_today,
  onTap: () => _pickDate(),
)
```

### 6. FormFieldType.multiline
Text area untuk input panjang
```dart
FormFieldConfig(
  label: 'Alasan',
  icon: Icons.assignment,
  type: FormFieldType.multiline,
  controller: alasanController,
  isRequired: true,
  hintText: 'Tuliskan alasan',
  maxLines: 3,
)
```

### 7. FormFieldType.disabled
Field yang tidak dapat diedit (read-only)
```dart
FormFieldConfig(
  label: 'NIK',
  icon: Icons.credit_card,
  type: FormFieldType.disabled,
  controller: nikController,
  hintText: 'NIK tidak dapat diubah',
  enabled: false,
)
```

## Complete Usage Example

```dart
AppFormCard(
  title: 'Edit Profil',
  titleIcon: Icons.edit,
  fields: [
    FormFieldConfig(
      label: 'NIK',
      icon: Icons.credit_card,
      type: FormFieldType.disabled,
      controller: nikController,
      hintText: 'NIK tidak dapat diubah',
      enabled: false,
    ),
    FormFieldConfig(
      label: 'Nama',
      icon: Icons.person,
      type: FormFieldType.textRequired,
      controller: namaController,
      isRequired: true,
      hintText: 'Masukkan nama lengkap',
    ),
    FormFieldConfig(
      label: 'Pendidikan Terakhir',
      icon: Icons.school,
      type: FormFieldType.dropdown,
      value: selectedPendidikan,
      options: pendidikanOptions,
      isRequired: true,
      onChanged: (value) {
        setState(() {
          selectedPendidikan = value!;
        });
      },
    ),
    FormFieldConfig(
      label: 'TOEFL',
      icon: Icons.language,
      type: FormFieldType.textRequired,
      controller: toeflController,
      isRequired: true,
      hintText: 'Masukkan skor TOEFL',
      keyboardType: TextInputType.number,
      helperText: 'Wajib diisi untuk Tenaga Ahli',
      isLast: true,
    ),
  ],
  onSave: () => _saveProfile(),
  saveButtonText: 'SIMPAN',
)
```

## Properties

### AppFormCard Properties
| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| title | String | ✅ | - | Judul card |
| titleIcon | IconData | ✅ | - | Icon untuk header card |
| fields | List\<FormFieldConfig\> | ✅ | - | List konfigurasi field |
| onSave | VoidCallback? | ❌ | null | Callback tombol save |
| saveButtonText | String | ❌ | 'SIMPAN' | Text tombol save |
| showSaveButton | bool | ❌ | true | Show/hide tombol save |
| padding | EdgeInsets? | ❌ | EdgeInsets.all(20) | Padding dalam card |
| margin | EdgeInsets? | ❌ | EdgeInsets.all(0) | Margin luar card |

### FormFieldConfig Properties
| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| label | String | ✅ | - | Label field |
| icon | IconData | ✅ | - | Icon field |
| type | FormFieldType | ❌ | FormFieldType.text | Jenis field |
| isRequired | bool | ❌ | false | Apakah wajib diisi |
| hintText | String? | ❌ | null | Placeholder text |
| helperText | String? | ❌ | null | Helper text di bawah field |
| keyboardType | TextInputType? | ❌ | null | Jenis keyboard |
| isLast | bool | ❌ | false | Apakah field terakhir (no divider) |
| controller | TextEditingController? | ❌ | null | Controller untuk text field |
| value | String? | ❌ | null | Value untuk dropdown |
| options | List\<String\>? | ❌ | null | Options untuk dropdown/autocomplete |
| onChanged | Function(String?)? | ❌ | null | Callback onChange |
| validator | String? Function(String?)? | ❌ | null | Custom validator |
| enabled | bool | ❌ | true | Enable/disable field |
| onTap | VoidCallback? | ❌ | null | Callback onTap (untuk date picker) |
| maxLines | int | ❌ | 1 | Jumlah baris untuk multiline |
| suffixIcon | IconData? | ❌ | null | Icon suffix (untuk date picker) |

## Implementation Examples

### 1. Edit Profile Page
```dart
// lib/features/dashboard/presentation/pages/DataDiri/edit_profile.dart
AppFormCard(
  title: 'Edit Profil',
  titleIcon: Icons.edit,
  fields: [
    // NIK (disabled)
    FormFieldConfig(
      label: 'NIK',
      icon: Icons.credit_card,
      type: FormFieldType.disabled,
      controller: _nikController,
      hintText: 'NIK tidak dapat diubah',
      enabled: false,
    ),
    // ... other fields
  ],
  onSave: () => _saveProfile(context, ref.watch(themeProvider)),
  saveButtonText: 'SIMPAN',
)
```

### 2. Tambah Cuti Page
```dart
// lib/features/dashboard/presentation/pages/MenuUtama/Cuti/tambah_cuti_page.dart
AppFormCard(
  title: 'Data Cuti',
  titleIcon: Icons.event_available,
  fields: [
    FormFieldConfig(
      label: 'Jenis Cuti',
      icon: Icons.category,
      type: FormFieldType.textRequired,
      controller: _jenisCtrl,
      isRequired: true,
      hintText: 'Cuti Tahunan',
    ),
    FormFieldConfig(
      label: 'Tanggal Mulai',
      icon: Icons.event,
      type: FormFieldType.datePicker,
      controller: _awalCtrl,
      isRequired: true,
      hintText: 'dd-mm-yyyy',
      suffixIcon: Icons.calendar_today,
      onTap: () => _pickDate(_awalCtrl),
    ),
    // ... other fields
  ],
  onSave: () => _submitCuti(),
  saveButtonText: 'KIRIM PENGAJUAN',
)
```

### 3. Tambah Lembur Page
```dart
// lib/features/dashboard/presentation/pages/MenuUtama/Lembur/tambah_lembur_page.dart
AppFormCard(
  title: 'Data Lembur',
  titleIcon: Icons.schedule,
  fields: [
    FormFieldConfig(
      label: 'Tanggal',
      icon: Icons.event,
      type: FormFieldType.datePicker,
      controller: _tanggalCtrl,
      isRequired: true,
      hintText: 'dd-mm-yyyy',
      suffixIcon: Icons.calendar_today,
      onTap: () => _pickDate(_tanggalCtrl),
    ),
    FormFieldConfig(
      label: 'Kegiatan',
      icon: Icons.assignment,
      type: FormFieldType.multiline,
      controller: _kegiatanCtrl,
      isRequired: true,
      hintText: 'Tuliskan kegiatan',
      maxLines: 3,
      isLast: true,
    ),
  ],
  onSave: () => _submitLembur(),
  saveButtonText: 'KIRIM PENGAJUAN',
)
```

## Benefits

### 1. Consistency
- Semua form memiliki styling yang sama
- Icon placement yang konsisten
- Spacing dan padding yang seragam

### 2. Maintainability
- Single source of truth untuk form styling
- Easy to update design across all forms
- Consistent validation behavior

### 3. Developer Experience
- Declarative configuration
- Type-safe field definitions
- Auto-generated dividers dan spacing

### 4. User Experience
- Clear visual hierarchy
- Consistent interaction patterns
- Intuitive field identification with icons

## Migration Guide

### Before (Custom Implementation)
```dart
// Duplicate code across multiple files
Widget _buildTextField(...) {
  return Column(
    children: [
      Row(
        children: [
          Container(...), // icon container
          Expanded(
            child: Column(
              children: [
                Text(...), // label
                TextFormField(...), // input
              ],
            ),
          ),
        ],
      ),
      Divider(...),
    ],
  );
}
```

### After (AppFormCard)
```dart
// Single, reusable component
AppFormCard(
  title: 'Form Title',
  titleIcon: Icons.edit,
  fields: [
    FormFieldConfig(
      label: 'Field Label',
      icon: Icons.text_fields,
      type: FormFieldType.textRequired,
      controller: controller,
      isRequired: true,
    ),
  ],
)
```

## File Locations
- **Component**: `lib/common/widgets/app_card_components.dart`
- **Implementation Examples**:
  - `lib/features/dashboard/presentation/pages/DataDiri/edit_profile.dart`
  - `lib/features/dashboard/presentation/pages/MenuUtama/Cuti/tambah_cuti_page.dart`
  - `lib/features/dashboard/presentation/pages/MenuUtama/Lembur/tambah_lembur_page.dart`
