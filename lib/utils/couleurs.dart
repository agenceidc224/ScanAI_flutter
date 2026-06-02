// colors.dart - Version Médicale & Imagerie avec police Chillax
// Compatible Flutter 3.41+
import 'package:flutter/material.dart';

class AppColors {
  // ============ COULEURS PRINCIPALES (6 max) ============

  // 1. Bleu médical profond - Confiance, technologie, imagerie
  static const Color primary = Color(0xFF1A73E8);

  // 2. Bleu cyan - Imagerie, numérisation, diagnostic
  static const Color secondary = Color(0xFF00B4D8);

  // 3. Fond blanc cassé - Propreté, hôpital, clarté (mode clair)
  static const Color background = Color(0xFFF8F9FA);

  // 3b. Fond sombre - Pour mode sombre
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);

  // 4. Texte principal - Gris foncé pour meilleure lisibilité (mode clair)
  static const Color textPrimary = Color(0xFF202124);

  // 4b. Texte principal mode sombre
  static const Color darkTextPrimary = Color(0xFFE8EAED);

  // 5. Texte secondaire - Gris médical (mode clair)
  static const Color textSecondary = Color(0xFF5F6368);

  // 5b. Texte secondaire mode sombre
  static const Color darkTextSecondary = Color(0xFF9AA0A6);

  // 6. Accent vert santé - Vitalité, résultats positifs
  static const Color accent = Color(0xFF34A853);

  // ============ COULEURS FONCTIONNELLES MÉDICALES ============

  // Succès - Résultat normal, examen validé
  static const Color success = Color(0xFF34A853);

  // Erreur - Anomalie détectée, urgent
  static const Color error = Color(0xFFEA4335);

  // Attention - Résultat limite, contrôle recommandé
  static const Color warning = Color(0xFFFBBC04);

  // Information - Information complémentaire
  static const Color info = Color(0xFF4285F4);

  // ============ COULEURS SPÉCIFIQUES À L'IMAGERIE MÉDICALE ============

  // Scanner/IRM - Pour les sections imagerie
  static const Color imaging = Color(0xFF0066B3);

  // Rayons X - Pour radiologie
  static const Color radiology = Color(0xFF4A90E2);

  // Échographie - Pour sonographie
  static const Color ultrasound = Color(0xFF50C878);

  // DPI/Dossier patient - Pour données patient
  static const Color patientRecord = Color(0xFF7C4DFF);

  // ============ NUANCES DE BLEU MÉDICAL ============

  static const Color medicalBlue = Color(0xFF1565C0);
  static const Color medicalLightBlue = Color(0xFF64B5F6);
  static const Color medicalDarkBlue = Color(0xFF0D47A1);
  static const Color medicalCyan = Color(0xFF00ACC1);

  // ============ COULEURS MÉDICALES SPÉCIFIQUES ============

  // Urgence - Rouge sang
  static const Color emergency = Color(0xFFD32F2F);

  // Guérison/Rétabli - Vert hôpital
  static const Color healed = Color(0xFF2E7D32);

  // En traitement - Orange
  static const Color treatment = Color(0xFFF57C00);

  // Critique - Rouge foncé
  static const Color critical = Color(0xFFC62828);

  // ============ COULEURS POUR RADIOLOGIE ET IMAGES ============

  // Noir médical pour visualisation des images radio
  static const Color radiologyBlack = Color(0xFF1A1A1A);

  // Blanc médical pour luminosité optimale
  static const Color radiologyWhite = Color(0xFFF5F5F5);

  // Niveaux de gris pour les images médicales
  static const Color grayScale0 = Color(0xFF000000); // Noir
  static const Color grayScale1 = Color(0xFF333333);
  static const Color grayScale2 = Color(0xFF666666);
  static const Color grayScale3 = Color(0xFF999999);
  static const Color grayScale4 = Color(0xFFCCCCCC);
  static const Color grayScale5 = Color(0xFFFFFFFF); // Blanc

  // ============ COULEURS NEUTRES COMPLÉMENTAIRES ============

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);

  // Couleur de séparation (lignes fines)
  static const Color divider = Color(0xFFE8EAED);
  static const Color darkDivider = Color(0xFF3C4043);

  // ============ VERSIONS TRANSPARENTES DES COULEURS ============

  // Transparent avec différentes opacités
  static const Color transparent = Colors.transparent;

  // Versions transparentes des couleurs principales
  static Color get primaryTransparent => primary.withValues(alpha: 0.2);
  static Color get secondaryTransparent => secondary.withValues(alpha: 0.2);
  static Color get successTransparent => success.withValues(alpha: 0.2);
  static Color get errorTransparent => error.withValues(alpha: 0.2);
  static Color get warningTransparent => warning.withValues(alpha: 0.2);
  static Color get infoTransparent => info.withValues(alpha: 0.2);
  static Color get accentTransparent => accent.withValues(alpha: 0.2);

  // Versions très transparentes (10%)
  static Color get primaryLight => primary.withValues(alpha: 0.1);
  static Color get secondaryLight => secondary.withValues(alpha: 0.1);
  static Color get successLight => success.withValues(alpha: 0.1);
  static Color get errorLight => error.withValues(alpha: 0.1);

  // Versions semi-transparentes (50%)
  static Color get primaryMedium => primary.withValues(alpha: 0.5);
  static Color get secondaryMedium => secondary.withValues(alpha: 0.5);
  static Color get blackMedium => black.withValues(alpha: 0.5);
  static Color get whiteMedium => white.withValues(alpha: 0.5);

  // ============ MÉTHODES UTILITAIRES ============

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  // Méthode pour obtenir une couleur avec une transparence spécifique
  static Color getTransparent(Color color, {double opacity = 0.2}) {
    return color.withValues(alpha: opacity);
  }

  // Obtenir la couleur de texte selon le thème
  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? darkTextPrimary : textPrimary;
  }

  // Obtenir la couleur de texte secondaire selon le thème
  static Color getSecondaryTextColor(bool isDarkMode) {
    return isDarkMode ? darkTextSecondary : textSecondary;
  }

  // Obtenir la couleur de fond selon le thème
  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? darkBackground : background;
  }

  // Obtenir la couleur de carte selon le thème
  static Color getCardColor(bool isDarkMode) {
    return isDarkMode ? darkCard : white;
  }

  // Obtenir la couleur de surface selon le thème
  static Color getSurfaceColor(bool isDarkMode) {
    return isDarkMode ? darkSurface : lightGrey;
  }

  // Palette pour thème Material
  static const Map<String, Color> colorMap = {
    'primary': primary,
    'secondary': secondary,
    'background': background,
    'textPrimary': textPrimary,
    'textSecondary': textSecondary,
    'accent': accent,
    'success': success,
    'error': error,
    'warning': warning,
    'info': info,
    'imaging': imaging,
    'radiology': radiology,
    'ultrasound': ultrasound,
    'patientRecord': patientRecord,
    'emergency': emergency,
    'critical': critical,
  };
}

