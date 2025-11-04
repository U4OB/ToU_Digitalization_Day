import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Импортируем google_fonts

// 1. Определение пользовательских цветов
class AppColors {
  // Темный Фон: Доминирующий фон (Ультра-темный, почти черный)
  static const Color background = Color(0xFF10101C);
  // Фон Поверхностей/Карточек (немного светлее для выделения структуры)
  static const Color surface = Color(0xFF1E1E3F);
  // Акцентный Цвет 1: Яркий Циан (Голубой/Бирюзовый)
  static const Color accentCyan = Color(0xFF00E6FF);
  // Акцентный Цвет 2: Неоновый Зеленый (для градиентов CTA)
  static const Color accentNeonGreen = Color(0xFF1FFF7A);
  // Основной Текст: Белый или очень светлый
  static const Color primaryText = Colors.white;
  // Второстепенный Текст: Светло-серый
  static const Color secondaryText = Color(0xFFC0C0C0);
}

// 2. Определение стилей тем (Dark Theme)
class AppThemes {
  static ThemeData get darkTheme {
    // Используем ColorScheme для соответствия стилю Dark Mode
    final colorScheme = ColorScheme.dark(
      primary: AppColors.accentCyan,
      secondary: AppColors.accentNeonGreen,
      surface: AppColors.surface,
      error: Colors.red.shade400,
      onPrimary: AppColors.background, // Текст на primary кнопках
      onSecondary: AppColors.background, // Текст на secondary кнопках
      onSurface: AppColors.primaryText,
    );

    // 1. Базовая Тема
    final baseTheme = ThemeData.dark().copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
    );

    // 2. Применяем шрифт Ubuntu ко всем текстовым стилям
    final ubuntuTextTheme = GoogleFonts.pressStart2pTextTheme(
      baseTheme.textTheme,
    );

    // 3. Создаем финальную тему, переопределяя только необходимые стили
    return baseTheme.copyWith(
      // Устанавливаем семейство шрифтов для всей темы
      textTheme: ubuntuTextTheme.copyWith(
        // Переопределяем стили, где заданы акцентные цвета,
        // чтобы сохранить неоновый эффект и белый цвет текста

        // Акцентный цвет для заголовков (Cyan)
        headlineLarge: ubuntuTextTheme.headlineLarge?.copyWith(
          color: AppColors.accentCyan,
          fontWeight: FontWeight.bold,
        ),
        // Основной текст (White)
        displayLarge: ubuntuTextTheme.displayLarge?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: ubuntuTextTheme.displayMedium?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: ubuntuTextTheme.displaySmall?.copyWith(
          color: AppColors.primaryText,
        ),
        // Основной текст (White)
        headlineMedium: ubuntuTextTheme.headlineMedium?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: ubuntuTextTheme.headlineSmall?.copyWith(
          color: AppColors.primaryText,
        ),
        titleLarge: ubuntuTextTheme.titleLarge?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: ubuntuTextTheme.titleMedium?.copyWith(
          color: AppColors.primaryText,
        ),
        // Второстепенный текст (Light Gray)
        titleSmall: ubuntuTextTheme.titleSmall?.copyWith(
          color: AppColors.secondaryText,
        ),
        // Основной/Второстепенный текст
        bodyLarge: ubuntuTextTheme.bodyLarge?.copyWith(
          color: AppColors.primaryText,
        ),
        bodyMedium: ubuntuTextTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText,
        ),
        labelLarge: ubuntuTextTheme.labelLarge?.copyWith(
          color: AppColors.primaryText,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor:
            AppColors.primaryText, // Убеждаемся, что текст и иконки яркие
        elevation: 0, // Убираем тень для чистоты
        titleTextStyle: ubuntuTextTheme.titleLarge?.copyWith(
          color: AppColors.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.accentCyan,
        ), // Акцентный цвет для иконок в AppBar
      ),

      // Карточки/Секции (Закруглённые углы, тёмный фон)
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      // Нижняя панель навигации
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accentCyan,
        unselectedItemColor: AppColors.secondaryText,
        // Стиль текста Ubuntu
        selectedLabelStyle: ubuntuTextTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),

      // Кнопки (CTA)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentCyan,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          // Стиль текста Ubuntu
          textStyle: ubuntuTextTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: 8, // Небольшая тень для эффекта "свечения"
        ),
      ),

      // Ввод текста (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: ubuntuTextTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText,
        ),
        labelStyle: ubuntuTextTheme.bodyMedium?.copyWith(
          color: AppColors.accentCyan,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accentCyan, width: 2),
        ),
      ),

      // Иконки
      iconTheme: const IconThemeData(
        color: AppColors.secondaryText, // Дефолтный цвет для обычных иконок
      ),
    );
  }
}
