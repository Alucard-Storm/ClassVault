import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../features/auth/auth_provider.dart';

class ResponsiveScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final String currentPath;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentPath,
    this.actions,
    this.bottom,
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authStateProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);

    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width > 960;

    if (user == null) return body;

    final menuItems = _getMenuItems(user.role);

    // Live defaulter count for admin notifications
    final defaulterCountAsync = user.role == UserRole.admin
        ? ref.watch(defaulterCountProvider)
        : const AsyncData(0);
    final notifCount = defaulterCountAsync.valueOrNull ?? 0;

    void cycleThemeMode() {
      final current = ref.read(themeModeProvider);
      final next = current == ThemeMode.system
          ? ThemeMode.light
          : (current == ThemeMode.light ? ThemeMode.dark : ThemeMode.system);
      ref.read(themeModeProvider.notifier).state = next;
    }

    final Widget mainLayout;

    if (isDesktop) {
      mainLayout = Scaffold(
        body: Row(
          children: [
            Container(
              width: 280,
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF4C5DF4), Color(0xFF3544C4)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          size: 32,
                          color: isDark ? theme.colorScheme.primary : Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CampusVault',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: isDark ? theme.colorScheme.onSurface : Colors.white,
                              ),
                            ),
                            Text(
                              'SIRT ERP',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                                    : Colors.white.withValues(alpha: 0.6),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.primary.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isDark
                              ? theme.colorScheme.primary.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: TextStyle(
                                color: isDark ? theme.colorScheme.primary : Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark
                                      ? theme.colorScheme.onSurface
                                      : Colors.white,
                                ),
                              ),
                              Text(
                                user.role.name.toUpperCase(),
                                style: TextStyle(
                                  color: isDark
                                      ? theme.colorScheme.primary
                                      : Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: menuItems.length,
                      itemBuilder: (context, idx) {
                        final item = menuItems[idx];
                        final isSelected = currentPath == item.route ||
                            (item.route != '/admin' &&
                                item.route != '/faculty' &&
                                item.route != '/student' &&
                                currentPath.startsWith(item.route));
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: ListTile(
                            selected: isSelected,
                            selectedTileColor: isDark
                                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                : Colors.white.withValues(alpha: 0.15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            leading: Icon(
                              item.icon,
                              color: isSelected
                                  ? (isDark ? theme.colorScheme.primary : Colors.white)
                                  : (isDark
                                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                                      : Colors.white.withValues(alpha: 0.7)),
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? (isDark ? theme.colorScheme.primary : Colors.white)
                                    : (isDark
                                        ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                                        : Colors.white.withValues(alpha: 0.85)),
                              ),
                            ),
                            onTap: () => context.go(item.route),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        foregroundColor: isDark ? theme.colorScheme.primary : Colors.white,
                        side: BorderSide(
                            color: isDark
                                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.3)),
                      ),
                      onPressed: () => ref.read(authStateProvider.notifier).logout(),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  leading: leading,
                  title: Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(
                      color: isDark
                          ? const Color(0xFF334155).withValues(alpha: 0.3)
                          : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                      height: 1,
                    ),
                  ),
                  actions: [
                    ...?actions,
                    Container(
                      width: 260,
                      height: 38,
                      margin: const EdgeInsets.only(right: 16),
                      child: TextField(
                        readOnly: true,
                        onTap: () => _showSearchDialog(context, ref),
                        decoration: InputDecoration(
                          hintText: 'Search anything...',
                          hintStyle: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B)),
                          prefixIcon: const Icon(Icons.search_rounded, size: 16),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              'Ctrl + K',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : const Color(0xFF475569)),
                            ),
                          ),
                          filled: true,
                          fillColor:
                              isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF475569)
                                    : const Color(0xFFCBD5E1)),
                          ),
                        ),
                      ),
                    ),
                    // Notification Icon
                    PopupMenuButton<int>(
                      tooltip: 'Notifications',
                      icon: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                          if (notifCount > 0)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                    color: Colors.red, shape: BoxShape.circle),
                                constraints:
                                    const BoxConstraints(minWidth: 14, minHeight: 14),
                                child: Text(
                                  notifCount > 9 ? '9+' : '$notifCount',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      offset: const Offset(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      itemBuilder: (context) {
                        if (notifCount == 0) {
                          return [
                            PopupMenuItem(
                              enabled: false,
                              child: Text(
                                'No active alerts',
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    fontSize: 13),
                              ),
                            ),
                          ];
                        }
                        return [
                          PopupMenuItem(
                            enabled: false,
                            child: Text(
                              'Alerts & Notifications',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: Colors.red, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Attendance Defaulters',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text(
                                        '$notifCount student${notifCount == 1 ? '' : 's'} below ${AppConstants.defaulterThreshold.toInt()}% threshold.',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                      onSelected: (val) {
                        if (val == 1) context.go('/reports');
                      },
                    ),
                    const SizedBox(width: 12),
                    // User Profile Dropdown
                    PopupMenuButton<int>(
                      tooltip: 'User Menu',
                      offset: const Offset(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            enabled: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  user.role.name.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: [
                                Icon(
                                  themeMode == ThemeMode.system
                                      ? Icons.brightness_auto_rounded
                                      : (isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                                  size: 18,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  themeMode == ThemeMode.system
                                      ? 'Theme: Auto (System)'
                                      : (isDark ? 'Theme: Dark Mode' : 'Theme: Light Mode'),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Row(
                              children: [
                                const Icon(Icons.logout_rounded,
                                    size: 18, color: Colors.red),
                                const SizedBox(width: 12),
                                const Text('Logout',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ];
                      },
                      onSelected: (val) {
                        if (val == 1) cycleThemeMode();
                        if (val == 2) ref.read(authStateProvider.notifier).logout();
                      },
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
                body: body,
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile/Tablet Layout
      final usesBottomNav = user.role == UserRole.faculty;
      final bottomNavItems = usesBottomNav ? _getFacultyBottomNavItems() : null;
      int? currentBottomIndex;
      if (usesBottomNav && bottomNavItems != null) {
        currentBottomIndex = bottomNavItems.indexWhere((item) =>
            currentPath == item.route ||
            (item.route != '/faculty' && currentPath.startsWith(item.route)));
        if (currentBottomIndex < 0) currentBottomIndex = 0;
      }

      mainLayout = Scaffold(
        appBar: AppBar(
          leading: leading,
          title: Text(title),
          bottom: bottom,
          actions: actions ??
              [
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                  onPressed: toggleTheme,
                  tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () => ref.read(authStateProvider.notifier).logout(),
                ),
              ],
        ),
        drawer: usesBottomNav
            ? null
            : Drawer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UserAccountsDrawerHeader(
                      decoration: BoxDecoration(color: theme.colorScheme.primary),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                      ),
                      accountName:
                          Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      accountEmail: Text('${user.role.name.toUpperCase()} PORTAL'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: menuItems.length,
                        itemBuilder: (context, idx) {
                          final item = menuItems[idx];
                          final isSelected = currentPath == item.route;
                          return ListTile(
                            selected: isSelected,
                            selectedTileColor:
                                theme.colorScheme.primary.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            leading: Icon(item.icon),
                            title: Text(item.title,
                                style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                            onTap: () {
                              Navigator.pop(context);
                              context.go(item.route);
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        themeMode == ThemeMode.system
                            ? Icons.brightness_auto_rounded
                            : (isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                          themeMode == ThemeMode.system
                              ? 'Theme: Auto (System)'
                              : (isDark ? 'Theme: Dark Mode' : 'Theme: Light Mode'),
                          style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.pop(context);
                        cycleThemeMode();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Colors.red),
                      title: const Text('Logout',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(authStateProvider.notifier).logout();
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
        bottomNavigationBar: usesBottomNav && bottomNavItems != null
            ? BottomNavigationBar(
                currentIndex: currentBottomIndex ?? 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                onTap: (idx) => context.go(bottomNavItems[idx].route),
                items: bottomNavItems
                    .map((item) => BottomNavigationBarItem(
                          icon: Icon(item.icon),
                          label: item.title,
                        ))
                    .toList(),
              )
            : null,
        body: body,
      );
    }

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          _showSearchDialog(context, ref);
        },
      },
      child: Focus(
        autofocus: true,
        child: mainLayout,
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _SearchDialog(),
    );
  }

  List<_NavigationMenuItem> _getMenuItems(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [
          _NavigationMenuItem(
              title: 'Dashboard', icon: Icons.dashboard_rounded, route: '/admin'),
          _NavigationMenuItem(
              title: 'Academic Setup',
              icon: Icons.account_tree_rounded,
              route: '/admin/academic'),
          _NavigationMenuItem(
              title: 'Subjects Catalog',
              icon: Icons.library_books_rounded,
              route: '/admin/subjects'),
          _NavigationMenuItem(
              title: 'Faculty Members',
              icon: Icons.badge_rounded,
              route: '/admin/faculty'),
          _NavigationMenuItem(
              title: 'Faculty Assignments',
              icon: Icons.assignment_ind_rounded,
              route: '/admin/faculty-assignment'),
          _NavigationMenuItem(
              title: 'Student Directory',
              icon: Icons.face_rounded,
              route: '/admin/students'),
          _NavigationMenuItem(
              title: 'Semester Promotion',
              icon: Icons.upgrade_rounded,
              route: '/admin/promotion'),
          _NavigationMenuItem(
              title: 'Analytics & Reports',
              icon: Icons.analytics_rounded,
              route: '/reports'),
        ];
      case UserRole.faculty:
        return [
          _NavigationMenuItem(
              title: 'Dashboard', icon: Icons.dashboard_rounded, route: '/faculty'),
          _NavigationMenuItem(
              title: 'Mark Attendance',
              icon: Icons.add_task_rounded,
              route: '/faculty/mark-attendance'),
          _NavigationMenuItem(
              title: 'Edit Attendance',
              icon: Icons.edit_note_rounded,
              route: '/faculty/edit-attendance'),
          _NavigationMenuItem(
              title: 'Analytics & Reports',
              icon: Icons.analytics_rounded,
              route: '/reports'),
        ];
      case UserRole.student:
        return [
          _NavigationMenuItem(
              title: 'Dashboard', icon: Icons.dashboard_rounded, route: '/student'),
        ];
    }
  }

  List<_NavigationMenuItem> _getFacultyBottomNavItems() {
    return [
      _NavigationMenuItem(
          title: 'Dashboard', icon: Icons.dashboard_rounded, route: '/faculty'),
      _NavigationMenuItem(
          title: 'Mark', icon: Icons.add_task_rounded, route: '/faculty/mark-attendance'),
      _NavigationMenuItem(
          title: 'Edit', icon: Icons.edit_note_rounded, route: '/faculty/edit-attendance'),
      _NavigationMenuItem(
          title: 'Reports', icon: Icons.analytics_rounded, route: '/reports'),
    ];
  }
}

class _NavigationMenuItem {
  final String title;
  final IconData icon;
  final String route;
  _NavigationMenuItem({required this.title, required this.icon, required this.route});
}

class _SearchDialog extends ConsumerStatefulWidget {
  const _SearchDialog();
  @override
  ConsumerState<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends ConsumerState<_SearchDialog> {
  final _controller = TextEditingController();
  List<Student> _students = [];
  List<Faculty> _faculty = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(academicRepositoryProvider);
    final students = await repo.getStudents();
    final facultyList = await repo.getFaculty();
    if (mounted) {
      setState(() {
        _students = students;
        _faculty = facultyList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> results = [];

    final pages = [
      {'title': 'Admin Dashboard', 'route': '/admin', 'icon': Icons.dashboard_rounded},
      {
        'title': 'Academic Setup',
        'route': '/admin/academic',
        'icon': Icons.account_tree_rounded
      },
      {
        'title': 'Subjects Catalog',
        'route': '/admin/subjects',
        'icon': Icons.library_books_rounded
      },
      {'title': 'Faculty Members', 'route': '/admin/faculty', 'icon': Icons.badge_rounded},
      {
        'title': 'Faculty Assignments',
        'route': '/admin/faculty-assignment',
        'icon': Icons.assignment_ind_rounded
      },
      {
        'title': 'Student Directory',
        'route': '/admin/students',
        'icon': Icons.face_rounded
      },
      {
        'title': 'Semester Promotion',
        'route': '/admin/promotion',
        'icon': Icons.upgrade_rounded
      },
      {
        'title': 'Analytics & Reports',
        'route': '/reports',
        'icon': Icons.analytics_rounded
      },
      {
        'title': 'Faculty Dashboard',
        'route': '/faculty',
        'icon': Icons.dashboard_rounded
      },
      {
        'title': 'Mark Attendance',
        'route': '/faculty/mark-attendance',
        'icon': Icons.add_task_rounded
      },
      {
        'title': 'Edit Attendance',
        'route': '/faculty/edit-attendance',
        'icon': Icons.edit_note_rounded
      },
      {
        'title': 'Student Dashboard',
        'route': '/student',
        'icon': Icons.dashboard_rounded
      },
    ];

    final user = ref.read(authStateProvider).valueOrNull;
    final userRole = user?.role;

    final filteredPages = pages.where((p) {
      final titleMatches =
          p['title'].toString().toLowerCase().contains(_query.toLowerCase());
      if (!titleMatches) return false;
      final route = p['route'].toString();
      if (route.startsWith('/admin') && userRole != UserRole.admin) return false;
      if (route.startsWith('/faculty') && userRole != UserRole.faculty) return false;
      if (route.startsWith('/student') && userRole != UserRole.student) return false;
      return true;
    }).toList();

    if (filteredPages.isNotEmpty) {
      results.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text('NAVIGATION PAGES',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 0.5)),
      ));
      results.addAll(filteredPages.map((p) => ListTile(
            leading: Icon(p['icon'] as IconData, size: 20),
            title: Text(p['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
            onTap: () {
              Navigator.pop(context);
              context.go(p['route'] as String);
            },
          )));
    }

    if (!_isLoading) {
      if (userRole == UserRole.admin || userRole == UserRole.faculty) {
        final filteredStudents = _students
            .where((s) =>
                s.name.toLowerCase().contains(_query.toLowerCase()) ||
                s.rollNumber.toLowerCase().contains(_query.toLowerCase()))
            .toList();
        if (filteredStudents.isNotEmpty) {
          results.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('STUDENTS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5)),
          ));
          results.addAll(filteredStudents.take(5).map((s) => ListTile(
                leading:
                    const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 14)),
                title: Text(s.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text('Roll No: ${s.rollNumber}'),
                onTap: () {
                  Navigator.pop(context);
                  context.go(
                      userRole == UserRole.admin ? '/admin/students' : '/reports');
                },
              )));
        }
      }
      if (userRole == UserRole.admin) {
        final filteredFaculty = _faculty
            .where((f) =>
                f.name.toLowerCase().contains(_query.toLowerCase()) ||
                f.employeeId.toLowerCase().contains(_query.toLowerCase()))
            .toList();
        if (filteredFaculty.isNotEmpty) {
          results.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('FACULTY',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5)),
          ));
          results.addAll(filteredFaculty.take(5).map((f) => ListTile(
                leading:
                    const CircleAvatar(radius: 12, child: Icon(Icons.school, size: 14)),
                title: Text(f.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text('Employee ID: ${f.employeeId}'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/admin/faculty');
                },
              )));
        }
      }
    }

    if (results.isEmpty) {
      results.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
              const SizedBox(height: 12),
              Text('No matching results found',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            ],
          ),
        ),
      ));
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        height: 450,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Type to search...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _query = val),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(children: results),
            ),
          ],
        ),
      ),
    );
  }
}
