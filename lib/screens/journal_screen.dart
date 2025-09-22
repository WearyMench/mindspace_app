import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';
import '../services/language_service.dart';
import '../widgets/gradient_card.dart';
import '../widgets/journal_quick_entry.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String _searchQuery = '';
  JournalCategory? _selectedCategory;
  int _selectedView = 0; // 0: Lista, 1: Grid

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
              _buildSearchAndFilters(context),
              Expanded(child: _buildJournalContent(context)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showJournalEditor(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return Text(
                          languageService.getLocalizedText('journal'),
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                    const SizedBox(height: 8),
                    Consumer<LanguageService>(
                          builder: (context, languageService, child) {
                            return Text(
                              languageService.getLocalizedText(
                                'journal_subtitle',
                              ),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onBackground.withOpacity(0.7),
                                  ),
                            );
                          },
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: -0.2),
                  ],
                ),
              ),
              _buildViewToggle(context),
            ],
          ),
          const SizedBox(height: 16),
          const JournalQuickEntry()
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context,
            icon: Icons.list,
            isSelected: _selectedView == 0,
            onTap: () => setState(() => _selectedView = 0),
          ),
          _buildToggleButton(
            context,
            icon: Icons.grid_view,
            isSelected: _selectedView == 1,
            onTap: () => setState(() => _selectedView = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSearchBar(context),
          const SizedBox(height: 16),
          _buildCategoryFilter(context),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildSearchBar(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: languageService.getLocalizedText('search_hint'),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () => setState(() => _searchQuery = ''),
                    icon: const Icon(Icons.clear),
                  )
                : null,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return _buildCategoryChip(
                context,
                label: languageService.getLocalizedText('all'),
                isSelected: _selectedCategory == null,
                onTap: () => setState(() => _selectedCategory = null),
              );
            },
          ),
          const SizedBox(width: 8),
          ...JournalCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Consumer<LanguageService>(
                builder: (context, languageService, child) {
                  return _buildCategoryChip(
                    context,
                    label: _getLocalizedCategoryName(category, languageService),
                    icon: category.icon,
                    isSelected: _selectedCategory == category,
                    onTap: () => setState(() => _selectedCategory = category),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalContent(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        List<JournalEntry> entries = journalProvider.entries;

        // Aplicar filtros
        if (_selectedCategory != null) {
          entries = entries
              .where((entry) => entry.category == _selectedCategory)
              .toList();
        }

        if (_searchQuery.isNotEmpty) {
          entries = journalProvider.searchEntries(_searchQuery);
        }

        // Ordenar por fecha (más recientes primero)
        entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (entries.isEmpty) {
          return _buildEmptyState(context);
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: _selectedView == 0
              ? _buildListView(context, entries)
              : _buildGridView(context, entries),
        ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.2);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: GradientCard(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                const SizedBox(height: 24),
                Consumer<LanguageService>(
                  builder: (context, languageService, child) {
                    return Column(
                      children: [
                        Text(
                          _searchQuery.isNotEmpty
                              ? languageService.getLocalizedText(
                                  'no_entries_found',
                                )
                              : languageService.getLocalizedText(
                                  'journal_empty',
                                ),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? languageService.getLocalizedText(
                                  'try_other_terms',
                                )
                              : languageService.getLocalizedText(
                                  'start_writing',
                                ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showJournalEditor(context),
                  icon: const Icon(Icons.add),
                  label: Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        languageService.getLocalizedText('write_entry_button'),
                      );
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildListView(BuildContext context, List<JournalEntry> entries) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildJournalEntryCard(context, entry);
      },
    );
  }

  Widget _buildGridView(BuildContext context, List<JournalEntry> entries) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildJournalEntryGridCard(context, entry);
      },
    );
  }

  Widget _buildJournalEntryCard(BuildContext context, JournalEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GradientCard(
        onTap: () => _showJournalDetail(context, entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      entry.category.icon,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onBackground,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Consumer<LanguageService>(
                          builder: (context, languageService, child) {
                            return Text(
                              _getLocalizedCategoryName(
                                entry.category,
                                languageService,
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onBackground.withOpacity(0.7),
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${entry.createdAt.day}/${entry.createdAt.month}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.preview,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (entry.moodTags.isNotEmpty) ...[
                    ...entry.moodTags
                        .take(3)
                        .map(
                          (tag) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              tag.icon,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      return Text(
                        '${entry.wordCount} ${languageService.getLocalizedText('words')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalEntryGridCard(BuildContext context, JournalEntry entry) {
    return GradientCard(
      onTap: () => _showJournalDetail(context, entry),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  entry.category.icon,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Spacer(),
                Text(
                  '${entry.createdAt.day}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              entry.preview,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (entry.moodTags.isNotEmpty)
              Row(
                children: entry.moodTags
                    .take(3)
                    .map(
                      (tag) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          tag.icon,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showJournalEditor(BuildContext context, {JournalEntry? entry}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEditorScreen(
          entry: entry,
          onSave: (newEntry) {
            if (entry != null) {
              Provider.of<JournalProvider>(
                context,
                listen: false,
              ).updateJournalEntry(newEntry);
            } else {
              Provider.of<JournalProvider>(
                context,
                listen: false,
              ).addJournalEntry(newEntry);
            }
          },
        ),
      ),
    );
  }

  void _showJournalDetail(BuildContext context, JournalEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalDetailScreen(
          entry: entry,
          onEdit: () => _showJournalEditor(context, entry: entry),
          onDelete: () {
            Provider.of<JournalProvider>(
              context,
              listen: false,
            ).deleteJournalEntry(entry.id);
            Navigator.pop(context);
          },
        ),
      ),
    );
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

class JournalEditorScreen extends StatefulWidget {
  final JournalEntry? entry;
  final Function(JournalEntry) onSave;

  const JournalEditorScreen({super.key, this.entry, required this.onSave});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  JournalCategory _selectedCategory = JournalCategory.daily;
  List<MoodTag> _selectedMoodTags = [];
  List<String> _customTags = [];
  bool _isPrivate = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(
      text: widget.entry?.content ?? '',
    );

    if (widget.entry != null) {
      _selectedCategory = widget.entry!.category;
      _selectedMoodTags = List.from(widget.entry!.moodTags);
      _customTags = List.from(widget.entry!.customTags);
      _isPrivate = widget.entry!.isPrivate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              widget.entry != null
                  ? languageService.getLocalizedText('edit_entry')
                  : languageService.getLocalizedText('new_entry'),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(languageService.getLocalizedText('save'));
              },
            ),
          ),
        ],
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategorySelector(),
              const SizedBox(height: 20),
              _buildTitleInput(),
              const SizedBox(height: 20),
              _buildContentInput(),
              const SizedBox(height: 20),
              _buildMoodTagsSelector(),
              const SizedBox(height: 20),
              _buildPrivacyToggle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('category'),
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
          children: JournalCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentOrange.withOpacity(0.1)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentOrange
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
                    Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return Text(
                          _getLocalizedCategoryName(category, languageService),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isSelected
                                    ? AppColors.accentOrange
                                    : AppColors.textPrimary,
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

  Widget _buildTitleInput() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: Provider.of<LanguageService>(
          context,
          listen: false,
        ).getLocalizedText('title'),
        hintText: Provider.of<LanguageService>(
          context,
          listen: false,
        ).getLocalizedText('title_hint'),
      ),
    );
  }

  Widget _buildContentInput() {
    return TextField(
      controller: _contentController,
      maxLines: 10,
      decoration: InputDecoration(
        labelText: Provider.of<LanguageService>(
          context,
          listen: false,
        ).getLocalizedText('content'),
        hintText: Provider.of<LanguageService>(
          context,
          listen: false,
        ).getLocalizedText('content_hint'),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildMoodTagsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('mood_tags'),
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
          children: MoodTag.values.map((tag) {
            final isSelected = _selectedMoodTags.contains(tag);
            return GestureDetector(
              onTap: () => setState(() {
                if (isSelected) {
                  _selectedMoodTags.remove(tag);
                } else {
                  _selectedMoodTags.add(tag);
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
                    Consumer<LanguageService>(
                      builder: (context, languageService, child) {
                        return Text(
                          _getLocalizedMoodTagLabel(tag, languageService),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.tertiary
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

  Widget _buildPrivacyToggle() {
    return Row(
      children: [
        Switch(
          value: _isPrivate,
          onChanged: (value) => setState(() => _isPrivate = value),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Text(
                languageService.getLocalizedText('private_entry'),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
              );
            },
          ),
        ),
      ],
    );
  }

  void _saveEntry() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Text(languageService.getLocalizedText('content_required'));
            },
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final entry = JournalEntry(
      id: widget.entry?.id,
      title: _titleController.text.trim().isEmpty
          ? '${Provider.of<LanguageService>(context, listen: false).getLocalizedText('entry_default_title')} ${DateTime.now().day}/${DateTime.now().month}'
          : _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
      createdAt: widget.entry?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      moodTags: _selectedMoodTags,
      customTags: _customTags,
      isPrivate: _isPrivate,
    );

    widget.onSave(entry);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              widget.entry != null
                  ? languageService.getLocalizedText('entry_updated')
                  : languageService.getLocalizedText('entry_saved'),
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
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

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const JournalDetailScreen({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
        actions: [
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
          IconButton(
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildContent(context),
              const SizedBox(height: 20),
              if (entry.moodTags.isNotEmpty) _buildMoodTags(context),
              const SizedBox(height: 20),
              _buildMetadata(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  entry.category.icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<LanguageService>(
                        builder: (context, languageService, child) {
                          return Text(
                            _getLocalizedCategoryName(
                              entry.category,
                              languageService,
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.isPrivate)
                  Icon(Icons.lock, color: AppColors.textTertiary, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          entry.content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildMoodTags(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('mood_tags'),
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
              children: entry.moodTags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
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
                          Consumer<LanguageService>(
                            builder: (context, languageService, child) {
                              return Text(
                                _getLocalizedMoodTagLabel(tag, languageService),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(
                  languageService.getLocalizedText('information'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildMetadataItem(
              context,
              Provider.of<LanguageService>(
                context,
                listen: false,
              ).getLocalizedText('word_count'),
              '${entry.wordCount}',
            ),
            _buildMetadataItem(
              context,
              Provider.of<LanguageService>(
                context,
                listen: false,
              ).getLocalizedText('reading_time'),
              '${entry.readingTime.inMinutes} min',
            ),
            if (entry.updatedAt != null)
              _buildMetadataItem(
                context,
                Provider.of<LanguageService>(
                  context,
                  listen: false,
                ).getLocalizedText('last_updated'),
                '${entry.updatedAt!.day}/${entry.updatedAt!.month}/${entry.updatedAt!.year}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(languageService.getLocalizedText('delete_entry_title'));
          },
        ),
        content: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(
              languageService.getLocalizedText('delete_entry_message'),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(languageService.getLocalizedText('cancel'));
              },
            ),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
            child: Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Text(languageService.getLocalizedText('delete_entry'));
              },
            ),
          ),
        ],
      ),
    );
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
