import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:inzaar/core/app_theme.dart';
import 'package:inzaar/features/settings/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.format_size_rounded,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        const Text('Font Size',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                        const Spacer(),
                        Text('${(state.appFontScale * 100).round()}%',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: theme.colorScheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Scales all text across the entire application for comfortable accessibility.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('A', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Slider(
                            value: state.appFontScale,
                            min: 0.8,
                            max: 1.6,
                            divisions: 8,
                            activeColor: theme.colorScheme.primary,
                            onChanged: (value) => context
                                .read<SettingsBloc>()
                                .add(ChangeAppFontScale(value)),
                          ),
                        ),
                        const Text('A',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'یہ پیش نظارہ آپ کے موجودہ فونٹ سائز اور پڑھنے کے انداز کی عکاسی کرتا ہے۔',
                        style: AppTheme.urduStyle(
                          fontSize: 22 * state.appFontScale,
                          fontFamily: state.urduFontFamily,
                        ).copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Theme', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ThemeCard(
                      color: Colors.white,
                      textColor: Colors.black,
                      label: 'Light',
                      isSelected: state.themeMode == 'light',
                      onTap: () => context
                          .read<SettingsBloc>()
                          .add(const ChangeTheme('light')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ThemeCard(
                      color: const Color(0xFFF6E9CB),
                      textColor: const Color(0xFF6C4B2A),
                      label: 'Sepia',
                      isSelected: state.themeMode == 'sepia',
                      onTap: () => context
                          .read<SettingsBloc>()
                          .add(const ChangeTheme('sepia')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ThemeCard(
                      color: const Color(0xFF15211D),
                      textColor: Colors.white,
                      label: 'Dark',
                      isSelected: state.themeMode == 'dark',
                      onTap: () => context
                          .read<SettingsBloc>()
                          .add(const ChangeTheme('dark')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.color,
    required this.textColor,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.03),
              blurRadius: isSelected ? 18 : 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? theme.colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : textColor.withValues(alpha: 0.25),
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(label,
                style: theme.textTheme.labelLarge?.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}
