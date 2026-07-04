import 'package:flutter/material.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../core/utils/extensions.dart';

class ImageSearchDelegate extends SearchDelegate<String?> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.glass.glassSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.clear_rounded, size: 20, color: context.colorScheme.onSurfaceVariant),
              onPressed: () => query = '',
            ),
          ),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.glass.glassSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: 20, color: context.colorScheme.onSurfaceVariant),
          onPressed: () => close(context, null),
        ),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return GlassEmptyState(
      icon: Icons.search_rounded,
      title: 'Results for "$query"',
      subtitle: 'No results found',
      iconGradient: context.aurora.primaryAurora,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return GlassEmptyState(
        icon: Icons.search_rounded,
        title: 'Search your images',
        subtitle: 'Type to search through your uploads',
        iconGradient: context.aurora.primaryAurora,
        action: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              GlassChip(label: 'Recent', icon: Icons.schedule_rounded, onTap: () => query = 'recent:'),
              GlassChip(label: 'Favorites', icon: Icons.favorite_outline_rounded, onTap: () => query = 'fav:'),
              GlassChip(label: 'Expiring', icon: Icons.timer_outlined, onTap: () => query = 'expiring:'),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
