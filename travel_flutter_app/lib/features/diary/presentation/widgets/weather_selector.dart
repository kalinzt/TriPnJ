import 'package:flutter/material.dart';

/// 날씨 타입과 아이콘 매핑
enum WeatherType {
  sunny('sunny', '맑음', Icons.wb_sunny, Colors.orange),
  partlyCloudy('partly_cloudy', '구름조금', Icons.wb_cloudy, Colors.blueGrey),
  cloudy('cloudy', '흐림', Icons.cloud, Colors.grey),
  rainy('rainy', '비', Icons.umbrella, Colors.blue),
  snowy('snowy', '눈', Icons.ac_unit, Colors.lightBlue),
  windy('windy', '돌풍', Icons.air, Colors.teal);

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const WeatherType(this.value, this.label, this.icon, this.color);

  static WeatherType fromValue(String value) {
    return WeatherType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WeatherType.sunny,
    );
  }
}

/// 날씨 선택 위젯
class WeatherSelector extends StatelessWidget {
  final String selectedWeather;
  final Function(String) onWeatherSelected;

  const WeatherSelector({
    required this.selectedWeather,
    required this.onWeatherSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final selectedType = WeatherType.fromValue(selectedWeather);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '날씨',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: WeatherType.values.map((weather) {
            final isSelected = weather == selectedType;
            return InkWell(
              onTap: () => onWeatherSelected(weather.value),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 90,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? weather.color.withOpacity(0.2)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? weather.color : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      weather.icon,
                      color: isSelected ? weather.color : Colors.grey[600],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? weather.color : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