// ============ THÈME MÉDICAL COMPLET AVEC POLICE CHILLAX ============
class AppTheme {
  // Définition de la police Chillax
  static const String chillaxFont = 'Chillax';

  // ============ THÈME CLAIR ============
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Police par défaut
      fontFamily: chillaxFont,

      // Couleurs principales
      primaryColor: AppColors.primary,
      hintColor: AppColors.info,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,

      // Card theme
      cardColor: AppColors.white,
      // ColorScheme médical
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.white,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onError: AppColors.white,
        primaryContainer: AppColors.primaryLight,
        secondaryContainer: AppColors.secondaryLight,
      ),

      // AppBar médicale
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Navigation Rail
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.white,
        selectedIconTheme: IconThemeData(color: AppColors.primary),
        unselectedIconTheme: IconThemeData(color: AppColors.grey),
        selectedLabelTextStyle: TextStyle(color: AppColors.primary),
        unselectedLabelTextStyle: TextStyle(color: AppColors.grey),
      ),

      // Textes médicaux avec police Chillax
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.grey,
          fontSize: 11,
        ),
      ),

      // Boutons médicaux
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: chillaxFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Boutons secondaires
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: chillaxFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Cartes médicales
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // Inputs médicaux
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.grey,
        ),
      ),

      // Dialogues médicaux
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        titleTextStyle: const TextStyle(
          fontFamily: chillaxFont,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: chillaxFont,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),

      // Chips pour filtres
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGrey,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        secondarySelectedColor: AppColors.secondary.withValues(alpha: 0.2),
        labelStyle: const TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.grey.withValues(alpha: 0.3);
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
      ),
    );
  }

  // ============ THÈME SOMBRE ============
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Police par défaut
      fontFamily: chillaxFont,

      // Couleurs principales
      primaryColor: AppColors.primary,
      hintColor: AppColors.info,
      scaffoldBackgroundColor: AppColors.darkBackground,
      dividerColor: AppColors.darkDivider,

      // Card theme
      cardColor: AppColors.darkCard,

      // ColorScheme sombre
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.white,
        primaryContainer: AppColors.medicalDarkBlue,
        secondaryContainer: AppColors.medicalCyan,
      ),

      // AppBar sombre
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Navigation Bar sombre
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Navigation Rail sombre
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedIconTheme: IconThemeData(color: AppColors.primary),
        unselectedIconTheme: IconThemeData(color: AppColors.darkGrey),
        selectedLabelTextStyle: TextStyle(color: AppColors.primary),
        unselectedLabelTextStyle: TextStyle(color: AppColors.darkGrey),
      ),

      // Textes médicaux avec police Chillax (version sombre)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextPrimary,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextSecondary,
          fontSize: 12,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextSecondary,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkGrey,
          fontSize: 11,
        ),
      ),

      // Boutons médicaux (version sombre)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: chillaxFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Boutons secondaires (version sombre)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: chillaxFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Cartes médicales (version sombre)
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // Inputs médicaux (version sombre)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkGrey.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkGrey.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextSecondary,
        ),
        hintStyle: const TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkGrey,
        ),
      ),

      // Dialogues médicaux (version sombre)
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        titleTextStyle: const TextStyle(
          fontFamily: chillaxFont,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: chillaxFont,
          fontSize: 14,
          color: AppColors.darkTextSecondary,
        ),
      ),

      // Chips pour filtres (version sombre)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.primary.withValues(alpha: 0.3),
        secondarySelectedColor: AppColors.secondary.withValues(alpha: 0.3),
        labelStyle: const TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.darkTextPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Switch (version sombre)
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.darkGrey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.darkGrey.withValues(alpha: 0.3);
        }),
      ),

      // Checkbox (version sombre)
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio (version sombre)
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
      ),
    );
  }

  // ============ THÈME POUR LA VISUALISATION D'IMAGES ============
  static ThemeData get imageViewerTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: chillaxFont,
      scaffoldBackgroundColor: AppColors.radiologyBlack,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.radiologyBlack,
        error: AppColors.error,
        onSurface: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.white,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: chillaxFont,
          color: AppColors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  // ============ GETTER PRATIQUE POUR LE THÈME ACTUEL ============
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }
}

