import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';

/// iOS-styled translucent glass bottom tab bar adaptive to ThemeMode
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabItem(
      path: '/home',
      icon: Icons.sunny_snowing,
      activeIcon: Icons.sunny,
      label: 'Погода',
    ),
    _TabItem(
      path: '/forecast',
      icon: Icons.calendar_view_week,
      activeIcon: Icons.calendar_month,
      label: 'Прогноз',
    ),
    _TabItem(
      path: '/outfit',
      icon: Icons.checkroom_outlined,
      activeIcon: Icons.checkroom,
      label: 'Гардероб',
    ),
    _TabItem(
      path: '/map',
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      label: 'Карта',
    ),
    _TabItem(
      path: '/favorites',
      icon: Icons.menu,
      activeIcon: Icons.menu_open,
      label: 'Города',
    ),
    _TabItem(
      path: '/settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Опции',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t.path));
    final settings = context.watch<SettingsViewModel>();

    final isDark = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final barBg = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.75);

    final barBorder = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.1);

    final activeColor = isDark ? const Color(0xFF64D2FF) : const Color(0xFF007AFF);
    final unselectedColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.45);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: barBg,
              border: Border(
                top: BorderSide(
                  color: barBorder,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _tabs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tab = entry.value;
                    final isSelected = index == (currentIndex < 0 ? 0 : currentIndex);

                    return Expanded(
                      child: InkWell(
                        onTap: () => context.go(tab.path),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelected ? tab.activeIcon : tab.icon,
                              color: isSelected ? activeColor : unselectedColor,
                              size: 23,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tab.label,
                              style: TextStyle(
                                color: isSelected ? activeColor : unselectedColor,
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
