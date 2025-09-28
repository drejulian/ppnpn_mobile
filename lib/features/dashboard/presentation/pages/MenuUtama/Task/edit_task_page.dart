import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ppnpm_dpr/app/theme.dart';
import 'package:ppnpm_dpr/common/theme/my_theme.dart';
import 'package:ppnpm_dpr/common/services/notification_service.dart';
import 'task_data.dart';

class EditTaskPage extends ConsumerStatefulWidget {
  final TaskData taskData;
  final Function(TaskData)? onTaskUpdated;

  const EditTaskPage({
    super.key,
    required this.taskData,
    this.onTaskUpdated,
  });

  @override
  ConsumerState<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends ConsumerState<EditTaskPage> {
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
    _descriptionController = TextEditingController(text: widget.taskData.description);
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: theme.primarySwatch,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Task',
          style: theme.typographyBold.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: Text(
              'Save',
              style: theme.typographyRegular.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskForm(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskForm(MyTheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Field
          _buildLabel('Task Title', theme),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _titleController,
            hint: 'Enter task title',
            theme: theme,
          ),
          const SizedBox(height: 20),

          // Description Field
          _buildLabel('Description', theme),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _descriptionController,
            hint: 'Enter task description',
            maxLines: 3,
            theme: theme,
          ),
          const SizedBox(height: 20),

          // Due Date
          _buildLabel('Due Date', theme),
          const SizedBox(height: 8),
          _buildDateField(theme),
          const SizedBox(height: 20),

          // Priority and Status Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Priority', theme),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedPriority,
                      items: _priorities,
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                      theme: theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Status', theme),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedStatus,
                      items: _statuses,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Reminder Section
          _buildReminderSection(theme),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, MyTheme theme) {
    return Text(
      text,
      style: theme.typographyRegular.bodyMedium.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.grey[900],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required MyTheme theme,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.typographyRegular.bodyMedium.copyWith(
          color: Colors.grey[500],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primarySwatch),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: theme.typographyRegular.bodyMedium,
    );
  }

  Widget _buildDateField(MyTheme theme) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd MMM yyyy').format(_selectedDate),
              style: theme.typographyRegular.bodyMedium,
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required MyTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: theme.typographyRegular.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildReminderSection(MyTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notifications_outlined, color: theme.primarySwatch, size: 20),
            const SizedBox(width: 8),
            _buildLabel('Reminder', theme),
          ],
        ),
        const SizedBox(height: 12),
        
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
                    'Enable Task Reminder',
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
                        Icon(Icons.schedule, color: Colors.grey[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _reminderDateTime != null 
                              ? DateFormat('dd MMM yyyy, HH:mm').format(_reminderDateTime!)
                              : 'Select reminder time',
                          style: theme.typographyRegular.bodySmall.copyWith(
                            color: _reminderDateTime != null 
                                ? Colors.grey[900] 
                                : Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 14),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                Text(
                  'You will receive a notification at the selected time',
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
        initialTime: _reminderDateTime != null 
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
              content: const Text('Please select a future date and time'),
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
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a task title'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
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
        final hasPermissions = await NotificationService.requestPermissionsWithDialog(context);
        
        if (hasPermissions) {
          // Schedule task reminder notification
          await NotificationService.scheduleTaskReminder(
            id: updatedTask.title.hashCode,
            title: 'Task Reminder',
            body: 'Don\'t forget: ${updatedTask.title}',
            scheduledDate: _reminderDateTime!,
          );

          // Also schedule due date notification (1 day before)
          final oneDayBefore = updatedTask.dueDate.subtract(const Duration(days: 1));
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
              content: const Text('Notifications disabled - reminder will not work'),
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
        content: Text(_enableReminder && _reminderDateTime != null 
            ? 'Task updated with reminder set!'
            : 'Task updated successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    Navigator.pop(context, updatedTask);
  }
}
