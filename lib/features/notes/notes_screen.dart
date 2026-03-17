import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:inzaar/features/library/library_item.dart';
import 'package:inzaar/features/settings/settings_bloc.dart';
import 'package:inzaar/core/app_theme.dart';
import 'package:inzaar/features/library/library_bloc.dart';
import 'package:inzaar/features/notes/notes_bloc.dart';
import 'package:inzaar/features/notes/notes_event.dart';
import 'package:inzaar/features/notes/notes_state.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesInitial) {
            context.read<NotesBloc>().add(const LoadAllNotes());
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary));
          }
          if (state is NotesLoading) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary));
          }
          if (state is NotesError) {
            return Center(child: Text(state.message));
          }
          if (state is NotesLoaded) {
            final notes = state.notes;
            if (notes.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.format_quote_rounded,
                          size: 80,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.15)),
                      const SizedBox(height: 24),
                      Text(
                        'No Notes Yet',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Highlight text while reading to save your favorite quotes and lines here.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              itemCount: notes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _NoteCard(
                  note: notes[index],
                  index: index,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NoteCard extends StatefulWidget {
  final dynamic note; // Using dynamic for brevity, should be Note model
  final int index;

  const _NoteCard({required this.note, required this.index});

  @override
  State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareAsImage(String sourceTitle) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw 'Could not find the card to capture.';

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw 'Failed to generate image data.';

      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/inzaar_note_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File(filePath).create();
      await file.writeAsBytes(buffer);

      try {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Shared from Inzaar — Highlight from "$sourceTitle"',
          subject: 'Note from Inzaar',
        );
      } catch (pluginError) {
        await Clipboard.setData(ClipboardData(
            text:
                '${widget.note.quote}\n\n— Source: $sourceTitle\n\nShared from Inzaar'));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Sharing tool not ready. Quote copied to clipboard!'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to share: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = widget.note;
    final highlightColor =
        Color(int.parse(note.colorHex.substring(1, 7), radix: 16) + 0xFF000000);

    return RepaintBoundary(
      key: _boundaryKey,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: highlightColor.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 140,
              decoration: BoxDecoration(
                color: highlightColor,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(24)),
              ),
            ),
            Expanded(
              child: Container(
                color: highlightColor.withValues(alpha: 0.04),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.format_quote_rounded,
                            color: highlightColor, size: 28),
                        Expanded(
                          child: BlocBuilder<LibraryBloc, LibraryState>(
                            builder: (context, libraryState) {
                              final title =
                                  _getItemTitle(note.itemId, libraryState);
                              return Text(
                                title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        if (!_isSharing) ...[
                          // Share button
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: _isSharing
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.share_rounded, size: 18),
                            onPressed: () {
                              final state = context.read<LibraryBloc>().state;
                              final title = _getItemTitle(note.itemId, state);
                              _shareAsImage(title);
                            },
                          ),
                          // Delete button
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18),
                            color:
                                theme.colorScheme.error.withValues(alpha: 0.7),
                            onPressed: () {
                              context
                                  .read<NotesBloc>()
                                  .add(DeleteNote(id: note.id));
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Note deleted')),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    BlocBuilder<LibraryBloc, LibraryState>(
                      builder: (context, libraryState) {
                        LibraryItem? item;
                        if (libraryState is LibraryLoaded) {
                          final allItems = [
                            ...libraryState.books,
                            ...libraryState.magazines,
                            ...libraryState.articles
                          ];
                          try {
                            item = allItems
                                .firstWhere((item) => item.id == note.itemId);
                          } catch (_) {}
                        }

                        final isRTL = item?.isArabicRTL ?? true;

                        return BlocBuilder<SettingsBloc, SettingsState>(
                          builder: (context, settingsState) {
                            TextStyle textStyle;
                            if (isRTL) {
                              textStyle = AppTheme.urduStyle(
                                fontSize: settingsState.urduFontSize,
                                fontFamily: settingsState.urduFontFamily,
                              ).copyWith(
                                height: 1.95,
                                letterSpacing: 0.15,
                                color: theme.colorScheme.onSurface,
                              );
                            } else {
                              textStyle = GoogleFonts.getFont(
                                settingsState.readingFontFamily,
                                fontSize: settingsState.fontSize,
                                height: 1.95,
                                letterSpacing: 0.15,
                              ).copyWith(
                                color: theme.colorScheme.onSurface,
                                fontStyle: FontStyle.italic,
                              );
                            }

                            return Directionality(
                              textDirection:
                                  isRTL ? TextDirection.rtl : TextDirection.ltr,
                              child: Text(
                                note.quote,
                                textAlign:
                                    isRTL ? TextAlign.right : TextAlign.justify,
                                style: textStyle,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatDate(note.timestamp),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
            duration: 300.ms, delay: Duration(milliseconds: 50 * widget.index))
        .slideX(begin: 0.05);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getItemTitle(String itemId, LibraryState state) {
    if (state is LibraryLoaded) {
      final allItems = [...state.books, ...state.magazines, ...state.articles];
      try {
        return allItems.firstWhere((item) => item.id == itemId).title;
      } catch (_) {
        return 'Unknown Title';
      }
    }
    return '';
  }
}
