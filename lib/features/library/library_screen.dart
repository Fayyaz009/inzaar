import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:inzaar/features/library/library_item.dart';
import 'package:inzaar/features/library/library_bloc.dart';
import 'package:inzaar/features/library/library_view_bloc.dart';
import 'package:inzaar/features/library/details_screen.dart';
import 'package:inzaar/core/inzaar_image.dart';

enum LibraryCategory { books, magazines, articles }

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary));
          }
          if (state is LibraryError) {
            return Center(child: Text(state.message));
          }
          if (state is! LibraryLoaded) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(context).textScaler.clamp(
                        minScaleFactor: 0.8,
                        maxScaleFactor: 1.1,
                      ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      labelColor: Theme.of(context).colorScheme.primary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      unselectedLabelColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'All Books'),
                        Tab(text: 'Abu Yahya'),
                        Tab(text: 'Other Authors'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    SharedLibraryListWidget(items: state.books),
                    SharedLibraryListWidget(items: state.abuYahyaBooks),
                    SharedLibraryListWidget(items: state.otherBooks),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CategoryScreen extends StatelessWidget {
  final String title;
  final LibraryCategory category;

  const CategoryScreen(
      {super.key, required this.title, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state is LibraryLoading) {
          return Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary));
        }
        if (state is LibraryError) {
          return Center(child: Text(state.message));
        }
        if (state is! LibraryLoaded) {
          return const SizedBox.shrink();
        }

        final items = switch (category) {
          LibraryCategory.books => state.books,
          LibraryCategory.magazines => state.magazines,
          LibraryCategory.articles => state.articles,
        };

        return SharedLibraryListWidget(items: items);
      },
    );
  }
}

class SharedLibraryListWidget extends StatelessWidget {
  final List<LibraryItem> items;

  const SharedLibraryListWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No items found.'));
    }

    return BlocBuilder<LibraryViewBloc, LibraryViewState>(
      builder: (context, viewState) {
        if (viewState.isGridView) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 18,
              mainAxisSpacing: 22,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _GridLibraryCard(item: items[index], index: index)
                  .animate(delay: Duration(milliseconds: 50 * index))
                  .fadeIn(duration: 240.ms)
                  .slideY(begin: 0.05);
            },
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            return _ListLibraryCard(item: items[index], index: index)
                .animate(delay: Duration(milliseconds: 40 * index))
                .fadeIn(duration: 220.ms)
                .slideX(begin: 0.04);
          },
        );
      },
    );
  }
}

class _GridLibraryCard extends StatelessWidget {
  final LibraryItem item;
  final int index;

  const _GridLibraryCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final heroTag = 'library_grid_${item.id}_$index';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DetailsScreen(item: item, heroTag: heroTag)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _LibraryCover(item: item, heroTag: heroTag)),
          const SizedBox(height: 12),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            item.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

class _ListLibraryCard extends StatelessWidget {
  final LibraryItem item;
  final int index;

  const _ListLibraryCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heroTag = 'library_list_${item.id}_$index';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DetailsScreen(item: item, heroTag: heroTag)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 105,
              height: 145,
              child: _LibraryCover(item: item, heroTag: heroTag),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.author,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryCover extends StatelessWidget {
  final LibraryItem item;
  final String heroTag;

  const _LibraryCover({required this.item, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        width: double.infinity,
        height: double.infinity,
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
              alignment: Alignment.topCenter),
        ),
      ),
    );
  }
}
