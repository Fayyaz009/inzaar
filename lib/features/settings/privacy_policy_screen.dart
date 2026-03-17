import 'package:flutter/material.dart';

import 'package:inzaar/core/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _InfoCard(
            title: 'Your reading stays on your device',
            body:
                'Inzaar stores reading progress, theme preferences, and font settings locally so the app can restore your experience smoothly.',
          ),
          const _InfoCard(
            title: 'Minimal data usage',
            body:
                'The current app experience is centered on bundled offline content. External actions such as opening WhatsApp or a website are initiated only when you choose them.',
          ),
          const _InfoCard(
            title: 'No unnecessary collection',
            body:
                'This build does not require account creation or personal profile data for normal reading. If future services require additional data, the policy should be updated accordingly.',
          ),
          const SizedBox(height: 16),
          Text(
            'For official legal text and contact details, replace this placeholder policy with Inzaar\'s approved privacy statement before release.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _InfoCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.verified_user_outlined,
                    color: AppTheme.forest),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: theme.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
          ),
        ],
      ),
    );
  }
}
