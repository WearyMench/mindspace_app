import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';

class ThemePreview extends StatelessWidget {
  const ThemePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeService, LanguageService>(
      builder: (context, themeService, languageService, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.palette,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    languageService.getLocalizedText('theme_preview'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Preview de colores
              Row(
                children: [
                  _buildColorPreview(
                    context,
                    languageService.getLocalizedText('primary_color'),
                    Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildColorPreview(
                    context,
                    languageService.getLocalizedText('secondary_color'),
                    Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  _buildColorPreview(
                    context,
                    languageService.getLocalizedText('surface_color'),
                    Theme.of(context).colorScheme.surface,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Preview de texto
              Text(
                languageService.getLocalizedText('sample_text'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                languageService.getLocalizedText('sample_text_description'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              // Preview de botón
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    languageService.getLocalizedText('sample_button'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorPreview(BuildContext context, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
