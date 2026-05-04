import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String theme = 'Ultra Dark';
  String language = 'English';
  String selectedSportPreference = 'Football';
  bool hasCompletedOnboarding = false;
  
  Color primaryColor = const Color(0xFF39FF14);
  
  void setTheme(String newTheme) {
    theme = newTheme;
    if (theme == 'Cyberpunk') {
      primaryColor = const Color(0xFFBC13FE); // Neon Purple
    } else if (theme == 'Classic Dark') {
      primaryColor = const Color(0xFF5E60CE); // Deep Blue
    } else if (theme == 'BoxBox Neon') {
      primaryColor = const Color(0xFF00E5FF); // Cyan
    } else {
      primaryColor = const Color(0xFF39FF14); // Neon Green
    }
    notifyListeners();
  }

  void setLanguage(String newLang) {
    language = newLang;
    notifyListeners();
  }

  void setSportPreference(String sport) {
    selectedSportPreference = sport;
    hasCompletedOnboarding = true;
    notifyListeners();
  }

  String translate(String key) {
    final Map<String, Map<String, String>> translations = {
      'English': {
        'roster': 'ROSTER',
        'stats': 'STATS',
        'health': 'HEALTH',
        'leaders': 'LEADERS',
        'settings': 'SETTINGS',
        'vital_analytics': 'VITAL ANALYTICS',
        'performance_hub': 'PERFORMANCE HUB',
        'legends': 'LEGENDS',
        'global_leaderboard': 'GLOBAL LEADERBOARD',
        'formation': 'FORMATION',
      },
      'Spanish': {
        'roster': 'PLANTILLA',
        'stats': 'ESTADÍSTICAS',
        'health': 'SALUD',
        'leaders': 'LÍDERES',
        'settings': 'AJUSTES',
        'vital_analytics': 'ANÁLISIS VITAL',
        'performance_hub': 'CENTRO DE RENDIMIENTO',
        'legends': 'LEYENDAS',
        'global_leaderboard': 'TABLA GLOBAL',
        'formation': 'FORMACIÓN',
      },
    };
    return translations[language]?[key] ?? translations['English']![key] ?? key.toUpperCase();
  }
}

final appState = AppState();
