import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:inzaar/features/home/recent_reading_bloc.dart';
import 'package:inzaar/features/library/library_item.dart';
import 'package:inzaar/features/library/library_bloc.dart';
import 'package:inzaar/features/library/details_screen.dart';
import 'package:inzaar/features/reading/reading_screen.dart';

import 'package:inzaar/features/home/quote_repository.dart';
import 'package:inzaar/core/streak_helper.dart';
import 'package:inzaar/core/inzaar_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state is LibraryLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }
        if (state is LibraryError) {
          return Center(child: Text(state.message));
        }
        if (state is! LibraryLoaded) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<RecentReadingBloc, RecentReadingState>(
          builder: (context, recentState) {
            LibraryItem? recentItem;
            if (recentState.itemId != null) {
              for (final item in state.items) {
                if (item.id == recentState.itemId) {
                  recentItem = item;
                  break;
                }
              }
            }

            final featured = recentItem ??
                (state.books.isNotEmpty
                    ? state.books.first
                    : (state.magazines.isNotEmpty
                        ? state.magazines.first
                        : null));

            final clampedScaler = TextScaler.linear(
              MediaQuery.textScalerOf(context).scale(1).clamp(0.8, 1.15),
            );

            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: clampedScaler),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (featured != null)
                          _FeaturedHero(
                            item: featured,
                            isResumeCard: recentItem != null,
                            progress: recentState.progress,
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 80.ms)
                              .slideY(begin: 0.06),
                        if (featured != null) const SizedBox(height: 26),
                        const _SectionHeader(
                          title: 'Featured Books',
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 150.ms)
                            .slideY(begin: 0.04),
                        const SizedBox(height: 10),
                        _HorizontalShelf(
                            items: state.books, sectionKey: 'books'),
                        const SizedBox(height: 10),
                        const _DailyInspirationCard()
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 200.ms)
                            .slideY(begin: 0.04),
                        const SizedBox(height: 32),
                        const _SectionHeader(
                          title: 'Latest Magazines',
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 250.ms)
                            .slideY(begin: 0.04),
                        const SizedBox(height: 16),
                        _HorizontalShelf(
                          items: state.magazines,
                          sectionKey: 'magazines',
                        ),
                        const SizedBox(height: 30),
                        const _SectionHeader(
                          title: 'Featured Articles',
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 300.ms)
                            .slideY(begin: 0.04),
                        const SizedBox(height: 16),
                        _HorizontalShelf(
                          items: state.articles,
                          sectionKey: 'articles',
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FeaturedHero extends StatelessWidget {
  final LibraryItem item;
  final bool isResumeCard;
  final double progress;

  const _FeaturedHero({
    required this.item,
    required this.isResumeCard,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heroTag = 'home_featured_${item.id}';
    final progressPercent = (progress * 100).round().clamp(0, 100);

    Future<void> openTarget() async {
      if (isResumeCard) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReadingScreen(item: item)),
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(item: item, heroTag: heroTag),
          ),
        );
      }
      if (context.mounted) {
        context.read<RecentReadingBloc>().add(const LoadRecentReading());
      }
    }

    return GestureDetector(
      onTap: openTarget,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.brightness == Brightness.light ||
                    theme.brightness == Brightness.dark
                ? [const Color(0xFF121212), const Color(0xFF1C1C1C)] // Pure Ink
                : [
                    const Color(0xFF3B2A18),
                    const Color(0xFF523D26)
                  ], // Premium Sepia
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: (theme.brightness == Brightness.dark
                      ? Colors.black
                      : theme.colorScheme.primary)
                  .withValues(alpha: 0.18),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PillLabel(
                    label: isResumeCard ? 'Continue Reading' : _typeLabel(item),
                    background: Colors.white.withValues(alpha: 0.12),
                    foreground: Colors.white,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _displayTitle(item),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _displaySubtitle(item),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isResumeCard) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress <= 0 ? 0.02 : progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$progressPercent% completed',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.76),
                      ),
                    ),
                  ] else ...[
                    Text(
                      item.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        height: 1.6,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  FittedBox(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isResumeCard ? 'Continue Reading' : 'View Details',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            _CoverFrame(
              item: item,
              heroTag: heroTag,
              width: 135,
              height: 195,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(color: accent),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _HorizontalShelf extends StatelessWidget {
  final List<LibraryItem> items;
  final String sectionKey;

  const _HorizontalShelf({required this.items, required this.sectionKey});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Content will appear here soon.'),
      );
    }

    final theme = Theme.of(context);
    // Dynamic sizing based on screen width to prevent bottom overflow
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.48).clamp(170.0, 220.0);
    // Taller height for larger covers
    final shelfHeight = cardWidth * 1.82;

    return SizedBox(
      height: shelfHeight,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final item = items[index];
          final heroTag = 'home_${sectionKey}_${item.id}_$index';

          Future<void> openDetails() async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailsScreen(item: item, heroTag: heroTag),
              ),
            );
            if (context.mounted) {
              context.read<RecentReadingBloc>().add(const LoadRecentReading());
            }
          }

          return GestureDetector(
            onTap: openDetails,
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: _CoverFrame(
                        item: item,
                        heroTag: heroTag,
                        width: cardWidth * 0.85,
                        height: cardWidth * 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _displayTitle(item),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _displaySubtitle(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.85),
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: 200 + (70 * index)))
              .fadeIn(duration: 280.ms)
              .slideX(begin: 0.06);
        },
      ),
    );
  }
}

