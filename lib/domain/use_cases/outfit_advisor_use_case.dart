import 'package:weather_outfit_advisor/domain/models/weather_model.dart';

/// Outfit recommendation based on weather conditions
class OutfitRecommendation {
  final String summary;
  final List<ClothingItem> items;
  final List<String> tips;
  final OutfitCategory category;

  const OutfitRecommendation({
    required this.summary,
    required this.items,
    required this.tips,
    required this.category,
  });
}

enum OutfitCategory {
  veryCold,
  cold,
  cool,
  mild,
  warm,
  hot,
  rainy,
  stormy,
  snowy,
}

class ClothingItem {
  final String name;
  final String emoji;
  final String description;

  const ClothingItem({
    required this.name,
    required this.emoji,
    required this.description,
  });
}

/// Business logic for outfit recommendations
class OutfitAdvisorUseCase {
  OutfitRecommendation getRecommendation(WeatherModel weather) {
    final temp = weather.temperature;
    final condition = weather.weatherMain.toLowerCase();
    final windSpeed = weather.windSpeed;

    // Priority: precipitation conditions first
    if (condition.contains('thunderstorm') || condition.contains('storm')) {
      return _stormyOutfit(temp);
    }
    if (condition.contains('snow') || condition.contains('blizzard')) {
      return _snowyOutfit(temp);
    }
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return _rainyOutfit(temp);
    }

    // Temperature-based with wind chill consideration
    final effectiveTemp = temp - (windSpeed > 5 ? (windSpeed - 5) * 0.5 : 0);

