import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:inzaar/core/database_helper.dart';
import 'package:inzaar/core/app_theme.dart';
import 'package:inzaar/features/library/library_item.dart';
import 'package:inzaar/features/settings/settings_bloc.dart';
import 'package:inzaar/features/reading/reading_repository.dart';
import 'package:inzaar/features/reading/reading_bloc.dart';
import 'package:inzaar/features/notes/notes_bloc.dart';
import 'package:inzaar/features/notes/notes_event.dart';
import 'package:inzaar/features/notes/note.dart';
import 'package:inzaar/features/notes/notes_state.dart';

class ReadingScreen extends StatefulWidget {
  final LibraryItem item;

  const ReadingScreen({super.key, required this.item});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen>
    with WidgetsBindingObserver {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  final ReadingRepository _repository = ReadingRepository();
  final ReadingBloc _readingBloc = ReadingBloc();

  Timer? _autoSaveTimer;
  double _lastSavedProgress = 0.0;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadContent();
    _itemPositionsListener.itemPositions.addListener(_onScrollChanged);
    _autoSaveTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _saveProgress());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveProgress();
    }
  }

  Future<void> _loadContent() async {
    _readingBloc.add(const ReadingContentLoading());

    try {
      final text = await _repository.loadTextContent(widget.item.contentPath);
      final paragraphs = text
          .split('\n')
          .where((paragraph) => paragraph.trim().isNotEmpty)
          .toList();

      double savedProgress = 0.0;
      try {
        savedProgress =
            await DatabaseHelper.instance.getProgress(widget.item.id) ?? 0.0;
      } catch (error) {
        debugPrint('Could not load progress from DB: $error');
      }

      _lastSavedProgress = savedProgress;
      _currentProgress = savedProgress;
      _readingBloc.add(
        ReadingContentLoaded(
          paragraphs:
              paragraphs.isEmpty ? ['No content available.'] : paragraphs,
          savedProgress: savedProgress,
        ),
      );

      if (savedProgress > 0 && paragraphs.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final targetIndex = (savedProgress * paragraphs.length)
              .floor()
              .clamp(0, paragraphs.length - 1);
          if (_itemScrollController.isAttached) {
            _itemScrollController.jumpTo(
                index: targetIndex + 1); // +1 because index 0 is the header
          }
        });
      }
    } catch (error) {
      _readingBloc.add(ReadingContentFailed('Error loading content: $error'));
    }
  }

  void _onScrollChanged() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final paragraphsCount = _readingBloc.state.paragraphs.length;
    if (paragraphsCount == 0) return;

    // Find the first visible item that is a paragraph (index > 0 and index <= paragraphsCount)
    // The list has paragraphsCount + 2 items (header and footer)
    int firstVisibleIndex = 0;
    for (final position in positions) {
      if (position.itemLeadingEdge < 1.0 && position.itemTrailingEdge > 0.0) {
        if (firstVisibleIndex == 0 || position.index < firstVisibleIndex) {
          firstVisibleIndex = position.index;
        }
      }
    }

    // Index 0 is header. Paragraphs are 1 to paragraphsCount. Footer is paragraphsCount + 1.
    int maxVisibleIndex = 0;
    for (final position in positions) {
      if (position.itemLeadingEdge < 1.0 && position.itemTrailingEdge > 0.0) {
        if (position.index > maxVisibleIndex) {
          maxVisibleIndex = position.index;
        }
      }
    }

    if (maxVisibleIndex >= paragraphsCount + 1) {
      // Footer or very end is visible
      _currentProgress = 1.0;
    } else if (firstVisibleIndex > 0 && firstVisibleIndex <= paragraphsCount) {
      // Use the top visible paragraph for a stable reading experience in long books
      _currentProgress =
          ((firstVisibleIndex - 1) / paragraphsCount).clamp(0.0, 1.0);
    } else if (firstVisibleIndex > paragraphsCount) {
      _currentProgress = 1.0;
    } else {
      _currentProgress = 0.0;
    }

    // Save more frequently if the user scrolls significantly
    if ((_currentProgress - _lastSavedProgress).abs() > 0.05) {
      _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    final paragraphs = _readingBloc.state.paragraphs;
    if (paragraphs.isEmpty) return;
    final percentage = _currentProgress.clamp(0.0, 1.0);

    if ((percentage - _lastSavedProgress).abs() > 0.0001) {
      try {
        await DatabaseHelper.instance.saveProgress(widget.item.id, percentage);
        _lastSavedProgress = percentage;
      } catch (error) {
        debugPrint('Could not save progress to DB: $error');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveProgress();
    _autoSaveTimer?.cancel();
    _itemPositionsListener.itemPositions.removeListener(_onScrollChanged);
    _readingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _readingBloc,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          TextStyle textStyle;
          if (widget.item.isArabicRTL) {
            textStyle = AppTheme.urduStyle(
              fontSize: settingsState.urduFontSize,
              fontFamily: settingsState.urduFontFamily,
            ).copyWith(height: 1.95, letterSpacing: 0.15);
          } else {
            textStyle = GoogleFonts.getFont(
              settingsState.readingFontFamily,
              fontSize: settingsState.fontSize,
              height: 1.95,
              letterSpacing: 0.15,
            );
          }

          final palette =
              _ReadingPalette.fromThemeMode(settingsState.themeMode);

          return BlocBuilder<ReadingBloc, ReadingState>(
            builder: (context, readingState) {
              return Scaffold(
                backgroundColor: palette.background,
                body: SafeArea(
                  top: false,
                  bottom: false,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: readingState.isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : NotificationListener<ScrollUpdateNotification>(
                                onNotification: (notification) {
                                  if (notification.scrollDelta != null &&
                                      notification.scrollDelta!.abs() > 2.0) {
                                    context
                                        .read<ReadingBloc>()
                                        .add(const ReadingControlsHidden());
                                  }
                                  return false;
                                },
                                child: BlocBuilder<NotesBloc, NotesState>(
                                  builder: (context, notesState) {
                                    final itemNotes = notesState is NotesLoaded
                                        ? notesState.notes
                                            .where((n) =>
                                                n.itemId == widget.item.id)
                                            .toList()
                                        : <Note>[];
                                    return ScrollablePositionedList.builder(
                                      itemScrollController:
                                          _itemScrollController,
                                      itemPositionsListener:
                                          _itemPositionsListener,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: readingState.paragraphs.isEmpty
                                          ? 2
                                          : readingState.paragraphs.length + 2,
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return Container(
                                            margin: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .padding
                                                      .top +
                                                  24,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.item.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium
                                                      ?.copyWith(
                                                          color: palette.text),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Resume from ${(readingState.savedProgress * 100).round()}%',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: palette.text
                                                            .withValues(
                                                                alpha: 0.65),
                                                      ),
                                                ),
                                                const SizedBox(height: 24),
                                              ],
                                            ),
                                          );
                                        }

                                        if (index ==
                                            (readingState.paragraphs.isEmpty
                                                ? 1
                                                : readingState
                                                        .paragraphs.length +
                                                    1)) {
                                          return SizedBox(
                                            height: MediaQuery.of(context)
                                                    .padding
                                                    .bottom +
                                                130,
                                          );
                                        }

                                        final paragraphIndex = index - 1;
                                        final isFirst = paragraphIndex == 0;
                                        final isLast = paragraphIndex ==
                                            readingState.paragraphs.length - 1;

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                              22,
                                              isFirst ? 26 : 0,
                                              22,
                                              isLast
                                                  ? 28
                                                  : (widget.item.isArabicRTL
                                                      ? 32
                                                      : 24),
                                            ),
                                            decoration: BoxDecoration(
                                              color: palette.card,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: isFirst
                                                    ? const Radius.circular(28)
                                                    : Radius.zero,
                                                bottom: isLast
                                                    ? const Radius.circular(28)
                                                    : Radius.zero,
                                              ),
                                              border: Border(
                                                top: isFirst
                                                    ? BorderSide(
                                                        color: palette.divider)
                                                    : BorderSide.none,
                                                bottom: isLast
                                                    ? BorderSide(
                                                        color: palette.divider)
                                                    : BorderSide.none,
                                                left: BorderSide(
                                                    color: palette.divider),
                                                right: BorderSide(
                                                    color: palette.divider),
                                              ),
                                            ),
                                            child: Directionality(
                                              textDirection:
                                                  widget.item.isArabicRTL
                                                      ? TextDirection.rtl
                                                      : TextDirection.ltr,
                                              child: SelectableText.rich(
                                                TextSpan(
                                                  children:
                                                      _buildHighlightedSpans(
                                                    readingState.paragraphs[
                                                        paragraphIndex],
                                                    itemNotes,
                                                    textStyle.copyWith(
                                                        color: palette.text,
                                                        height: 1.4),
                                                  ),
                                                ),
                                                strutStyle: StrutStyle(
                                                  fontSize: widget.item.isArabicRTL
                                                      ? settingsState.urduFontSize
                                                      : settingsState.fontSize,
                                                  height: 1.95,
                                                  forceStrutHeight: true,
                                                ),
                                                selectionHeightStyle: BoxHeightStyle.tight,
                                                selectionWidthStyle: BoxWidthStyle.tight,
                                                textHeightBehavior: const TextHeightBehavior(
                                                  leadingDistribution: TextLeadingDistribution.even,
                                                ),
                                                textAlign:
                                                    widget.item.isArabicRTL
                                                        ? TextAlign.right
                                                        : TextAlign.justify,
                                                contextMenuBuilder:
                                                    (BuildContext context,
                                                        EditableTextState
                                                            editableTextState) {
                                                  return AdaptiveTextSelectionToolbar(
                                                    anchors: editableTextState
                                                        .contextMenuAnchors,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .surface,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(24),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                      alpha:
                                                                          0.1),
                                                              blurRadius: 10,
                                                              offset:
                                                                  const Offset(
                                                                      0, 4),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              'Highlight:',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .labelMedium
                                                                  ?.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurfaceVariant,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                                width: 12),
                                                            ...[
                                                              '#C49A53',
                                                              '#FFEB3B',
                                                              '#40C070',
                                                              '#E56B6B',
                                                              '#5A9CF5',
                                                              '#9E67E4'
                                                            ].map((hex) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    final selection =
                                                                        editableTextState
                                                                            .textEditingValue
                                                                            .selection;
                                                                    if (!selection
                                                                        .isCollapsed) {
                                                                      final selectedText = selection.textInside(editableTextState
                                                                          .textEditingValue
                                                                          .text);
                                                                      context
                                                                          .read<
                                                                              NotesBloc>()
                                                                          .add(
                                                                              AddNote(
                                                                            itemId:
                                                                                widget.item.id,
                                                                            quote:
                                                                                selectedText.trim(),
                                                                            colorHex:
                                                                                hex,
                                                                          ));
                                                                      ContextMenuController
                                                                          .removeAny();
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .hideCurrentSnackBar();
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        const SnackBar(
                                                                            content:
                                                                                Text('Note highlighted successfully!')),
                                                                      );
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 24,
                                                                    height: 24,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(int.parse(
                                                                              hex.substring(1, 7),
                                                                              radix: 16) +
                                                                          0xFF000000),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .white,
                                                                          width:
                                                                              2),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .black
                                                                              .withValues(alpha: 0.15),
                                                                          blurRadius:
                                                                              4,
                                                                          offset: const Offset(
                                                                              0,
                                                                              2),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        top: readingState.showControls ? 0 : -120,
                        left: 0,
                        right: 0,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top + 10,
                                left: 10,
                                right: 10,
                                bottom: 14,
                              ),
                              color: palette.overlay,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: palette.text,
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          widget.item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(color: palette.text),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(_lastSavedProgress * 100).round()}% saved',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: palette.text
                                                    .withValues(alpha: 0.65),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.bookmark_outline_rounded,
                                      color: palette.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        bottom: readingState.showControls ? 0 : -420,
                        left: 0,
                        right: 0,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                22,
                                24,
                                22,
                                MediaQuery.of(context).padding.bottom + 24,
                              ),
                              decoration: BoxDecoration(
                                color: palette.overlay,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(32),
                                ),
                                border: Border(
                                  top: BorderSide(color: palette.divider),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Reading controls',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(color: palette.text),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${(_currentProgress * 100).round()}% read',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: palette.text
                                                  .withValues(alpha: 0.65),
                                            ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        onPressed: () => context
                                            .read<ReadingBloc>()
                                            .add(
                                                const ReadingControlsToggled()),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _ThemeChoice(
                                          label: 'Light',
                                          sampleColor: const Color(0xFFFCFCFC),
                                          selected: settingsState.themeMode ==
                                              'light',
                                          onTap: () => context
                                              .read<SettingsBloc>()
                                              .add(const ChangeTheme('light')),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _ThemeChoice(
                                          label: 'Sepia',
                                          sampleColor: const Color(0xFFF7EBCF),
                                          selected: settingsState.themeMode ==
                                              'sepia',
                                          onTap: () => context
                                              .read<SettingsBloc>()
                                              .add(const ChangeTheme('sepia')),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _ThemeChoice(
                                          label: 'Dark',
                                          sampleColor: const Color(0xFF161616),
                                          selected:
                                              settingsState.themeMode == 'dark',
                                          onTap: () => context
                                              .read<SettingsBloc>()
                                              .add(const ChangeTheme('dark')),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Row(
                                      children: widget.item.isArabicRTL
                                          ? [
                                              _FontChoice(
                                                label: 'Nastaliq',
                                                fontFamily: 'Jameel',
                                                selected: settingsState
                                                        .urduFontFamily ==
                                                    'Jameel',
                                                onTap: () => context
                                                    .read<SettingsBloc>()
                                                    .add(const ChangeUrduFontFamily(
                                                        'Jameel')),
                                              ),
                                            ]
                                          : [
                                              _FontChoice(
                                                label: 'Inter',
                                                fontFamily: 'Inter',
                                                selected: settingsState
                                                        .readingFontFamily ==
                                                    'Inter',
                                                onTap: () => context
                                                    .read<SettingsBloc>()
                                                    .add(
                                                        const ChangeReadingFontFamily(
                                                            'Inter')),
                                              ),
                                              const SizedBox(width: 8),
                                              _FontChoice(
                                                label: 'Montserrat',
                                                fontFamily: 'Montserrat',
                                                selected: settingsState
                                                        .readingFontFamily ==
                                                    'Montserrat',
                                                onTap: () => context
                                                    .read<SettingsBloc>()
                                                    .add(
                                                        const ChangeReadingFontFamily(
                                                            'Montserrat')),
                                              ),
                                              const SizedBox(width: 8),
                                              _FontChoice(
                                                label: 'Playfair',
                                                fontFamily: 'Playfair Display',
                                                selected: settingsState
                                                        .readingFontFamily ==
                                                    'Playfair Display',
                                                onTap: () => context
                                                    .read<SettingsBloc>()
                                                    .add(
                                                        const ChangeReadingFontFamily(
                                                            'Playfair Display')),
                                              ),
                                              const SizedBox(width: 8),
                                              _FontChoice(
                                                label: 'Lora',
                                                fontFamily: 'Lora',
                                                selected: settingsState
                                                        .readingFontFamily ==
                                                    'Lora',
                                                onTap: () => context
                                                    .read<SettingsBloc>()
                                                    .add(
                                                        const ChangeReadingFontFamily(
                                                            'Lora')),
                                              ),
                                            ],
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  Row(
                                    children: [
                                      Text(
                                        'A',
                                        style: TextStyle(
                                          color: palette.text
                                              .withValues(alpha: 0.65),
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: widget.item.isArabicRTL
                                              ? settingsState.urduFontSize
                                              : settingsState.fontSize,
                                          min: 14,
                                          max:
                                              widget.item.isArabicRTL ? 42 : 32,
                                          divisions:
                                              widget.item.isArabicRTL ? 28 : 18,
                                          activeColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          onChanged: (value) {
                                            if (widget.item.isArabicRTL) {
                                              context.read<SettingsBloc>().add(
                                                  ChangeUrduFontSize(value));
                                            } else {
                                              context
                                                  .read<SettingsBloc>()
                                                  .add(ChangeFontSize(value));
                                            }
                                          },
                                        ),
                                      ),
                                      Text(
                                        'A',
                                        style: TextStyle(
                                          color: palette.text
                                              .withValues(alpha: 0.65),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: readingState.isLoading ||
                        readingState.showControls
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 24, right: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: palette.text.withValues(alpha: 0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: FloatingActionButton(
                            onPressed: () => context
                                .read<ReadingBloc>()
                                .add(const ReadingControlsToggled()),
                            backgroundColor:
                                palette.background.withValues(alpha: 0.85),
                            foregroundColor: palette.text,
                            elevation: 0,
                            highlightElevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.format_size_rounded,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
              );
            },
          );
        },
      ),
    );
  }

  List<InlineSpan> _buildHighlightedSpans(
      String text, List<Note> notes, TextStyle baseStyle) {
    if (notes.isEmpty) return [TextSpan(text: text, style: baseStyle)];

    List<_HighlightMatch> matches = [];
    for (final note in notes) {
      if (note.quote.isEmpty) continue;
      int startIndex = 0;
      while (true) {
        final index = text.indexOf(note.quote, startIndex);
        if (index == -1) break;
        matches.add(_HighlightMatch(
          start: index,
          end: index + note.quote.length,
          colorHex: note.colorHex,
        ));
        startIndex = index + note.quote.length;
      }
    }

    if (matches.isEmpty) return [TextSpan(text: text, style: baseStyle)];

    matches.sort((a, b) => a.start.compareTo(b.start));

    List<_HighlightMatch> nonOverlapping = [];
    int currentEnd = -1;
    for (final match in matches) {
      if (match.start >= currentEnd) {
        nonOverlapping.add(match);
        currentEnd = match.end;
      }
    }

    List<InlineSpan> spans = [];
    int currentIndex = 0;
    for (final match in nonOverlapping) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
            text: text.substring(currentIndex, match.start), style: baseStyle));
      }
      final highlightColor = Color(
          int.parse(match.colorHex.substring(1, 7), radix: 16) + 0xFF000000);
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: baseStyle.copyWith(
          backgroundColor: highlightColor.withValues(alpha: 0.35),
        ),
      ));
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: baseStyle));
    }

    return spans;
  }
}

