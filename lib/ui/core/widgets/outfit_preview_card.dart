import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:weather_outfit_advisor/domain/use_cases/outfit_advisor_use_case.dart';
import 'package:weather_outfit_advisor/ui/core/widgets/ios_glass_card.dart';

/// Apple-styled Outfit Advisor Widget Card
class OutfitPreviewCard extends StatelessWidget {
  const OutfitPreviewCard({super.key, required this.outfit});

  final OutfitRecommendation outfit;

  @override
  Widget build(BuildContext context) {
    final topItems = outfit.items.take(3).toList();

    return GestureDetector(
      onTap: () => context.go('/outfit'),
      child: IosGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Apple-style caption
            Row(
              children: [
                Icon(
                  Icons.checkroom,
                  size: 15,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 6),
                Text(
                  'РЕКОМЕНДАЦИЯ ПО ОДЕЖДЕ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'Подробнее',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Summary description
            Text(
              outfit.summary,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Item Pills
            Row(
              children: topItems.map((item) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          item.name,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (outfit.items.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    '+${outfit.items.length - 3} ещё предмета — нажмите для полного списка',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
