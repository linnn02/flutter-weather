import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_outfit_advisor/ui/features/home/view_models/home_view_model.dart';
import 'package:weather_outfit_advisor/domain/use_cases/outfit_advisor_use_case.dart';
import 'package:weather_outfit_advisor/ui/features/settings/view_models/settings_view_model.dart';
import 'package:weather_outfit_advisor/ui/core/theme/app_theme.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/ios_glass_card.dart';

/// Full outfit recommendation screen with Apple HIG styling
class OutfitScreen extends StatelessWidget {
  const OutfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final outfit = vm.outfit;
    final weather = vm.weather;

    final settings = context.watch<SettingsViewModel>();
    final isForceDark = settings.themeMode == ThemeMode.dark;
    final isForceLight = settings.themeMode == ThemeMode.light;

    final gradient = weather != null
        ? AppTheme.getWeatherGradient(
            weather.weatherMain,
            weather.isDay,
            forceDark: isForceDark,
            forceLight: isForceLight,
          )
        : (isForceDark ? AppColors.darkSunnyGradient : AppColors.sunnyGradient);

    if (outfit == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F1A2C),
        appBar: AppBar(title: const Text('Рекомендации по одежде')),
        body: const Center(
          child: Text(
            'Загрузите погоду на главном экране',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // iOS-styled Navigation title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather != null ? weather.cityName : 'Гардероб',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Что надеть сегодня?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Summary Hero Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _OutfitSummaryCard(outfit: outfit),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Clothes List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _IosClothingTile(item: outfit.items[index]),
                    childCount: outfit.items.length,
                  ),
                ),
              ),

              // Tips Card
              if (outfit.tips.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    child: _IosTipsCard(tips: outfit.tips),
                  ),
                )
              else
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutfitSummaryCard extends StatelessWidget {
  const _OutfitSummaryCard({required this.outfit});

  final OutfitRecommendation outfit;

  String get _categoryTitle => switch (outfit.category) {
        OutfitCategory.hot => '🔥 ЖАРКАЯ ПОГОДА',
        OutfitCategory.warm => '☀️ ТЕПЛАЯ ПОГОДА',
        OutfitCategory.mild => '🌤️ КОМФОРТНО',
        OutfitCategory.cool => '🌬️ ПРОХЛАДНО',
        OutfitCategory.cold => '❄️ МОРОЗНО',
        OutfitCategory.veryCold => '🥶 СИЛЬНЫЙ МОРОЗ',
        OutfitCategory.rainy => '🌧️ ДОЖДЛИВО',
        OutfitCategory.snowy => '🌨️ СНЕГОПАД',
        OutfitCategory.stormy => '⛈️ ШТОРМ / ГРОЗА',
      };

  @override
  Widget build(BuildContext context) {
    return IosGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _categoryTitle,
            style: const TextStyle(
              color: Color(0xFF64D2FF),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            outfit.summary,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _IosClothingTile extends StatelessWidget {
  const _IosClothingTile({required this.item});

  final ClothingItem item;

  @override
  Widget build(BuildContext context) {
    return IosGlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IosTipsCard extends StatelessWidget {
  const _IosTipsCard({required this.tips});

  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return IosGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFFFD60A)),
              const SizedBox(width: 6),
              Text(
                'СОВЕТЫ ДНЯ',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFF64D2FF), fontSize: 16)),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
