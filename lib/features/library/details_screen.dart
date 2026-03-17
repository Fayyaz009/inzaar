import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:inzaar/core/inzaar_image.dart';
import 'package:inzaar/core/app_theme.dart';
import 'package:inzaar/features/library/library_item.dart';
import 'package:inzaar/features/reading/reading_screen.dart';

class DetailsScreen extends StatelessWidget {
  final LibraryItem item;
  final String heroTag;

  const DetailsScreen({
    super.key,
    required this.item,
    required this.heroTag,
  });

  Future<void> _orderHardCopy(BuildContext context) async {
    final message = Uri.encodeComponent(
      "Assalamualaikum, I want to order a hard copy of '${item.title}' from the Inzaar app. Please confirm the price and delivery details.",
    );
    final url = Uri.parse('https://wa.me/923008187411?text=$message');

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication) &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('WhatsApp is not installed or unavailable.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedScaler = TextScaler.linear(
      MediaQuery.textScalerOf(context).scale(1).clamp(0.8, 1.15),
    );

    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: clampedScaler),
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                toolbarHeight: 64,
                expandedHeight: MediaQuery.of(context).size.height * 0.52,
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.08),
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -40,
                          right: -20,
                          child: Container(
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.gold.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 110,
                          left: -35,
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        SafeArea(
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 24, 24, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Spacer(),
                                  Hero(
                                    tag: heroTag,
                                    child: Stack(
                                      children: [
                                        // Layered page effect blocks
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          right: -4,
                                          bottom: 4,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: theme.cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.08),
                                                  blurRadius: 12,
                                                  offset: const Offset(4, 4),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 240,
                                          width: 170,
                                          decoration: BoxDecoration(
                                            color: theme.cardColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.16),
                                                blurRadius: 24,
                                                offset: const Offset(0, 12),
                                              ),
                                              // Spine shadow
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.1),
                                                blurRadius: 4,
                                                offset: const Offset(-2, 0),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: InzaarImage(path: item.coverPath,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).animate().fadeIn(duration: 400.ms).scale(
                                      begin: const Offset(0.94, 0.94),
                                      curve: Curves.easeOutBack),
                                  const SizedBox(height: 20),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                48,
                                            child: Text(
                                              item.title,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: theme
                                                  .textTheme.headlineMedium
                                                  ?.copyWith(
                                                color:
                                                    theme.colorScheme.onSurface,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                48,
                                            child: Text(
                                              item.author,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ReadingScreen(item: item)),
                            );
                          },
                          icon: const Icon(Icons.chrome_reader_mode_rounded),
                          label: const Text('Start Reading'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _orderHardCopy(context),
                          icon: const Icon(Icons.local_mall_outlined),
                          label: const Text('Order Hard Copy'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(color: theme.colorScheme.primary),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.description,
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(height: 1.8),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.04),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
