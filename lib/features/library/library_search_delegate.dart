import 'package:flutter/material.dart';
import 'package:inzaar/core/app_theme.dart';
import 'package:inzaar/features/library/library_item.dart';
import 'package:inzaar/features/library/details_screen.dart';
import 'package:inzaar/core/inzaar_image.dart';

class LibrarySearchDelegate extends SearchDelegate<LibraryItem?> {
  final List<LibraryItem> items;

  LibrarySearchDelegate(this.items);

  @override
  String get searchFieldLabel => 'Search library...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: AppTheme.primaryGreen),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryGreen),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    final results = items.where((item) {
      final titleMatch = item.title.toLowerCase().contains(query.toLowerCase());
      final authorMatch = item.author.toLowerCase().contains(query.toLowerCase());
      return titleMatch || authorMatch;
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text("No results found."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: Container(
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: InzaarImage(
                path: item.coverPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(item.author, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(
                  item: item,
                  heroTag: 'search_${item.id}_$index',
                ),
              ),
            );
          },
        );
      },
    );
  }
}