// ============ EXTENSION POUR FACILITER L'UTILISATION ============
extension AppColorsExtension on BuildContext {
  AppColors get colors => AppColors();

  ThemeData get theme => Theme.of(this);

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get primaryColor => Theme.of(this).primaryColor;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get errorColor => Theme.of(this).colorScheme.error;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;

  // Couleurs adaptées au thème
  Color get backgroundColor =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;
  Color get cardColor => isDarkMode ? AppColors.darkCard : AppColors.white;
  Color get textPrimaryColor =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get textSecondaryColor =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get dividerColor =>
      isDarkMode ? AppColors.darkDivider : AppColors.divider;

  // Getters pour les versions transparentes
  Color get primaryTransparent => AppColors.primaryTransparent;
  Color get secondaryTransparent => AppColors.secondaryTransparent;
  Color get successTransparent => AppColors.successTransparent;
  Color get errorTransparent => AppColors.errorTransparent;

  // Padding responsive basé sur la taille d'écran
  EdgeInsets get responsivePadding {
    final width = MediaQuery.of(this).size.width;
    if (width >= 1200) return const EdgeInsets.all(32);
    if (width >= 800) return const EdgeInsets.all(24);
    return const EdgeInsets.all(16);
  }
}

// ============ WIDGET POUR APERÇU DES COULEURS ============
class ColorPreviewWidget extends StatelessWidget {
  const ColorPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final bgColor = context.backgroundColor;
    final textColor = context.textPrimaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      color: bgColor,
      child: Column(
        children: [
          Text(
            'Couleurs avec transparence',
            style: TextStyle(
              fontFamily: AppTheme.chillaxFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildColorChip(
                context,
                'Primary',
                AppColors.primary,
                AppColors.primaryTransparent,
              ),
              _buildColorChip(
                context,
                'Secondary',
                AppColors.secondary,
                AppColors.secondaryTransparent,
              ),
              _buildColorChip(
                context,
                'Success',
                AppColors.success,
                AppColors.successTransparent,
              ),
              _buildColorChip(
                context,
                'Error',
                AppColors.error,
                AppColors.errorTransparent,
              ),
              _buildColorChip(
                context,
                'Warning',
                AppColors.warning,
                AppColors.warningTransparent,
              ),
              _buildColorChip(
                context,
                'Info',
                AppColors.info,
                AppColors.infoTransparent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(
    BuildContext context,
    String label,
    Color solid,
    Color transparent,
  ) {
    final textColor = context.textPrimaryColor;

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: solid,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontFamily: AppTheme.chillaxFont,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
