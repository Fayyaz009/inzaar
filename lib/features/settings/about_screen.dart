import 'package:flutter/material.dart';

import 'package:inzaar/core/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About Inzaar')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A), // Charcoal
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.auto_stories_rounded,
                      color: Colors.white, size: 34),
                ),
                const SizedBox(height: 20),
                Text(
                  'Inzaar',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'A focused reading space for books, magazines, and articles rooted in Islamic thought.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _AboutTile(
            title: 'Mission',
            subtitle:
                'Present meaningful writings with a calm, premium, distraction-light reading experience.',
          ),
          const _AboutTile(
            title: 'Offline-first',
            subtitle:
                'Core reading content is bundled so users can study without depending on a live connection.',
          ),
          const _AboutTile(
            title: 'Version',
            subtitle: '1.0.0',
          ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AboutTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: AppTheme.forest)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}