    if (effectiveTemp < -15) return _veryColdfOutfit();
    if (effectiveTemp < 0) return _coldOutfit();
    if (effectiveTemp < 10) return _coolOutfit();
    if (effectiveTemp < 18) return _mildOutfit();
    if (effectiveTemp < 25) return _warmOutfit();
    return _hotOutfit();
  }

  OutfitRecommendation _veryColdfOutfit() => const OutfitRecommendation(
        category: OutfitCategory.veryCold,
        summary: 'Экстремальный мороз! Одевайтесь как в Арктику',
        items: [
          ClothingItem(name: 'Термобельё', emoji: '🧣', description: 'Базовый слой из шерсти или синтетики'),
          ClothingItem(name: 'Свитер', emoji: '🧶', description: 'Толстый шерстяной свитер'),
          ClothingItem(name: 'Пуховик', emoji: '🧥', description: 'Очень тёплый пуховик или парка -30°C'),
          ClothingItem(name: 'Шапка-ушанка', emoji: '🎿', description: 'Закрывает уши и лоб'),
          ClothingItem(name: 'Шарф', emoji: '🧣', description: 'Обмотайте лицо'),
          ClothingItem(name: 'Варежки', emoji: '🧤', description: 'Варежки теплее перчаток'),
          ClothingItem(name: 'Валенки или унты', emoji: '👢', description: 'Утеплённая обувь'),
          ClothingItem(name: 'Термоноски', emoji: '🧦', description: 'Шерстяные термоноски'),
        ],
        tips: [
          'Не выходите без крайней необходимости',
          'Закрывайте открытые участки кожи',
          'Одевайтесь слоями — это эффективнее',
          'Возьмите термос с горячим напитком',
        ],
      );

  OutfitRecommendation _coldOutfit() => const OutfitRecommendation(
        category: OutfitCategory.cold,
        summary: 'Сильный мороз — одевайтесь тепло',
        items: [
          ClothingItem(name: 'Термобельё', emoji: '🩲', description: 'Тёплое нижнее бельё'),
          ClothingItem(name: 'Флисовый свитер', emoji: '🧶', description: 'Промежуточный утепляющий слой'),
          ClothingItem(name: 'Зимняя куртка', emoji: '🧥', description: 'Тёплая куртка с наполнителем'),
          ClothingItem(name: 'Зимняя шапка', emoji: '🎩', description: 'Обязательно покрывайте голову'),
          ClothingItem(name: 'Перчатки', emoji: '🧤', description: 'Тёплые перчатки или варежки'),
          ClothingItem(name: 'Зимние ботинки', emoji: '👢', description: 'Утеплённая непромокаемая обувь'),
          ClothingItem(name: 'Тёплые брюки', emoji: '👖', description: 'Утеплённые штаны'),
        ],
        tips: [
          'Надевайте шапку — через голову уходит 30% тепла',
          'Избегайте хлопка — он удерживает влагу',
          'Шарф поможет защитить горло',
        ],
      );

  OutfitRecommendation _coolOutfit() => const OutfitRecommendation(
        category: OutfitCategory.cool,
        summary: 'Прохладно — нужна куртка',
        items: [
          ClothingItem(name: 'Свитер или толстовка', emoji: '👕', description: 'Плотный верхний слой'),
          ClothingItem(name: 'Лёгкая куртка', emoji: '🧥', description: 'Ветровка или демисезонная куртка'),
          ClothingItem(name: 'Лёгкая шапка', emoji: '🧢', description: 'По желанию, если ветрено'),
          ClothingItem(name: 'Джинсы или брюки', emoji: '👖', description: 'Плотные брюки'),
          ClothingItem(name: 'Кроссовки или ботинки', emoji: '👟', description: 'Закрытая обувь'),
        ],
        tips: [
          'Возьмите куртку на случай похолодания',
          'Вечером будет холоднее',
        ],
      );

  OutfitRecommendation _mildOutfit() => const OutfitRecommendation(
        category: OutfitCategory.mild,
        summary: 'Комфортная температура',
        items: [
          ClothingItem(name: 'Футболка или рубашка', emoji: '👕', description: 'Лёгкий верхний слой'),
          ClothingItem(name: 'Лёгкая кофта', emoji: '🧣', description: 'На случай если прохладно'),
          ClothingItem(name: 'Джинсы или брюки', emoji: '👖', description: 'Обычные брюки'),
          ClothingItem(name: 'Кроссовки', emoji: '👟', description: 'Удобная обувь'),
        ],
        tips: [
          'Идеальная погода для прогулок',
          'Возьмите лёгкую кофту на вечер',
        ],
      );

  OutfitRecommendation _warmOutfit() => const OutfitRecommendation(
        category: OutfitCategory.warm,
        summary: 'Тепло и приятно',
        items: [
          ClothingItem(name: 'Футболка', emoji: '👕', description: 'Лёгкая хлопковая футболка'),
          ClothingItem(name: 'Лёгкие брюки или шорты', emoji: '🩳', description: 'По настроению'),
          ClothingItem(name: 'Кроссовки или сандалии', emoji: '👟', description: 'Лёгкая обувь'),
          ClothingItem(name: 'Солнцезащитные очки', emoji: '😎', description: 'Защита от солнца'),
        ],
        tips: [
          'Используйте солнцезащитный крем',
          'Носите головной убор в солнечную погоду',
          'Пейте больше воды',
        ],
      );

  OutfitRecommendation _hotOutfit() => const OutfitRecommendation(
        category: OutfitCategory.hot,
        summary: 'Жарко! Одевайтесь легко',
        items: [
          ClothingItem(name: 'Лёгкая футболка', emoji: '👕', description: 'Дышащая ткань'),
          ClothingItem(name: 'Шорты', emoji: '🩳', description: 'Лёгкие шорты'),
          ClothingItem(name: 'Сандалии или шлёпанцы', emoji: '🩴', description: 'Открытая обувь'),
          ClothingItem(name: 'Шляпа или кепка', emoji: '🧢', description: 'Защита от солнца'),
          ClothingItem(name: 'Солнцезащитные очки', emoji: '😎', description: 'Обязательно!'),
        ],
        tips: [
          'Носите светлую одежду — она отражает солнце',
          'Пейте воду каждые 20–30 минут',
          'Используйте крем SPF 50+',
          'Избегайте прямых солнечных лучей в 12–15 ч',
        ],
      );

  OutfitRecommendation _rainyOutfit(double temp) => OutfitRecommendation(
        category: OutfitCategory.rainy,
        summary: 'Дождь — берите зонт!',
        items: [
          ClothingItem(
            name: temp < 10 ? 'Тёплая куртка-дождевик' : 'Лёгкий дождевик',
            emoji: '🧥',
            description: 'Водонепроницаемый верхний слой',
          ),
          const ClothingItem(name: 'Зонт', emoji: '☂️', description: 'Компактный или складной'),
          const ClothingItem(name: 'Водонепроницаемая обувь', emoji: '👢', description: 'Резиновые сапоги или влагостойкие ботинки'),
          const ClothingItem(name: 'Запасные носки', emoji: '🧦', description: 'На случай промокания'),
        ],
        tips: [
          'Промокшая одежда охлаждает быстрее — будьте осторожны',
          'Носите яркий дождевик — водители лучше видят',
          'Проверьте прогноз — может просто небольшой дождик',
        ],
      );

  OutfitRecommendation _snowyOutfit(double temp) => const OutfitRecommendation(
        category: OutfitCategory.snowy,
        summary: 'Снегопад — одевайтесь тепло и непромокаемо',
        items: [
          ClothingItem(name: 'Термобельё', emoji: '🩲', description: 'Базовый тёплый слой'),
          ClothingItem(name: 'Зимняя куртка', emoji: '🧥', description: 'Тёплая и водонепроницаемая'),
          ClothingItem(name: 'Зимние сапоги', emoji: '👢', description: 'Высокие непромокаемые сапоги'),
          ClothingItem(name: 'Шапка', emoji: '🎩', description: 'Обязательно'),
          ClothingItem(name: 'Перчатки', emoji: '🧤', description: 'Непромокаемые перчатки'),
          ClothingItem(name: 'Зонт или капюшон', emoji: '☂️', description: 'Защита от снега сверху'),
        ],
        tips: [
          'Осторожно — скользко!',
          'Выберите обувь с хорошим протектором',
          'Снег на одежде тает — используйте влагозащитную пропитку',
        ],
      );

  OutfitRecommendation _stormyOutfit(double temp) => const OutfitRecommendation(
        category: OutfitCategory.stormy,
        summary: 'Гроза! Лучше остаться дома',
        items: [
          ClothingItem(name: 'Надёжный дождевик', emoji: '🧥', description: 'Полностью водонепроницаемый'),
          ClothingItem(name: 'Резиновые сапоги', emoji: '👢', description: 'Высокие, непромокаемые'),
          ClothingItem(name: 'Плотная одежда', emoji: '👕', description: 'Несколько слоёв'),
        ],
        tips: [
          'По возможности оставайтесь дома',
          'Не пользуйтесь зонтом при грозе!',
          'Избегайте высоких мест и деревьев',
          'Держитесь подальше от воды',
        ],
      );
}
