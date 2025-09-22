import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';
import '../services/language_service.dart';
import 'gradient_card.dart';

class JournalQuickEntry extends StatelessWidget {
  const JournalQuickEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<JournalProvider, LanguageService>(
      builder: (context, journalProvider, languageService, child) {
        final hasWrittenToday = journalProvider.hasWrittenToday();

        return GradientCard(
          gradientColors: hasWrittenToday
              ? [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ]
              : [
                  Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                  Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
                ],
          onTap: () => _showJournalOptions(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasWrittenToday
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2)
                          : Theme.of(
                              context,
                            ).colorScheme.tertiary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasWrittenToday ? Icons.check : Icons.book,
                      color: hasWrittenToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasWrittenToday
                          ? languageService.getLocalizedText(
                              'journal_written_today',
                            )
                          : languageService.getLocalizedText('journal_write'),
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
                hasWrittenToday
                    ? languageService.getLocalizedText(
                        'journal_written_message',
                      )
                    : languageService.getLocalizedText('journal_tap_to_write'),
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

  void _showJournalOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const JournalOptionsBottomSheet(),
    );
  }
}

class JournalOptionsBottomSheet extends StatefulWidget {
  const JournalOptionsBottomSheet({super.key});

  @override
  State<JournalOptionsBottomSheet> createState() =>
      _JournalOptionsBottomSheetState();
}

class _JournalOptionsBottomSheetState extends State<JournalOptionsBottomSheet> {
  JournalCategory selectedCategory = JournalCategory.daily;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final List<MoodTag> selectedMoodTags = [];
  final List<String> customTags = [];

  @override
  void initState() {
    super.initState();
    _loadWritingPrompts();
  }

  void _loadWritingPrompts() {
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );
    final prompts = Provider.of<JournalProvider>(
      context,
      listen: false,
    ).getWritingPrompts(languageService);
    if (prompts.isNotEmpty) {
      contentController.text = prompts.first;
    }
  }

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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        languageService.getLocalizedText('new_entry'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 24),
                      _buildCategorySelector(languageService),
                      const SizedBox(height: 16),
                      _buildTitleInput(languageService),
                      const SizedBox(height: 16),
                      _buildContentInput(languageService),
                      const SizedBox(height: 16),
                      _buildMoodTagsSelector(languageService),
                      const SizedBox(height: 24),
                      _buildActionButtons(languageService),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(LanguageService languageService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageService.getLocalizedText('category'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: JournalCategory.values.map((category) {
            final isSelected = selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.tertiary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.tertiary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getLocalizedCategoryName(category, languageService),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
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

  Widget _buildTitleInput(LanguageService languageService) {
    return TextField(
      controller: titleController,
      decoration: InputDecoration(
        labelText: languageService.getLocalizedText('title_optional'),
        hintText: languageService.getLocalizedText('title_hint_journal'),
      ),
    );
  }

  Widget _buildContentInput(LanguageService languageService) {
    return TextField(
      controller: contentController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: languageService.getLocalizedText('content'),
        hintText: languageService.getLocalizedText('content_hint_journal'),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildMoodTagsSelector(LanguageService languageService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageService.getLocalizedText('mood_optional'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MoodTag.values.map((tag) {
            final isSelected = selectedMoodTags.contains(tag);
            return GestureDetector(
              onTap: () => setState(() {
                if (isSelected) {
                  selectedMoodTags.remove(tag);
                } else {
                  selectedMoodTags.add(tag);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.tertiary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.tertiary
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tag.icon,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getLocalizedMoodTagLabel(tag, languageService),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
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

  Widget _buildActionButtons(LanguageService languageService) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageService.getLocalizedText('cancel')),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveJournalEntry,
            child: Text(languageService.getLocalizedText('save')),
          ),
        ),
      ],
    );
  }

  void _saveJournalEntry() {
    if (contentController.text.trim().isNotEmpty) {
      final journalEntry = JournalEntry(
        title: titleController.text.trim().isEmpty
            ? 'Entrada del ${DateTime.now().day}/${DateTime.now().month}'
            : titleController.text.trim(),
        content: contentController.text.trim(),
        category: selectedCategory,
        createdAt: DateTime.now(),
        moodTags: selectedMoodTags,
        customTags: customTags,
      );

      Provider.of<JournalProvider>(
        context,
        listen: false,
      ).addJournalEntry(journalEntry);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${Provider.of<LanguageService>(context, listen: false).getLocalizedText('entry_saved_message')} ${selectedCategory.name}',
          ),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  String _getLocalizedCategoryName(
    JournalCategory category,
    LanguageService languageService,
  ) {
    switch (category) {
      case JournalCategory.daily:
        return languageService.getLocalizedText('category_daily');
      case JournalCategory.gratitude:
        return languageService.getLocalizedText('category_gratitude');
      case JournalCategory.reflection:
        return languageService.getLocalizedText('category_reflection');
      case JournalCategory.goals:
        return languageService.getLocalizedText('category_goals');
      case JournalCategory.dreams:
        return languageService.getLocalizedText('category_dreams');
      case JournalCategory.challenges:
        return languageService.getLocalizedText('category_challenges');
      case JournalCategory.memories:
        return languageService.getLocalizedText('category_memories');
      case JournalCategory.ideas:
        return languageService.getLocalizedText('category_ideas');
    }
  }

  String _getLocalizedMoodTagLabel(
    MoodTag tag,
    LanguageService languageService,
  ) {
    switch (tag) {
      case MoodTag.happy:
        return languageService.getLocalizedText('mood_happy');
      case MoodTag.sad:
        return languageService.getLocalizedText('mood_sad');
      case MoodTag.excited:
        return languageService.getLocalizedText('mood_excited');
      case MoodTag.anxious:
        return languageService.getLocalizedText('mood_anxious');
      case MoodTag.calm:
        return languageService.getLocalizedText('mood_calm');
      case MoodTag.angry:
        return languageService.getLocalizedText('mood_angry');
      case MoodTag.grateful:
        return languageService.getLocalizedText('mood_grateful');
      case MoodTag.confused:
        return languageService.getLocalizedText('mood_confused');
      case MoodTag.hopeful:
        return languageService.getLocalizedText('mood_hopeful');
      case MoodTag.nostalgic:
        return languageService.getLocalizedText('mood_nostalgic');
    }
  }
}
