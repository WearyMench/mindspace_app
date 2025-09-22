import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../models/mood_entry.dart';
import '../constants/app_colors.dart';
import '../services/language_service.dart';
import 'gradient_card.dart';

class MoodQuickEntry extends StatelessWidget {
  const MoodQuickEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MoodProvider, LanguageService>(
      builder: (context, moodProvider, languageService, child) {
        final hasLoggedToday = moodProvider.hasLoggedMoodToday();

        return GradientCard(
          gradientColors: hasLoggedToday
              ? [
                  AppColors.success.withOpacity(0.1),
                  AppColors.success.withOpacity(0.05),
                ]
              : [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
          onTap: () => _showMoodSelector(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasLoggedToday
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2)
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasLoggedToday ? Icons.check : Icons.mood,
                      color: hasLoggedToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasLoggedToday
                          ? languageService.getLocalizedText(
                              'mood_logged_today',
                            )
                          : languageService.getLocalizedText('mood_today'),
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
                hasLoggedToday
                    ? languageService.getLocalizedText('mood_logged_message')
                    : languageService.getLocalizedText('mood_tap_to_log'),
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

  void _showMoodSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MoodSelectorBottomSheet(),
    );
  }
}

class MoodSelectorBottomSheet extends StatefulWidget {
  const MoodSelectorBottomSheet({super.key});

  @override
  State<MoodSelectorBottomSheet> createState() =>
      _MoodSelectorBottomSheetState();
}

class _MoodSelectorBottomSheetState extends State<MoodSelectorBottomSheet> {
  MoodLevel? selectedMood;
  final Map<MoodCategory, int> categoryRatings = {};

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
        child: SingleChildScrollView(
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
                    languageService.getLocalizedText('how_do_you_feel'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildMoodSelector(),
              const SizedBox(height: 20),
              if (selectedMood != null) _buildCategoryRatings(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: MoodLevel.values.length,
      itemBuilder: (context, index) {
        final mood = MoodLevel.values[index];
        final isSelected = selectedMood == mood;

        return GestureDetector(
          onTap: () => setState(() => selectedMood = mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  mood.icon,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Text(
                      _getLocalizedMoodLabel(mood, languageService),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryRatings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('additional_details'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ...MoodCategory.values.map(
          (category) => _buildCategoryRating(category),
        ),
      ],
    );
  }

  Widget _buildCategoryRating(MoodCategory category) {
    final rating = categoryRatings[category] ?? 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  _getLocalizedMoodCategoryLabel(category, languageService),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              final isSelected = index < rating;
              return GestureDetector(
                onTap: () => setState(() {
                  categoryRatings[category] = index + 1;
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: isSelected
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                    size: 20,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
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
            onPressed: selectedMood != null ? _saveMood : null,
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(languageService.getLocalizedText('save'));
              },
            ),
          ),
        ),
      ],
    );
  }

  void _saveMood() {
    if (selectedMood != null) {
      final moodEntry = MoodEntry(
        date: DateTime.now(),
        overallMood: selectedMood!,
        categoryRatings: categoryRatings,
      );

      Provider.of<MoodProvider>(context, listen: false).addMoodEntry(moodEntry);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${Provider.of<LanguageService>(context, listen: false).getLocalizedText('mood_saved_message')}: ${selectedMood!.label}',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  String _getLocalizedMoodLabel(
    MoodLevel mood,
    LanguageService languageService,
  ) {
    switch (mood) {
      case MoodLevel.excellent:
        return languageService.getLocalizedText('mood_excellent');
      case MoodLevel.good:
        return languageService.getLocalizedText('mood_good');
      case MoodLevel.neutral:
        return languageService.getLocalizedText('mood_neutral');
      case MoodLevel.bad:
        return languageService.getLocalizedText('mood_bad');
      case MoodLevel.terrible:
        return languageService.getLocalizedText('mood_terrible');
    }
  }

  String _getLocalizedMoodCategoryLabel(
    MoodCategory category,
    LanguageService languageService,
  ) {
    switch (category) {
      case MoodCategory.energy:
        return languageService.getLocalizedText('mood_energy');
      case MoodCategory.stress:
        return languageService.getLocalizedText('mood_stress');
      case MoodCategory.happiness:
        return languageService.getLocalizedText('mood_happiness');
      case MoodCategory.anxiety:
        return languageService.getLocalizedText('mood_anxiety');
      case MoodCategory.motivation:
        return languageService.getLocalizedText('mood_motivation');
      case MoodCategory.sleep:
        return languageService.getLocalizedText('mood_sleep');
      case MoodCategory.social:
        return languageService.getLocalizedText('mood_social');
      case MoodCategory.work:
        return languageService.getLocalizedText('mood_work');
    }
  }
}
