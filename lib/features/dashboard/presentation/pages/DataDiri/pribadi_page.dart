import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';

class PribadiPage extends ConsumerStatefulWidget {
  const PribadiPage({super.key});

  @override
  ConsumerState<PribadiPage> createState() => _PribadiPageState();
}

class _PribadiPageState extends ConsumerState<PribadiPage> {
  // Text Controllers
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _propinsiController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _kelurahanController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _rwController = TextEditingController();
  final TextEditingController _kodePosController = TextEditingController();
  final TextEditingController _teleponRumahController = TextEditingController();
  final TextEditingController _teleponKantorController =
      TextEditingController();
  final TextEditingController _handphoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Dropdown values
  String _selectedStatusPerkawinan = 'Kawin';
  String _selectedAgama = 'Islam';
  String _selectedGolonganDarah = 'O';

  // Radio button values
  String _selectedJenisKelamin = 'Laki-Laki';
  String _selectedStatusDomisili = 'Alamat Rumah dan Alamat Sesuai KTP';

  // Dropdown options
  final List<String> _statusPerkawinanOptions = [
    'Belum Kawin',
    'Kawin',
    'Cerai Hidup',
    'Cerai Mati',
  ];

  final List<String> _agamaOptions = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];

  final List<String> _golonganDarahOptions = ['A', 'B', 'AB', 'O'];

  final List<String> _jenisKelaminOptions = ['Laki-Laki', 'Perempuan'];

  final List<String> _statusDomisiliOptions = [
    'Alamat Rumah dan Alamat Sesuai KTP',
    'Alamat Rumah dan Alamat Sesuai KTP berbeda',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current values
    _tempatLahirController.text = 'TANGERANG';
    _tanggalLahirController.text = '05-10-1981';
    _addressController.text = 'Cluster Kencana Pamulang A25, Jalan Sawo';
    _propinsiController.text = 'BANTEN';
    _kotaController.text = '';
    _kecamatanController.text = '';
    _kelurahanController.text = '';
    _rtController.text = '000';
    _rwController.text = '009';
    _kodePosController.text = '15020';
    _teleponRumahController.text = '';
    _teleponKantorController.text = '';
    _handphoneController.text = '08128365992';
    _emailController.text = '';

    _selectedStatusPerkawinan = 'Kawin';
    _selectedAgama = 'Islam';
    _selectedGolonganDarah = 'O';
    _selectedJenisKelamin = 'Laki-Laki';
    _selectedStatusDomisili = 'Alamat Rumah dan Alamat Sesuai KTP';
  }

  @override
  void dispose() {
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _addressController.dispose();
    _propinsiController.dispose();
    _kotaController.dispose();
    _kecamatanController.dispose();
    _kelurahanController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _kodePosController.dispose();
    _teleponRumahController.dispose();
    _teleponKantorController.dispose();
    _handphoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Real-time Indonesian time (UTC+7)
    final currentTime = DateTime.now().toUtc().add(const Duration(hours: 7));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Data Pribadi',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primarySwatch,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 16.0,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Data Pribadi
            _buildFormDataPribadi(theme),

            const SizedBox(height: 20), // Bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildFormDataPribadi(dynamic theme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Data Pribadi',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Form Fields
          _buildDropdownField(
            'Status Perkawinan (Marital Status)',
            _selectedStatusPerkawinan,
            _statusPerkawinanOptions,
            Icons.favorite,
            theme,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedStatusPerkawinan = value!;
              });
            },
          ),

          _buildDropdownField(
            'Agama (Religion)',
            _selectedAgama,
            _agamaOptions,
            Icons.place,
            theme,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedAgama = value!;
              });
            },
          ),

          _buildTextFieldWithRequired(
            'Tempat Lahir (Place of Birth)',
            _tempatLahirController,
            Icons.location_city,
            theme,
            isRequired: true,
            hintText: 'Masukkan tempat lahir',
          ),

          _buildDatePickerField(
            'Tanggal Lahir (Date of Birth)',
            _tanggalLahirController,
            Icons.cake,
            theme,
            isRequired: true,
          ),

          _buildRadioButtonField(
            'Jenis Kelamin (Gender)',
            _selectedJenisKelamin,
            _jenisKelaminOptions,
            Icons.wc,
            theme,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedJenisKelamin = value!;
              });
            },
          ),

          _buildDropdownField(
            'Golongan Darah (Blood Type)',
            _selectedGolonganDarah,
            _golonganDarahOptions,
            Icons.bloodtype,
            theme,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedGolonganDarah = value!;
              });
            },
          ),

          _buildRadioButtonField(
            'Status Domisili (Domicile Status)',
            _selectedStatusDomisili,
            _statusDomisiliOptions,
            Icons.home,
            theme,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedStatusDomisili = value!;
              });
            },
          ),

          _buildTextAreaField(
            'Address',
            _addressController,
            Icons.location_on,
            theme,
            isRequired: true,
            hintText: 'Masukkan alamat lengkap',
          ),

          _buildTextFieldWithRequired(
            'Propinsi (Province)',
            _propinsiController,
            Icons.map,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama propinsi',
          ),

          _buildTextFieldWithRequired(
            'Kota (City)',
            _kotaController,
            Icons.location_city,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama kota',
          ),

          _buildTextFieldWithRequired(
            'Kecamatan (District)',
            _kecamatanController,
            Icons.place,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama kecamatan',
          ),

          _buildTextFieldWithRequired(
            'Kelurahan (Sub-district)',
            _kelurahanController,
            Icons.location_on,
            theme,
            isRequired: true,
            hintText: 'Masukkan nama kelurahan',
          ),

          _buildTextFieldWithRequired(
            'RT',
            _rtController,
            Icons.home_outlined,
            theme,
            isRequired: true,
            hintText: 'Ketik \'000\' Jika Tidak Diketahui',
            keyboardType: TextInputType.number,
          ),

          _buildTextFieldWithRequired(
            'RW',
            _rwController,
            Icons.home_outlined,
            theme,
            isRequired: true,
            hintText: 'Ketik \'000\' Jika Tidak Diketahui',
            keyboardType: TextInputType.number,
          ),

          _buildTextFieldWithRequired(
            'Kode Pos (Postal Code)',
            _kodePosController,
            Icons.local_post_office,
            theme,
            isRequired: true,
            hintText: 'Masukkan kode pos',
            keyboardType: TextInputType.number,
          ),

          _buildTextField(
            'Telepon Rumah (Home Phone)',
            _teleponRumahController,
            Icons.phone,
            theme,
            hintText: 'Masukkan nomor telepon rumah',
            keyboardType: TextInputType.phone,
          ),

          _buildTextField(
            'Telepon Kantor (Office Phone)',
            _teleponKantorController,
            Icons.business,
            theme,
            hintText: 'Masukkan nomor telepon kantor',
            keyboardType: TextInputType.phone,
          ),

          _buildTextFieldWithRequired(
            'Handphone (WA) (Whatsapp Mobile Phone)',
            _handphoneController,
            Icons.phone_android,
            theme,
            isRequired: true,
            hintText: 'Masukkan nomor handphone',
            keyboardType: TextInputType.phone,
          ),

          _buildTextField(
            'Email',
            _emailController,
            Icons.email,
            theme,
            hintText: 'Masukkan alamat email',
            keyboardType: TextInputType.emailAddress,
            isLast: true,
          ),

          // Save Button
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _saveData(context, theme);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primarySwatch,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'SIMPAN',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    required Function(String?) onChanged,
    bool isLast = false,
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
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
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
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
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
                    value: value,
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
                        items.map((String item) {
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
                    onChanged: onChanged,
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

  Widget _buildRadioButtonField(
    String label,
    String selectedValue,
    List<String> options,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    required Function(String?) onChanged,
    bool isLast = false,
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
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
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
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
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
                  Column(
                    children:
                        options.map((String option) {
                          return RadioListTile<String>(
                            title: Text(
                              option,
                              style: theme.typographyRegular.bodySmall.copyWith(
                                color: Colors.grey[800],
                              ),
                            ),
                            value: option,
                            groupValue: selectedValue,
                            onChanged: onChanged,
                            activeColor: theme.primarySwatch,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          );
                        }).toList(),
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
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    bool isLast = false,
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
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
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
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
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
                    controller: controller,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Pilih tanggal lahir',
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: theme.primarySwatch,
                      ),
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
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(1981, 10, 5),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        controller.text = DateFormat(
                          'dd-MM-yyyy',
                        ).format(pickedDate);
                      }
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

  Widget _buildTextAreaField(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    String? hintText,
    bool isLast = false,
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
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
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
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
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
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: hintText,
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
                      hintStyle: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
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

  Widget _buildTextFieldWithRequired(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    bool isRequired = false,
    String? hintText,
    TextInputType? keyboardType,
    bool isLast = false,
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
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
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
                          label,
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isRequired)
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
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      hintText: hintText,
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
                      hintStyle: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    dynamic theme, {
    String? hintText,
    TextInputType? keyboardType,
    bool isLast = false,
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
                color: theme.primarySwatch.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primarySwatch, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      hintText: hintText,
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
                      hintStyle: theme.typographyRegular.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
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

  void _saveData(BuildContext context, dynamic theme) {
    // Validate required fields
    List<String> errors = [];

    if (_selectedStatusPerkawinan.isEmpty) {
      errors.add('Status Perkawinan harus dipilih');
    }
    if (_selectedAgama.isEmpty) {
      errors.add('Agama harus dipilih');
    }
    if (_tempatLahirController.text.isEmpty) {
      errors.add('Tempat Lahir harus diisi');
    }
    if (_tanggalLahirController.text.isEmpty) {
      errors.add('Tanggal Lahir harus diisi');
    }
    if (_selectedJenisKelamin.isEmpty) {
      errors.add('Jenis Kelamin harus dipilih');
    }
    if (_selectedGolonganDarah.isEmpty) {
      errors.add('Golongan Darah harus dipilih');
    }
    if (_selectedStatusDomisili.isEmpty) {
      errors.add('Status Domisili harus dipilih');
    }
    if (_addressController.text.isEmpty) {
      errors.add('Address harus diisi');
    }
    if (_propinsiController.text.isEmpty) {
      errors.add('Propinsi harus diisi');
    }
    if (_kotaController.text.isEmpty) {
      errors.add('Kota harus diisi');
    }
    if (_kecamatanController.text.isEmpty) {
      errors.add('Kecamatan harus diisi');
    }
    if (_kelurahanController.text.isEmpty) {
      errors.add('Kelurahan harus diisi');
    }
    if (_rtController.text.isEmpty) {
      errors.add('RT harus diisi');
    }
    if (_rwController.text.isEmpty) {
      errors.add('RW harus diisi');
    }
    if (_kodePosController.text.isEmpty) {
      errors.add('Kode Pos harus diisi');
    }
    if (_handphoneController.text.isEmpty) {
      errors.add('Handphone harus diisi');
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(context, theme, errors.join('\n'));
      return;
    }

    // Show success dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Simpan Data Pribadi',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text('Data pribadi berhasil disimpan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(BuildContext context, dynamic theme, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Error',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
