import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../upload/presentation/upload_sheet.dart';
import 'dashboard_page.dart';
import 'files_page.dart';
import 'api_keys_page.dart';
import 'settings_page.dart';
import 'profile_sheet.dart';
import 'search_delegate.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/constants/app_constants.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;

  final _pages = const [
    DashboardPage(),
    FilesPage(),
    ApiKeysPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: 300.ms,
    )..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _currentIndex == 0
          ? AppBar(
              toolbarHeight: 72,
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
                    child: Icon(
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
          : PreferredSize(
              preferredSize: Size.zero,
              child: SizedBox.shrink(),
            ),
      body: AnimatedSwitcher(
        duration: 350.ms,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: GlassBottomNav(
        selectedIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          _fabController.reset();
          _fabController.forward();
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
      floatingActionButton: GlassFAB(
        onPressed: null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    ).animate().fadeIn(duration: 500.ms);
  }
}