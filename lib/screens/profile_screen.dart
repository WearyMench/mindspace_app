import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/mood_provider.dart';
import '../providers/meditation_provider.dart';
import '../providers/journal_provider.dart';
import '../services/language_service.dart';
import '../services/theme_service.dart';
import '../widgets/gradient_card.dart';
import '../widgets/notification_settings.dart';
import '../widgets/theme_preview.dart';
import 'statistics_screen.dart';
import 'export_screen.dart';
import 'backup_screen.dart';
import 'achievements_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _reminderTime = 20; // 20:00
  bool _weeklyReports = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildUserStats(context),
                const SizedBox(height: 24),
                _buildSettingsSection(context),
                const SizedBox(height: 24),
                _buildDataSection(context),
                const SizedBox(height: 24),
                _buildAboutSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('user_profile'),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
        const SizedBox(height: 8),
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('profile_subtitle'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.7),
              ),
            );
          },
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: -0.2),
      ],
    );
  }

  Widget _buildUserStats(BuildContext context) {
    return Consumer3<MoodProvider, MeditationProvider, JournalProvider>(
      builder: (context, moodProvider, meditationProvider, journalProvider, child) {
        final moodStats = moodProvider.getMoodStatistics();
        final meditationStats = meditationProvider.getMeditationStatistics();
        final journalStats = journalProvider.getJournalStatistics();

        return GradientCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                languageService.getLocalizedText(
                                  'user_profile',
                                ),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onBackground,
                                      fontWeight: FontWeight.bold,
                                    ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                '${languageService.getLocalizedText('member_since')} ${DateTime.now().month}/${DateTime.now().year}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showEditProfileDialog(context),
                      icon: const Icon(Icons.edit),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            languageService.getLocalizedText('mood'),
                            moodStats['totalEntries'].toString(),
                            languageService.getLocalizedText('registros'),
                            Icons.mood,
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            languageService.getLocalizedText('meditation'),
                            meditationStats['totalSessions'].toString(),
                            languageService.getLocalizedText('sesiones'),
                            Icons.self_improvement,
                            Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            languageService.getLocalizedText('journal'),
                            journalStats['totalEntries'].toString(),
                            languageService.getLocalizedText('entradas'),
                            Icons.book,
                            Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('app_settings'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
        const SizedBox(height: 16),
        GradientCard(
          child: Column(
            children: [
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.notifications,
                    title: languageService.getLocalizedText('notifications'),
                    subtitle: languageService.getLocalizedText(
                      'notifications_subtitle',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationSettings(),
                        ),
                      );
                    },
                  );
                },
              ),
              _buildDivider(),
              Consumer2<ThemeService, LanguageService>(
                builder: (context, themeService, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.palette,
                    title: languageService.getLocalizedText('theme'),
                    subtitle: themeService.themeModeLabel,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showThemeSelector(context, themeService),
                  );
                },
              ),
              _buildDivider(),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.language,
                    title: languageService.getLocalizedText('language'),
                    subtitle: languageService.currentLanguageName,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () =>
                        _showLanguageSelector(context, languageService),
                  );
                },
              ),
              _buildDivider(),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.schedule,
                    title: languageService.getLocalizedText('reminder_time'),
                    subtitle: '${_reminderTime.toString().padLeft(2, '0')}:00',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showTimePicker(context),
                  );
                },
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 700.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('data_privacy'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 800.ms);
          },
        ),
        const SizedBox(height: 16),
        GradientCard(
          child: Column(
            children: [
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.analytics,
                    title: languageService.getLocalizedText('statistics'),
                    subtitle: languageService.getLocalizedText(
                      'statistics_subtitle',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatisticsScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
              _buildDivider(),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.emoji_events,
                    title: languageService.getLocalizedText('achievements'),
                    subtitle: languageService.getLocalizedText(
                      'achievements_subtitle',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
              _buildDivider(),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.analytics,
                    title: languageService.getLocalizedText('weekly_reports'),
                    subtitle: languageService.getLocalizedText(
                      'weekly_reports_subtitle',
                    ),
                    trailing: Switch(
                      value: _weeklyReports,
                      onChanged: (value) =>
                          setState(() => _weeklyReports = value),
                      activeColor: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                },
              ),
              _buildDivider(),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.download,
                    title: languageService.getLocalizedText('export_data'),
                    subtitle: languageService.getLocalizedText(
                      'export_data_subtitle',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExportScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
              _buildDivider(),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.backup,
                    title: languageService.getLocalizedText('backup_restore'),
                    subtitle: languageService.getLocalizedText(
                      'backup_restore_subtitle',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BackupScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
              _buildDivider(),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.delete_forever,
                    title: languageService.getLocalizedText('delete_account'),
                    subtitle: languageService.getLocalizedText(
                      'delete_account_subtitle',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showDeleteAccountDialog(context),
                    textColor: Theme.of(context).colorScheme.error,
                  );
                },
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 900.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('about'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 1000.ms);
          },
        ),
        const SizedBox(height: 16),
        GradientCard(
          child: Column(
            children: [
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.info,
                    title: languageService.getLocalizedText('version'),
                    subtitle: '1.0.0',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showAboutDialog(context),
                  );
                },
              ),
              _buildDivider(),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.help,
                    title: languageService.getLocalizedText('help_support'),
                    subtitle: languageService.getLocalizedText(
                      'help_support_subtitle',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showHelpDialog(context),
                  );
                },
              ),
              _buildDivider(),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.privacy_tip,
                    title: languageService.getLocalizedText('privacy_policy'),
                    subtitle: languageService.getLocalizedText(
                      'privacy_policy_subtitle',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showPrivacyDialog(context),
                  );
                },
              ),
              _buildDivider(),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildSettingItem(
                    context,
                    icon: Icons.description,
                    title: languageService.getLocalizedText('terms_of_service'),
                    subtitle: languageService.getLocalizedText(
                      'terms_of_service_subtitle',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showTermsDialog(context),
                  );
                },
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 1100.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? Theme.of(context).colorScheme.secondary)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: textColor ?? Theme.of(context).colorScheme.secondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: textColor ?? Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color:
              textColor?.withOpacity(0.7) ??
              Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(languageService.getLocalizedText('edit_profile'));
          },
        ),
        content: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('edit_profile_message'),
            );
          },
        ),
        actions: [
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(languageService.getLocalizedText('close')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(
    BuildContext context,
    LanguageService languageService,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('language'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('language_subtitle'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ...languageService.supportedLocales.map(
              (locale) =>
                  _buildLanguageOption(context, locale, languageService),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    Locale locale,
    LanguageService languageService,
  ) {
    final isSelected = languageService.currentLocale == locale;
    final languageName = languageService.getLanguageName(locale);
    final flag = _getFlagForLocale(locale);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            languageService.changeLanguage(locale);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Bandera del idioma
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(flag, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 16),
                // Información del idioma
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        languageName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getLanguageDescription(locale),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Indicador de selección
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFlagForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return '🇪🇸';
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'it':
        return '🇮🇹';
      case 'pt':
        return '🇧🇷';
      default:
        return '🌐';
    }
  }

  String _getLanguageDescription(Locale locale) {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    switch (locale.languageCode) {
      case 'es':
        return languageService.getLocalizedText('spanish_default');
      case 'en':
        return languageService.getLocalizedText('english_default');
      case 'fr':
        return languageService.getLocalizedText('french_default');
      case 'de':
        return languageService.getLocalizedText('german_default');
      case 'it':
        return languageService.getLocalizedText('italian_default');
      case 'pt':
        return languageService.getLocalizedText('portuguese_default');
      default:
        return languageService.getLocalizedText('selected_language');
    }
  }

  void _showThemeSelector(BuildContext context, ThemeService themeService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('select_theme'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('select_theme_subtitle'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Opciones de tema con mejor diseño
            ...themeService.availableThemes.map(
              (themeMode) =>
                  _buildThemeOption(context, themeMode, themeService),
            ),
            const SizedBox(height: 24),
            // Vista previa del tema
            const ThemePreview(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    AppThemeMode themeMode,
    ThemeService themeService,
  ) {
    final isSelected = themeService.currentThemeMode == themeMode;
    final isDark = themeMode == AppThemeMode.dark;
    final isSystem = themeMode == AppThemeMode.system;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            themeService.changeThemeMode(themeMode);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Icono del tema
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : isSystem
                        ? Colors.grey[300]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    isDark
                        ? Icons.dark_mode
                        : isSystem
                        ? Icons.settings_brightness
                        : Icons.light_mode,
                    color: isDark
                        ? Colors.white
                        : isSystem
                        ? Colors.grey[600]
                        : Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Información del tema
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<LanguageService>(
                        builder: (context, languageService, child) {
                          return Text(
                            _getLocalizedThemeLabel(themeMode, languageService),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getThemeDescription(themeMode),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Indicador de selección
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getThemeDescription(AppThemeMode themeMode) {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    switch (themeMode) {
      case AppThemeMode.light:
        return languageService.getLocalizedText('light_theme');
      case AppThemeMode.dark:
        return languageService.getLocalizedText('dark_theme');
      case AppThemeMode.system:
        return languageService.getLocalizedText('system_theme');
    }
  }

  void _showTimePicker(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderTime, minute: 0),
    ).then((time) {
      if (time != null) {
        setState(() => _reminderTime = time.hour);
      }
    });
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('delete_account_confirm'),
            );
          },
        ),
        content: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('delete_account_message'),
            );
          },
        ),
        actions: [
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(languageService.getLocalizedText('cancel')),
              );
            },
          ),
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implementar eliminación de cuenta
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(languageService.getLocalizedText('delete')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );

    showAboutDialog(
      context: context,
      applicationName: 'MindSpace',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.self_improvement,
        size: 48,
        color: Theme.of(context).colorScheme.secondary,
      ),
      children: [Text(languageService.getLocalizedText('about_message'))],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(languageService.getLocalizedText('help_support'));
          },
        ),
        content: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(languageService.getLocalizedText('help_message'));
          },
        ),
        actions: [
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(languageService.getLocalizedText('close')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(languageService.getLocalizedText('privacy_policy'));
          },
        ),
        content: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(languageService.getLocalizedText('privacy_message'));
          },
        ),
        actions: [
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(languageService.getLocalizedText('close')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(languageService.getLocalizedText('terms_of_service'));
          },
        ),
        content: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('terms_of_service_message'),
            );
          },
        ),
        actions: [
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(languageService.getLocalizedText('close')),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getLocalizedThemeLabel(
    AppThemeMode themeMode,
    LanguageService languageService,
  ) {
    switch (themeMode) {
      case AppThemeMode.light:
        return languageService.getLocalizedText('theme_light');
      case AppThemeMode.dark:
        return languageService.getLocalizedText('theme_dark');
      case AppThemeMode.system:
        return languageService.getLocalizedText('theme_system');
    }
  }
}
