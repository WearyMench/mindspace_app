import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _isExporting = false;
  String _exportStatus = '';
  final List<String> _selectedDataTypes = ['mood', 'meditation', 'journal'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.background,
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
                      _buildDataSelection(context),
                      const SizedBox(height: 24),
                      _buildExportOptions(context),
                      const SizedBox(height: 24),
                      _buildExportButton(context),
                      if (_exportStatus.isNotEmpty) ...[
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
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return Text(
                    languageService.getLocalizedText('export_data_title'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
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
                languageService.getLocalizedText('export_data_subtitle'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      languageService.getLocalizedText('export_info_title'),
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
                  languageService.getLocalizedText('export_info_description'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                      languageService.getLocalizedText('export_mood_entries'),
                    ),
                    _buildInfoItem(
                      context,
                      languageService.getLocalizedText(
                        'export_meditation_sessions',
                      ),
                    ),
                    _buildInfoItem(
                      context,
                      languageService.getLocalizedText(
                        'export_journal_entries',
                      ),
                    ),
                    _buildInfoItem(
                      context,
                      languageService.getLocalizedText(
                        'export_settings_preferences',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('export_security_note'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDataSelection(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('select_data_to_export'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Column(
                  children: [
                    _buildDataOption(
                      context,
                      languageService.getLocalizedText('mood_data_title'),
                      languageService.getLocalizedText('mood_data_description'),
                      'mood',
                      Icons.mood,
                    ),
                    _buildDataOption(
                      context,
                      languageService.getLocalizedText('meditation_data_title'),
                      languageService.getLocalizedText(
                        'meditation_data_description',
                      ),
                      'meditation',
                      Icons.self_improvement,
                    ),
                    _buildDataOption(
                      context,
                      languageService.getLocalizedText('journal_data_title'),
                      languageService.getLocalizedText(
                        'journal_data_description',
                      ),
                      'journal',
                      Icons.book,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildDataOption(
    BuildContext context,
    String title,
    String subtitle,
    String value,
    IconData icon,
  ) {
    final isSelected = _selectedDataTypes.contains(value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedDataTypes.remove(value);
            } else {
              _selectedDataTypes.add(value);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportOptions(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('export_options_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Column(
                  children: [
                    _buildExportOption(
                      context,
                      languageService.getLocalizedText('json_format_title'),
                      languageService.getLocalizedText(
                        'json_format_description',
                      ),
                      'json',
                      Icons.code,
                    ),
                    _buildExportOption(
                      context,
                      languageService.getLocalizedText('csv_format_title'),
                      languageService.getLocalizedText(
                        'csv_format_description',
                      ),
                      'csv',
                      Icons.table_chart,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildExportOption(
    BuildContext context,
    String title,
    String subtitle,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedDataTypes.isEmpty || _isExporting
            ? null
            : _exportData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isExporting
            ? Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return Row(
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
                      Text(
                        languageService.getLocalizedText('exporting'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              )
            : Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return Text(
                    languageService.getLocalizedText('export_data_button'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildStatusCard(BuildContext context) {
    return GradientCard(
      gradientColors: [
        AppColors.success.withOpacity(0.1),
        AppColors.success.withOpacity(0.05),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _exportStatus,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    if (_selectedDataTypes.isEmpty) return;

    setState(() {
      _isExporting = true;
      _exportStatus = '';
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

      data['exportInfo'] = {
        'timestamp': timestamp,
        'version': '1.0.0',
        'dataTypes': _selectedDataTypes,
      };

      if (_selectedDataTypes.contains('mood')) {
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
      }

      if (_selectedDataTypes.contains('meditation')) {
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
      }

      if (_selectedDataTypes.contains('journal')) {
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
      }

      // Convertir a JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Crear archivo temporal
      final directory = await getTemporaryDirectory();
      final fileName =
          'mindspace_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      // Compartir archivo
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Exportación de datos de MindSpace');

      setState(() {
        _exportStatus = Provider.of<LanguageService>(
          context,
          listen: false,
        ).getLocalizedText('export_success');
      });
    } catch (e) {
      setState(() {
        _exportStatus =
            '${Provider.of<LanguageService>(context, listen: false).getLocalizedText('export_error')}: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }
}
