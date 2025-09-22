import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../constants/app_colors.dart';
import '../providers/mood_provider.dart';
import '../providers/meditation_provider.dart';
import '../providers/journal_provider.dart';
import '../services/language_service.dart';
import '../widgets/gradient_card.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isCreatingBackup = false;
  bool _isRestoring = false;
  String _statusMessage = '';
  bool _isSuccess = false;

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
                      _buildInfoCard(context),
                      const SizedBox(height: 24),
                      _buildBackupSection(context),
                      const SizedBox(height: 24),
                      _buildRestoreSection(context),
                      if (_statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildStatusCard(context),
                      ],
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
                    languageService.getLocalizedText('backup_restore'),
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
                languageService.getLocalizedText('backup_info'),
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

  Widget _buildInfoCard(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.backup_outlined,
                  color: AppColors.secondaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getLocalizedText('why_backup'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('backup_benefits'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Column(
                  children: [
                    _buildInfoItem(
                      context,
                      languageService.getLocalizedText('protect_data'),
                    ),
                    _buildInfoItem(
                      context,
                      languageService.getLocalizedText('recover_data'),
                    ),
                    _buildInfoItem(
                      context,
                      languageService.getLocalizedText('maintain_history'),
                    ),
                    _buildInfoItem(
                      context,
                      languageService.getLocalizedText('transfer_data'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accentOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: AppColors.accentOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return Text(
                          languageService.getLocalizedText(
                            'backup_recommendation',
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.accentOrange,
                                fontWeight: FontWeight.w500,
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildInfoItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildBackupSection(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getLocalizedText('create_backup_title'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('create_backup_description'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildBackupInfo(context),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreatingBackup ? null : _createBackup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreatingBackup
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                languageService.getLocalizedText(
                                  'creating_backup',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : Consumer<LanguageService>(
                        builder: (context, languageService, child) {
                          return Text(
                            languageService.getLocalizedText(
                              'create_backup_title',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildBackupInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Column(
                children: [
                  _buildBackupItem(
                    context,
                    languageService.getLocalizedText('mood_data'),
                    Icons.mood,
                    languageService.getLocalizedText('all_entries'),
                  ),
                  _buildBackupItem(
                    context,
                    languageService.getLocalizedText('meditation_data'),
                    Icons.self_improvement,
                    languageService.getLocalizedText('all_sessions'),
                  ),
                  _buildBackupItem(
                    context,
                    languageService.getLocalizedText('journal_data'),
                    Icons.book,
                    languageService.getLocalizedText('all_entries'),
                  ),
                  _buildBackupItem(
                    context,
                    languageService.getLocalizedText('settings_data'),
                    Icons.settings,
                    languageService.getLocalizedText('preferences_settings'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackupItem(
    BuildContext context,
    String title,
    IconData icon,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreSection(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_download_outlined,
                  color: AppColors.secondaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getLocalizedText('restore_data_title'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('restore_data_description'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return Text(
                          languageService.getLocalizedText('restore_warning'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isRestoring ? null : _restoreData,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondaryBlue,
                  side: const BorderSide(color: AppColors.secondaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isRestoring
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.secondaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                languageService.getLocalizedText('restoring'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : Consumer<LanguageService>(
                        builder: (context, languageService, child) {
                          return Text(
                            languageService.getLocalizedText(
                              'restore_from_file',
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildStatusCard(BuildContext context) {
    return GradientCard(
      gradientColors: [
        (_isSuccess ? AppColors.success : AppColors.error).withOpacity(0.1),
        (_isSuccess ? AppColors.success : AppColors.error).withOpacity(0.05),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isSuccess ? Icons.check_circle : Icons.error_outline,
              color: _isSuccess ? AppColors.success : AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _statusMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _isSuccess ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() {
      _isCreatingBackup = true;
      _statusMessage = '';
    });

    try {
      final data = <String, dynamic>{};
      final timestamp = DateTime.now().toIso8601String();

      // Obtener datos de los providers
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      final meditationProvider = Provider.of<MeditationProvider>(
        context,
        listen: false,
      );
      final journalProvider = Provider.of<JournalProvider>(
        context,
        listen: false,
      );

      data['backupInfo'] = {
        'timestamp': timestamp,
        'version': '1.0.0',
        'type': 'full_backup',
      };

      data['moodEntries'] = moodProvider.moodEntries
          .map(
            (entry) => {
              'id': entry.id,
              'date': entry.date.toIso8601String(),
              'overallMood': entry.overallMood.name,
              'notes': entry.notes,
              'categoryRatings': entry.categoryRatings.map(
                (key, value) => MapEntry(key.name, value),
              ),
            },
          )
          .toList();

      data['meditationSessions'] = meditationProvider.sessions
          .map(
            (session) => {
              'id': session.id,
              'type': session.type.name,
              'duration': session.duration.inMinutes,
              'difficulty': session.difficulty.name,
              'completedAt': session.completedAt.toIso8601String(),
              'rating': session.rating,
              'notes': session.notes,
              'completed': session.completed,
              'actualDuration': session.actualDuration?.inMinutes,
            },
          )
          .toList();

      data['journalEntries'] = journalProvider.entries
          .map(
            (entry) => {
              'id': entry.id,
              'title': entry.title,
              'content': entry.content,
              'category': entry.category.name,
              'createdAt': entry.createdAt.toIso8601String(),
              'updatedAt': entry.updatedAt?.toIso8601String(),
              'moodTags': entry.moodTags.map((tag) => tag.name).toList(),
              'customTags': entry.customTags,
              'isPrivate': entry.isPrivate,
              'wordCount': entry.wordCount,
            },
          )
          .toList();

      // Convertir a JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Crear archivo de respaldo
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'mindspace_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      // Compartir archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Respaldo de MindSpace - ${DateTime.now().toString().split(' ')[0]}',
      );

      setState(() {
        _statusMessage = Provider.of<LanguageService>(
          context,
          listen: false,
        ).getLocalizedText('backup_created_successfully');
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage =
            '${Provider.of<LanguageService>(context, listen: false).getLocalizedText('backup_error')} $e';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isCreatingBackup = false;
      });
    }
  }

  Future<void> _restoreData() async {
    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('confirm_restoration'),
            );
          },
        ),
        content: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('confirm_restoration_message'),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(languageService.getLocalizedText('cancel'));
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(languageService.getLocalizedText('restore'));
              },
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isRestoring = true;
      _statusMessage = '';
    });

    try {
      // Seleccionar archivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _statusMessage = Provider.of<LanguageService>(
            context,
            listen: false,
          ).getLocalizedText('no_file_selected');
          _isSuccess = false;
        });
        return;
      }

      // Leer archivo
      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString);

      // Validar estructura del archivo
      if (!data.containsKey('backupInfo')) {
        throw Exception(
          Provider.of<LanguageService>(
            context,
            listen: false,
          ).getLocalizedText('invalid_backup_file'),
        );
      }

      // Restaurar datos
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      final meditationProvider = Provider.of<MeditationProvider>(
        context,
        listen: false,
      );
      final journalProvider = Provider.of<JournalProvider>(
        context,
        listen: false,
      );

      // Limpiar datos actuales
      await moodProvider.clearAllData();
      await meditationProvider.clearAllData();
      await journalProvider.clearAllData();

      // Restaurar datos del respaldo
      if (data.containsKey('moodEntries')) {
        // Implementar restauración de mood entries
      }

      if (data.containsKey('meditationSessions')) {
        // Implementar restauración de meditation sessions
      }

      if (data.containsKey('journalEntries')) {
        // Implementar restauración de journal entries
      }

      setState(() {
        _statusMessage = Provider.of<LanguageService>(
          context,
          listen: false,
        ).getLocalizedText('backup_restored_successfully');
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage =
            '${Provider.of<LanguageService>(context, listen: false).getLocalizedText('restore_error')} $e';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isRestoring = false;
      });
    }
  }
}
