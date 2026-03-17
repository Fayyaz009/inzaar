import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:inzaar/features/library/library_bloc.dart';
import 'package:inzaar/features/library/library_view_bloc.dart';
import 'package:inzaar/features/library/library_screen.dart';
import 'package:inzaar/features/library/library_search_delegate.dart';
import 'package:inzaar/features/settings/about_screen.dart';
import 'package:inzaar/features/settings/settings_screen.dart';
import 'package:inzaar/features/notes/notes_screen.dart';
import 'package:inzaar/features/home/main_nav_bloc.dart';
import 'package:inzaar/features/home/home_screen.dart';

class MainNavScreen extends StatelessWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MainNavBloc()),
        BlocProvider(create: (_) => LibraryViewBloc()),
      ],
      child: const _MainNavView(),
    );
  }
}

class _MainNavView extends StatefulWidget {
  const _MainNavView();

  @override
  State<_MainNavView> createState() => _MainNavViewState();
}

class _MainNavViewState extends State<_MainNavView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainNavBloc, MainNavState>(
      builder: (context, navState) {
        return PopScope(
          canPop: !navState.canPopTabHistory,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && navState.canPopTabHistory) {
              context.read<MainNavBloc>().add(const MainNavBackPressed());
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            extendBody: true,
            drawer: _AppDrawer(
              currentIndex: navState.currentIndex,
              onSelectTab: (index) {
                Navigator.pop(context);
                context.read<MainNavBloc>().add(MainNavTabSelected(index));
              },
            ),
            appBar: _buildAppBar(context, navState.currentIndex),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutQuart,
                switchOutCurve: Curves.easeInQuart,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.015),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey<int>(navState.currentIndex),
                  child: [
                    const HomeScreen(),
                    const LibraryScreen(),
                    const CategoryScreen(
                      title: 'Magazines',
                      category: LibraryCategory.magazines,
                    ),
                    const CategoryScreen(
                      title: 'Articles',
                      category: LibraryCategory.articles,
                    ),
                    const NotesScreen(),
                  ][navState.currentIndex],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.textScalerOf(context).scale(1).clamp(0.5, 1.1),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: NavigationBar(
                        height: 72,
                        selectedIndex: navState.currentIndex,
                        animationDuration: const Duration(milliseconds: 600),
                        onDestinationSelected: (index) {
                          context
                              .read<MainNavBloc>()
                              .add(MainNavTabSelected(index));
                        },
                        destinations: const [
                          NavigationDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home_rounded),
                            label: 'Home',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.menu_book_outlined),
                            selectedIcon: Icon(Icons.menu_book_rounded),
                            label: 'Books',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.collections_bookmark_outlined),
                            selectedIcon:
                                Icon(Icons.collections_bookmark_rounded),
                            label: 'Magazines',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.article_outlined),
                            selectedIcon: Icon(Icons.article_rounded),
                            label: 'Articles',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.format_quote_outlined),
                            selectedIcon: Icon(Icons.format_quote_rounded),
                            label: 'My Notes',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int currentIndex) {
    final theme = Theme.of(context);
    final titles = ['Inzaar', 'Books', 'Magazines', 'Articles', 'My Notes'];
    final subtitles = [
      'A refined library for serious reading',
      'Collected works and featured titles',
      'Issues curated for regular study',
      'Short reads for focused reflection',
      'Saved highlights and favorite lines',
    ];

    return AppBar(
      toolbarHeight: 84,
      leading: Center(
        child: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu_rounded),
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
          ),
        ),
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Column(
          key: ValueKey<int>(currentIndex),
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(titles[currentIndex]),
            const SizedBox(height: 2),
            Text(
              subtitles[currentIndex],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (currentIndex != 0)
          BlocBuilder<LibraryViewBloc, LibraryViewState>(
            builder: (context, viewState) {
              return IconButton(
                tooltip: viewState.isGridView ? 'List view' : 'Grid view',
                onPressed: () => context.read<LibraryViewBloc>().add(
                      const LibraryGridViewToggled(),
                    ),
                icon: Icon(
                  viewState.isGridView
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                ),
              );
            },
          ),
        IconButton(
          tooltip: 'Search library',
          onPressed: () => _openSearch(context, currentIndex),
          icon: const Icon(Icons.search_rounded),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _openSearch(BuildContext context, int currentIndex) {
    final state = context.read<LibraryBloc>().state;
    if (state is! LibraryLoaded) return;

    switch (currentIndex) {
      case 1:
        showSearch(
          context: context,
          delegate: LibrarySearchDelegate(state.books),
        );
        break;
      case 2:
        showSearch(
          context: context,
          delegate: LibrarySearchDelegate(state.magazines),
        );
        break;
      case 3:
        showSearch(
          context: context,
          delegate: LibrarySearchDelegate(state.articles),
        );
        break;
      default:
        showSearch(
          context: context,
          delegate: LibrarySearchDelegate([
            ...state.books,
            ...state.magazines,
            ...state.articles,
          ]),
        );
    }
  }
}

class _AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectTab;

  const _AppDrawer({
    required this.currentIndex,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.brightness == Brightness.light ||
                        theme.brightness == Brightness.dark
                    ? [
                        const Color(0xFF121212),
                        const Color(0xFF1C1C1C)
                      ] // Pure Ink
                    : [
                        const Color(0xFF3B2A18),
                        const Color(0xFF523D26)
                      ], // Premium Sepia
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Inzaar',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Elegant reading for books, magazines, and articles.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DrawerTile(
                  title: 'Home',
                  icon: Icons.home_rounded,
                  selected: currentIndex == 0,
                  onTap: () => onSelectTab(0),
                ),
                _DrawerTile(
                  title: 'Books',
                  icon: Icons.menu_book_rounded,
                  selected: currentIndex == 1,
                  onTap: () => onSelectTab(1),
                ),
                _DrawerTile(
                  title: 'Magazines',
                  icon: Icons.collections_bookmark_rounded,
                  selected: currentIndex == 2,
                  onTap: () => onSelectTab(2),
                ),
                _DrawerTile(
                  title: 'Articles',
                  icon: Icons.article_rounded,
                  selected: currentIndex == 3,
                  onTap: () => onSelectTab(3),
                ),
                _DrawerTile(
                  title: 'My Notes',
                  icon: Icons.format_quote_rounded,
                  selected: currentIndex == 4,
                  onTap: () => onSelectTab(4),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'More',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _DrawerTile(
                  title: 'Settings',
                  icon: Icons.tune_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                _DrawerTile(
                  title: 'About',
                  icon: Icons.info_outline_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Support',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _DrawerTile(
                  title: 'Share with Others',
                  icon: Icons.share_rounded,
                  onTap: () {
                    Share.share(
                      'Read premium Islamic books and magazines on Inzaar. Download now!',
                      subject: 'Inzaar - A mission for truth',
                    );
                  },
                ),
                _DrawerTile(
                  title: 'Rate Us',
                  icon: Icons.star_rate_rounded,
                  onTap: () async {
                    final Uri url = Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.inzaar.fayyazapps',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          leading: Icon(
            icon,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: selected ? theme.colorScheme.primary : null,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
