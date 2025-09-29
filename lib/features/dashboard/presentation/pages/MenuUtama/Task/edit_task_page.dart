import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/theme/my_theme.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'package:ppnpm_dpr/common/widgets/app_card_components.dart';
import 'task_data.dart';

class EditTaskPage extends ConsumerStatefulWidget {
  final TaskData taskData;
  final Function(TaskData)? onTaskUpdated;

  const EditTaskPage({super.key, required this.taskData, this.onTaskUpdated});

  @override
  ConsumerState<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends ConsumerState<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedPriority;
  late String _selectedStatus;

  DateTime? _reminderDateTime;
  bool _enableReminder = false;

  final List<String> _priorities = ['High', 'Medium', 'Low'];
  final List<String> _statuses = ['To Do', 'In Review', 'Complete'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskData.title);
    _descriptionController = TextEditingController(
      text: widget.taskData.description,
    );
    _selectedDate = widget.taskData.dueDate;
    _selectedPriority = widget.taskData.priority;
    _selectedStatus = widget.taskData.status;

    // Initialize reminder settings from task data
    _enableReminder = widget.taskData.hasReminder;
    _reminderDateTime = widget.taskData.reminderDateTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppCustomAppBar(
        title: 'Ubah Task',
        onBackPressed: () => Navigator.of(context).pop(),
        backTooltip: 'Kembali',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskForm(theme),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primarySwatch,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'SIMPAN PERUBAHAN',
                    style: theme.typographyRegular.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildTaskForm(MyTheme theme) {
    return Column(
      children: [
        AppFormCard(
          title: 'Informasi Task',
          titleIcon: Icons.task_alt,
          fields: [
            FormFieldConfig(
              label: 'Judul Task',
              icon: Icons.title,
              type: FormFieldType.textRequired,
              isRequired: true,
              controller: _titleController,
              hintText: 'Masukkan judul task',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul task tidak boleh kosong';
                }
                return null;
              },
            ),
            FormFieldConfig(
              label: 'Deskripsi Task',
              icon: Icons.description,
              type: FormFieldType.multiline,
              controller: _descriptionController,
              hintText: 'Masukkan deskripsi task (opsional)',
              maxLines: 3,
            ),
            FormFieldConfig(
              label: 'Tanggal Deadline',
              icon: Icons.calendar_today,
              type: FormFieldType.datePicker,
              isRequired: true,
              controller: TextEditingController(
                text: DateFormat('dd-MM-yyyy').format(_selectedDate),
              ),
              hintText: 'Pilih tanggal deadline',
              suffixIcon: Icons.calendar_today,
              onTap: () => _selectDate(context),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pilih tanggal deadline';
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppFormCard(
          title: 'Prioritas & Status',
          titleIcon: Icons.flag,
          fields: [
            FormFieldConfig(
              label: 'Prioritas Task',
              icon: Icons.flag,
              type: FormFieldType.dropdown,
              isRequired: true,
              options: _priorities,
              value: _selectedPriority,
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pilih prioritas task';
                }
                return null;
              },
            ),
            FormFieldConfig(
              label: 'Status Task',
              icon: Icons.info,
              type: FormFieldType.dropdown,
              isRequired: true,
              options: _statuses,
              value: _selectedStatus,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pilih status task';
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildReminderSection(theme),
      ],
    );
  }

  Widget _buildReminderSection(MyTheme theme) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primarySwatch,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Pengingat Task',
                style: theme.typographyRegular.bodyMedium.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Enable reminder switch
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.alarm, color: Colors.grey[600], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Aktifkan Pengingat',
                      style: theme.typographyRegular.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _enableReminder,
                      onChanged: (value) {
                        setState(() {
                          _enableReminder = value;
                          if (!value) {
                            _reminderDateTime = null;
                          }
                        });
                      },
                      activeColor: theme.primarySwatch,
                    ),
                  ],
                ),

                if (_enableReminder) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Reminder datetime picker
                  GestureDetector(
                    onTap: _selectReminderDateTime,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _reminderDateTime != null
                                ? DateFormat(
                                  'dd-MM-yyyy, HH:mm',
                                ).format(_reminderDateTime!)
                                : 'Pilih waktu pengingat',
                            style: theme.typographyRegular.bodySmall.copyWith(
                              color:
                                  _reminderDateTime != null
                                      ? Colors.grey[900]
                                      : Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Anda akan menerima notifikasi pada waktu yang dipilih',
                    style: theme.typographyRegular.bodySmall.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectReminderDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _selectedDate,
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime:
            _reminderDateTime != null
                ? TimeOfDay.fromDateTime(_reminderDateTime!)
                : TimeOfDay.now(),
      );

      if (time != null) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        // Check if selected time is not in the past
        if (selectedDateTime.isAfter(DateTime.now())) {
          setState(() {
            _reminderDateTime = selectedDateTime;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Pilih tanggal dan waktu yang akan datang'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Complete':
        return Colors.green;
      case 'To Do':
        return Colors.orange;
      case 'In Review':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedTask = TaskData(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _selectedDate,
      priority: _selectedPriority,
      status: _selectedStatus,
      assignees: [],
      commentsCount: 0,
      filesCount: 0,
      priorityColor: _getPriorityColor(_selectedPriority),
      statusColor: _getStatusColor(_selectedStatus),
      hasReminder: _enableReminder,
      reminderDateTime: _reminderDateTime,
    );

    // Schedule notifications if enabled
    if (_enableReminder && _reminderDateTime != null) {
      try {
        // Check and request permissions first
        final hasPermissions =
            await NotificationService.requestPermissionsWithDialog(context);

        if (hasPermissions) {
          // Schedule task reminder notification
          await NotificationService.scheduleTaskReminder(
            id: updatedTask.title.hashCode,
            title: 'Task Reminder',
            body: 'Don\'t forget: ${updatedTask.title}',
            scheduledDate: _reminderDateTime!,
          );

          // Also schedule due date notification (1 day before)
          final oneDayBefore = updatedTask.dueDate.subtract(
            const Duration(days: 1),
          );
          if (oneDayBefore.isAfter(DateTime.now())) {
            await NotificationService.scheduleDueDateReminder(
              id: updatedTask.title.hashCode + 1,
              title: 'Task Due Tomorrow',
              body: 'Task "${updatedTask.title}" is due tomorrow!',
              scheduledDate: DateTime(
                oneDayBefore.year,
                oneDayBefore.month,
                oneDayBefore.day,
                9, // 9 AM
                0,
              ),
            );
          }
        } else {
          // Show message if permissions denied
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Notifikasi dinonaktifkan - pengingat tidak akan bekerja',
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        print('Failed to schedule notification: $e');
      }
    }

    if (widget.onTaskUpdated != null) {
      widget.onTaskUpdated!(updatedTask);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _enableReminder && _reminderDateTime != null
              ? 'Task berhasil diperbarui dengan pengingat!'
              : 'Task berhasil diperbarui!',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context, updatedTask);
  }
}
