import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/ios_glass_card.dart';

/// Settings screen designed with iOS Inset Grouped style, fully adaptive to Light & Dark themes
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    final isDark = vm.themeMode == ThemeMode.dark ||
        (vm.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final scaffoldBg = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final titleColor = isDark ? Colors.white : const Color(0xFF000000);
    final sectionTitleColor = isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF6C6C70);
    final rowTextColor = isDark ? Colors.white : const Color(0xFF000000);
    final rowSubtextColor = isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF8E8E93);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFC6C6C8).withValues(alpha: 0.4);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Text(
                  'Настройки',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // Section 1: Appearance
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IosSectionHeader('ОФОРМЛЕНИЕ И ТЕМА', color: sectionTitleColor),
                    IosGlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.palette_outlined, color: Color(0xFF007AFF), size: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Тема приложения',
                                    style: TextStyle(
                                      color: rowTextColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              DropdownButton<ThemeMode>(
                                value: vm.themeMode,
                                dropdownColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
                                underline: const SizedBox.shrink(),
                                icon: Icon(
                                  Icons.unfold_more,
                                  color: rowSubtextColor,
                                  size: 18,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: ThemeMode.system,
                                    child: Text('Авто', style: TextStyle(color: rowTextColor)),
                                  ),
                                  DropdownMenuItem(
                                    value: ThemeMode.light,
                                    child: Text('Светлая', style: TextStyle(color: rowTextColor)),
                                  ),
                                  DropdownMenuItem(
                                    value: ThemeMode.dark,
                                    child: Text('Темная', style: TextStyle(color: rowTextColor)),
                                  ),
                                ],
                                onChanged: (mode) {
                                  if (mode != null) vm.setThemeMode(mode);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section 2: Units
                    _IosSectionHeader('ЕДИНИЦЫ ИЗМЕРЕНИЯ', color: sectionTitleColor),
                    IosGlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.thermostat, color: Color(0xFFFF9500), size: 22),
                              const SizedBox(width: 12),
                              Text(
                                'Шкала температуры',
                                style: TextStyle(
                                  color: rowTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => vm.setTemperatureUnit(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: vm.isCelsius
                                        ? const Color(0xFF007AFF)
                                        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '°C',
                                    style: TextStyle(
                                      color: vm.isCelsius
                                          ? Colors.white
                                          : rowTextColor,
                                      fontWeight: vm.isCelsius ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => vm.setTemperatureUnit(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: !vm.isCelsius
                                        ? const Color(0xFF007AFF)
                                        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '°F',
                                    style: TextStyle(
                                      color: !vm.isCelsius
                                          ? Colors.white
                                          : rowTextColor,
                                      fontWeight: !vm.isCelsius ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section 3: Notifications
                    _IosSectionHeader('УВЕДОМЛЕНИЯ', color: sectionTitleColor),
                    IosGlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.notifications_active_outlined, color: Color(0xFF34C759), size: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Ежедневный совет',
                                    style: TextStyle(
                                      color: rowTextColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Switch.adaptive(
                                value: vm.notificationsEnabled,
                                activeTrackColor: const Color(0xFF34C759),
                                onChanged: vm.setNotificationsEnabled,
                              ),
                            ],
                          ),
                          if (vm.notificationsEnabled) ...[
                            Divider(color: dividerColor, height: 16),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.schedule, color: rowSubtextColor, size: 20),
                              title: Text(
                                'Время отправки',
                                style: TextStyle(color: rowTextColor, fontSize: 15),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFF007AFF).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${vm.notificationTime.hour.toString().padLeft(2, '0')}:${vm.notificationTime.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF64D2FF) : const Color(0xFF007AFF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: vm.notificationTime,
                                );
                                if (time != null) {
                                  await vm.setNotificationTime(time);
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section 4: About
                    _IosSectionHeader('О ПРИЛОЖЕНИИ', color: sectionTitleColor),
                    IosGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildIosInfoRow('Приложение', 'Weather & Outfit Advisor (iOS)', rowTextColor, rowSubtextColor),
                          Divider(color: dividerColor, height: 16),
                          _buildIosInfoRow('Версия', '1.0.0 (Build 2026.10)', rowTextColor, rowSubtextColor),
                          Divider(color: dividerColor, height: 16),
                          _buildIosInfoRow('Метеосервер', 'OpenWeatherMap API 2.5', rowTextColor, rowSubtextColor),
                          Divider(color: dividerColor, height: 16),
                          _buildIosInfoRow('Картография', 'OpenStreetMap / flutter_map', rowTextColor, rowSubtextColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IosSectionHeader extends StatelessWidget {
  const _IosSectionHeader(this.title, {required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

Widget _buildIosInfoRow(String label, String value, Color textColor, Color subtextColor) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(color: textColor, fontSize: 15)),
      Text(
        value,
        style: TextStyle(
          color: subtextColor,
          fontSize: 14,
        ),
      ),
    ],
  );
}
