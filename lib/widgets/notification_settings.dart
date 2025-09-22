import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/language_service.dart';
import '../widgets/gradient_card.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _dailyReminders = true;
  bool _weeklyReports = true;
  bool _meditationReminders = true;
  bool _moodReminders = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  int _meditationReminderHour = 9;
  int _moodReminderHour = 21;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Cargar configuraciones guardadas
    // En una implementación real, esto vendría de SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGeneralSettings(context),
                      const SizedBox(height: 24),
                      _buildReminderSettings(context),
                      const SizedBox(height: 24),
                      _buildNotificationTypes(context),
                      const SizedBox(height: 24),
                      _buildTestNotification(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                color: Theme.of(context).colorScheme.onBackground,
              ),
              const SizedBox(width: 8),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return Text(
                    languageService.getLocalizedText(
                      'notification_settings_title',
                    ),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Text(
                languageService.getLocalizedText(
                  'notification_settings_subtitle',
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onBackground.withOpacity(0.7),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildGeneralSettings(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('general_settings'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return _buildSettingItem(
                  context,
                  languageService.getLocalizedText('daily_notifications'),
                  languageService.getLocalizedText('daily_notifications_desc'),
                  _dailyReminders,
                  (value) => setState(() => _dailyReminders = value),
                  Icons.notifications_active,
                );
              },
            ),
            _buildDivider(),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return _buildSettingItem(
                  context,
                  languageService.getLocalizedText(
                    'weekly_reports_notifications',
                  ),
                  languageService.getLocalizedText(
                    'weekly_reports_notifications_desc',
                  ),
                  _weeklyReports,
                  (value) => setState(() => _weeklyReports = value),
                  Icons.analytics,
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildReminderSettings(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('reminder_schedules'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return _buildTimeSetting(
                  context,
                  languageService.getLocalizedText('daily_reminder_time'),
                  '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                  () => _selectTime(context),
                  Icons.access_time,
                );
              },
            ),
            _buildDivider(),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return _buildTimeSetting(
                  context,
                  languageService.getLocalizedText('meditation_reminder'),
                  '${_meditationReminderHour.toString().padLeft(2, '0')}:00',
                  () => _selectMeditationTime(context),
                  Icons.self_improvement,
                );
              },
            ),
            _buildDivider(),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return _buildTimeSetting(
                  context,
                  languageService.getLocalizedText('mood_reminder'),
                  '${_moodReminderHour.toString().padLeft(2, '0')}:00',
                  () => _selectMoodTime(context),
                  Icons.mood,
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildNotificationTypes(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('notification_types'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return _buildSettingItem(
                  context,
                  languageService.getLocalizedText('meditation_reminders'),
                  languageService.getLocalizedText('meditation_reminders_desc'),
                  _meditationReminders,
                  (value) => setState(() => _meditationReminders = value),
                  Icons.self_improvement,
                );
              },
            ),
            _buildDivider(),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return _buildSettingItem(
                  context,
                  languageService.getLocalizedText('mood_reminders'),
                  languageService.getLocalizedText('mood_reminders_desc'),
                  _moodReminders,
                  (value) => setState(() => _moodReminders = value),
                  Icons.mood,
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildTestNotification(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('test_notifications'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('test_notifications_desc'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _sendTestNotification,
                    icon: const Icon(Icons.send),
                    label: Text(
                      languageService.getLocalizedText(
                        'send_test_notification',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTimeSetting(
    BuildContext context,
    String title,
    String time,
    VoidCallback onTap,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          time,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.2),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _selectMeditationTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _meditationReminderHour, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _meditationReminderHour = picked.hour;
      });
    }
  }

  Future<void> _selectMoodTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _moodReminderHour, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _moodReminderHour = picked.hour;
      });
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      final languageService = Provider.of<LanguageService>(
        context,
        listen: false,
      );

      await NotificationService.showNotification(
        id: 999,
        title:
            'MindSpace - ${languageService.getLocalizedText('test_notifications')}',
        body: '¡Las notificaciones están funcionando correctamente!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageService.getLocalizedText('test_notification_sent'),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final languageService = Provider.of<LanguageService>(
          context,
          listen: false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${languageService.getLocalizedText('test_notification_error')}: $e',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
