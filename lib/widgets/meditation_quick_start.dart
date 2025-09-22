import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meditation_provider.dart';
import '../models/meditation_session.dart';
import '../constants/app_colors.dart';
import '../services/language_service.dart';
import 'gradient_card.dart';

class MeditationQuickStart extends StatelessWidget {
  const MeditationQuickStart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MeditationProvider, LanguageService>(
      builder: (context, meditationProvider, languageService, child) {
        final hasMeditatedToday = meditationProvider.hasMeditatedToday();

        return GradientCard(
          gradientColors: hasMeditatedToday
              ? [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ]
              : [
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
          onTap: () => _showMeditationOptions(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasMeditatedToday
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2)
                          : Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasMeditatedToday ? Icons.check : Icons.self_improvement,
                      color: hasMeditatedToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasMeditatedToday
                          ? languageService.getLocalizedText(
                              'meditation_done_today',
                            )
                          : languageService.getLocalizedText(
                              'meditation_quick',
                            ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hasMeditatedToday
                    ? languageService.getLocalizedText(
                        'meditation_done_message',
                      )
                    : languageService.getLocalizedText(
                        'meditation_tap_to_start',
                      ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMeditationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MeditationOptionsBottomSheet(),
    );
  }
}

class MeditationOptionsBottomSheet extends StatefulWidget {
  const MeditationOptionsBottomSheet({super.key});

  @override
  State<MeditationOptionsBottomSheet> createState() =>
      _MeditationOptionsBottomSheetState();
}

class _MeditationOptionsBottomSheetState
    extends State<MeditationOptionsBottomSheet> {
  MeditationType? selectedType;
  Duration selectedDuration = const Duration(minutes: 5);
  DifficultyLevel selectedDifficulty = DifficultyLevel.beginner;

  final List<Duration> durations = [
    const Duration(minutes: 5),
    const Duration(minutes: 10),
    const Duration(minutes: 15),
    const Duration(minutes: 20),
    const Duration(minutes: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('choose_meditation'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildTypeSelector(),
            const SizedBox(height: 24),
            _buildDurationSelector(),
            const SizedBox(height: 24),
            _buildDifficultySelector(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('meditation_type'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MeditationType.values.map((type) {
            final isSelected = selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => selectedType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return Text(
                          _getLocalizedMeditationTypeName(
                            type,
                            languageService,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('duration'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: durations.map((duration) {
            final isSelected = selectedDuration == duration;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedDuration = duration),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '${duration.inMinutes}m',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('difficulty'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: DifficultyLevel.values.map((difficulty) {
            final isSelected = selectedDifficulty == difficulty;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedDifficulty = difficulty),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        _getLocalizedDifficultyLabel(
                          difficulty,
                          languageService,
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(languageService.getLocalizedText('cancel'));
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: selectedType != null ? _startMeditation : null,
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('start_meditation'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _startMeditation() {
    if (selectedType != null) {
      Provider.of<MeditationProvider>(
        context,
        listen: false,
      ).startMeditationSession(
        selectedType!,
        selectedDuration,
        selectedDifficulty,
      );
      Navigator.pop(context);

      // Navigate to meditation screen or show meditation timer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${Provider.of<LanguageService>(context, listen: false).getLocalizedText('meditation_starting_message')}: ${selectedType!.name}',
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  String _getLocalizedMeditationTypeName(
    MeditationType type,
    LanguageService languageService,
  ) {
    switch (type) {
      case MeditationType.breathing:
        return languageService.getLocalizedText('meditation_breathing');
      case MeditationType.mindfulness:
        return languageService.getLocalizedText('meditation_mindfulness');
      case MeditationType.bodyScan:
        return languageService.getLocalizedText('meditation_body_scan');
      case MeditationType.lovingKindness:
        return languageService.getLocalizedText('meditation_loving_kindness');
      case MeditationType.walking:
        return languageService.getLocalizedText('meditation_walking');
      case MeditationType.gratitude:
        return languageService.getLocalizedText('meditation_gratitude');
      case MeditationType.sleep:
        return languageService.getLocalizedText('meditation_sleep');
      case MeditationType.anxiety:
        return languageService.getLocalizedText('meditation_anxiety');
    }
  }

  String _getLocalizedDifficultyLabel(
    DifficultyLevel difficulty,
    LanguageService languageService,
  ) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return languageService.getLocalizedText('difficulty_beginner');
      case DifficultyLevel.intermediate:
        return languageService.getLocalizedText('difficulty_intermediate');
      case DifficultyLevel.advanced:
        return languageService.getLocalizedText('difficulty_advanced');
    }
  }
}
