import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../upload/presentation/upload_sheet.dart';
import 'dashboard_page.dart';
import 'files_page.dart';
import 'api_keys_page.dart';
import 'settings_page.dart';
import 'profile_sheet.dart';
import 'search_delegate.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/extensions.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final _pages = const [
    DashboardPage(),
    FilesPage(),
    ApiKeysPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              leading: IconButton(
                icon: Icon(Icons.person_outline_rounded, color: cs.onSurfaceVariant),
                onPressed: () => ProfileSheet.show(context),
              ),
              title: Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                  onPressed: () => showSearch(
                    context: context,
                    delegate: ImageSearchDelegate(),
                  ),
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Files',
          ),
          NavigationDestination(
            icon: Icon(Icons.key_outlined),
            selectedIcon: Icon(Icons.key_rounded),
            label: 'API Keys',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => UploadSheet.show(context),
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
