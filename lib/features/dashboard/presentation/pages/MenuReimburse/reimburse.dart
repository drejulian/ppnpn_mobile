import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';

class ReimbursePage extends ConsumerStatefulWidget {
  const ReimbursePage({super.key});

  @override
  ConsumerState<ReimbursePage> createState() => _ReimbursePageState();
}

class _ReimbursePageState extends ConsumerState<ReimbursePage> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primarySwatch),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Reimburse',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24.0 : 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(theme, context),
                const SizedBox(height: 24),

                // Reimbursement Form Section
                _buildReimbursementForm(theme, context),
                const SizedBox(height: 24),

                // Reimbursement History Section
                _buildReimbursementHistory(theme, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [theme.primarySwatch, theme.secondarySwatch],
              ),
            ),
            child: const Icon(Icons.receipt, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengajuan Reimburse',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'Ajukan dan lacak penggantian biaya Anda',
                  style: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReimbursementForm(dynamic theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Formulir Pengajuan Reimburse',
          style: theme.typographyRegular.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
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
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Jenis Pengeluaran',
                  labelStyle: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  labelStyle: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  labelStyle: theme.typographyRegular.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  debugPrint('📝 Submitting reimbursement form');
                  debugPrint('👤 User: miftahul01');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengajuan reimburse berhasil dikirim'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primarySwatch,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'Ajukan Reimburse',
                  style: theme.typographyRegular.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReimbursementHistory(dynamic theme, BuildContext context) {
    final currentTime = DateTime.now();
    final reimbursementItems = [
      {
        'title': 'Transportasi Meeting',
        'amount': 'Rp 500.000',
        'date': currentTime.subtract(const Duration(days: 3)),
        'status': 'Disetujui',
        'statusColor': Colors.green,
      },
      {
        'title': 'Biaya Training',
        'amount': 'Rp 1.200.000',
        'date': currentTime.subtract(const Duration(days: 7)),
        'status': 'Menunggu',
        'statusColor': Colors.orange,
      },
      {
        'title': 'Peralatan Kantor',
        'amount': 'Rp 750.000',
        'date': currentTime.subtract(const Duration(days: 15)),
        'status': 'Ditolak',
        'statusColor': Colors.red,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Reimburse',
              style: theme.typographyRegular.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            GestureDetector(
              onTap: () {
                debugPrint('📜 Viewing all reimbursement history');
                debugPrint('👤 User: miftahul01');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur riwayat lengkap akan segera tersedia'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Lihat Semua',
                style: theme.typographyRegular.bodySmall.copyWith(
                  color: theme.primarySwatch,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
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
          child: reimbursementItems.isEmpty
              ? _buildEmptyState('Tidak ada riwayat reimburse', Icons.receipt)
              : Column(
                  children: reimbursementItems.map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.primarySwatch.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.receipt_long,
                                color: theme.primarySwatch,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] as String,
                                    style: theme.typographyRegular.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Divider(color: Colors.grey[200], height: 1),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    icon: Icons.monetization_on,
                                    label: 'Jumlah',
                                    value: item['amount'] as String,
                                    theme: theme,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    icon: Icons.calendar_today,
                                    label: 'Tanggal',
                                    value: DateFormat('dd MMMM yyyy', 'id_ID').format(item['date'] as DateTime),
                                    theme: theme,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    icon: Icons.info,
                                    label: 'Status',
                                    value: item['status'] as String,
                                    statusColor: item['statusColor'] as Color,
                                    theme: theme,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required dynamic theme,
    Color? statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.typographyRegular.bodyExtraSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              statusColor != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        value,
                        style: theme.typographyRegular.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: theme.typographyRegular.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}