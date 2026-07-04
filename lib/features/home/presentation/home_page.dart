import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dashboard_page.dart';
import 'files_page.dart';
import 'api_keys_page.dart';
import 'settings_page.dart';
import 'profile_sheet.dart';
import 'search_delegate.dart';
import '../../upload/presentation/upload_sheet.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/tab_index_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final tabIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: tabIndex == 0
          ? AppBar(
              toolbarHeight: ResponsiveUtils.isSmall(context) ? 64 : 72,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: context.aurora.primaryAurora,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  onPressed: () => ProfileSheet.show(context),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Free Image Hosting',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.glass.glassSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.glass.glassBorder,
                        ),
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: cs.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                    onPressed: () => showSearch(
                      context: context,
                      delegate: ImageSearchDelegate(),
                    ),
                  ),
                ),
              ],
            )
          : const PreferredSize(
              preferredSize: Size.zero,
              child: SizedBox.shrink(),
            ),
      body: IndexedStack(
        index: tabIndex,
        children: _pages,
      ),
      bottomNavigationBar: GlassBottomNav(
        selectedIndex: tabIndex,
        onTap: (i) {
          ref.read(tabIndexProvider.notifier).state = i;
        },
        items: const [
          GlassNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Home',
          ),
          GlassNavItem(
            icon: Icons.folder_outlined,
            selectedIcon: Icons.folder_rounded,
            label: 'Files',
          ),
          GlassNavItem(
            icon: Icons.key_outlined,
            selectedIcon: Icons.key_rounded,
            label: 'Keys',
          ),
          GlassNavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: kBottomNavigationBarHeight + 16,
        ),
        child: GlassFAB(
          onPressed: () => UploadSheet.show(context),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    ).animate().fadeIn(duration: 500.ms);
  }
}

final _pages = <Widget>[
  const DashboardPage(),
  const FilesPage(),
  const ApiKeysPage(),
  const SettingsPage(),
];