class _PillLabel extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _PillLabel({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

class _CoverFrame extends StatelessWidget {
  final LibraryItem item;
  final String heroTag;
  final double width;
  final double height;

  const _CoverFrame({
    required this.item,
    required this.heroTag,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: InzaarImage(
            path: item.coverPath,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}

String _typeLabel(LibraryItem item) {
  switch (item.type) {
    case ItemType.book:
      return 'Book';
    case ItemType.magazine:
      return 'Magazine';
    case ItemType.article:
      return 'Article';
  }
}

String _displayTitle(LibraryItem item) {
  if (item.type == ItemType.magazine) {
    final title = item.title.replaceFirst('Inzaar Magazine - ', '').trim();
    return title.isEmpty ? 'Inzaar Magazine' : title;
  }
  return item.title;
}

String _displaySubtitle(LibraryItem item) {
  if (item.type == ItemType.magazine) {
    return 'Inzaar Editorial Board';
  }
  if (item.type == ItemType.article) {
    return item.author;
  }
  return item.author;
}

class _DailyInspirationCard extends StatefulWidget {
  const _DailyInspirationCard();

  @override
  State<_DailyInspirationCard> createState() => _DailyInspirationCardState();
}

class _DailyInspirationCardState extends State<_DailyInspirationCard> {
  int _streak = 0;
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak = await StreakHelper.updateAndGetStreak();
    if (mounted) {
      setState(() {
        _streak = streak;
      });
    }
  }

  Future<void> _shareAsImage() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      // Small delay to ensure the UI has updated (isSharing state)
      // and the RepaintBoundary is ready for capture.
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw 'Could not find the inspiration card to capture.';
      }

      // Check if the layer is ready for capture
      if (boundary.debugNeedsPaint) {
        // If it still needs paint, wait one more frame
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw 'Failed to generate image data.';

      final buffer = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/inzaar_quote_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File(filePath).create();
      await file.writeAsBytes(buffer);

      final quote = QuoteRepository.getQuoteForToday();

      try {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Shared from Inzaar - "${quote.text}"',
          subject: 'Daily Inspiration from Inzaar',
        );
      } catch (pluginError) {
        // Fallback for MissingPluginException or other sharing failures
        debugPrint(
            'System sharing failed, falling back to clipboard: $pluginError');
        await Clipboard.setData(ClipboardData(
            text: '${quote.text}\n\n— ${quote.author}\n\nShared from Inzaar'));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Sharing tool not ready yet. Quote copied to clipboard! (Please restart your app)'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to generate image: ${e.toString().split('\n').first}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quote = QuoteRepository.getQuoteForToday();

    return RepaintBoundary(
      key: _boundaryKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_streak Day Streak',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _isSharing ? null : _shareAsImage,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                  ),
                  icon: _isSharing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Icon(Icons.share_rounded,
                          size: 16, color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.format_quote_rounded,
              size: 28,
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 12),
            Text(
              quote.text,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.6,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                fontFamily: 'Lora',
              ),
            ),
            const SizedBox(height: 18),
            Container(
              height: 1,
              width: 30,
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 16),
            Text(
              quote.author.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