class _HighlightMatch {
  final int start;
  final int end;
  final String colorHex;
  _HighlightMatch(
      {required this.start, required this.end, required this.colorHex});
}

class _ThemeChoice extends StatelessWidget {
  final String label;
  final Color sampleColor;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.label,
    required this.sampleColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sampleColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    selected ? theme.colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.primary
                      : (theme.brightness == Brightness.dark
                          ? Colors.white24
                          : Colors.black12),
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: sampleColor.computeLuminance() > 0.5
                      ? Colors.black87
                      : Colors.white,
                )),
          ],
        ),
      ),
    );
  }
}

class _FontChoice extends StatelessWidget {
  final String label;
  final String fontFamily;
  final bool selected;
  final VoidCallback onTap;

  const _FontChoice({
    required this.label,
    required this.fontFamily,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle getLabelStyle() {
      return TextStyle(
        fontSize: 16,
        fontFamily: fontFamily,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: getLabelStyle(),
          ),
        ),
      ),
    );
  }
}

class _ReadingPalette {
  final Color background;
  final Color card;
  final Color text;
  final Color divider;
  final Color overlay;

  const _ReadingPalette({
    required this.background,
    required this.card,
    required this.text,
    required this.divider,
    required this.overlay,
  });

  factory _ReadingPalette.fromThemeMode(String themeMode) {
    switch (themeMode) {
      case 'dark':
        return const _ReadingPalette(
          background: Color(0xFF0C0C0C),
          card: Color(0xFF161616),
          text: Color(0xFFE0E0E0),
          divider: Color(0xFF262626),
          overlay: Color(0xDD0C0C0C),
        );
      case 'sepia':
        return const _ReadingPalette(
          background: Color(0xFFF5EBD8),
          card: Color(0xFFFFF7EA),
          text: Color(0xFF59462E),
          divider: Color(0xFFE2D2B3),
          overlay: Color(0xE6F7EEDC),
        );
      case 'light':
      default:
        return const _ReadingPalette(
          background: Color(0xFFFCFCFC),
          card: Colors.white,
          text: Color(0xFF1A1A1A),
          divider: Color(0xFFEEEEEE),
          overlay: Color(0xEFFFFFFF),
        );
    }
  }
}
