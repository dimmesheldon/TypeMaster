import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Fundo claro
  static const bg = Color(0xFFF4F6FB);
  static const bgCard = Color(0xFFFFFFFF);
  static const bgSurface = Color(0xFFECEFF8);
  static const bgElevated = Color(0xFFE4E9F5);

  // Primária — azul
  static const primary = Color(0xFF3B6EE8);
  static const primaryLight = Color(0xFF6B92F0);
  static const primaryDark = Color(0xFF2C55C8);

  // Acento — índigo
  static const accent = Color(0xFF7C4DFF);
  static const accentGlow = Color(0x187C4DFF);

  // Sucesso / erro / aviso
  static const success = Color(0xFF16A34A);
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFD97706);
  static const info = Color(0xFF0284C7);

  // Texto
  static const textPrimary = Color(0xFF1A202C);
  static const textSecondary = Color(0xFF4A5568);
  static const textMuted = Color(0xFF718096);
  static const textDisabled = Color(0xFFA0AEC0);

  // Bordas
  static const border = Color(0xFFE2E8F0);
  static const borderFocus = Color(0xFF3B6EE8);

  // Gradiente para destaque (sutil)
  static const gradientPrimary = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientDark = LinearGradient(
    colors: [bgCard, bgSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Cores dos dedos (vívidas para contraste no fundo claro)
  static const dedoMinimo = Color(0xFFEF4444);
  static const dedoAnelar = Color(0xFFF59E0B);
  static const dedoMedio = Color(0xFF10B981);
  static const dedoIndicador = Color(0xFF3B82F6);
  static const dedoPolegar = Color(0xFF84CC16);

  // Mãos
  static const maoEsquerda = Color(0xFF3B6EE8);
  static const maoDireita = Color(0xFF7C4DFF);

  // Níveis de dificuldade
  static const iniciante = Color(0xFF16A34A);
  static const medio = Color(0xFF0284C7);
  static const avancado = Color(0xFFD97706);
  static const hardcore = Color(0xFFDC2626);

  // Pele (para desenho das mãos)
  static const skin = Color(0xFFFFD4A8);
  static const skinDark = Color(0xFFE8B887);
  static const skinBorder = Color(0xFFD4976A);
}

class AppTextStyles {
  static TextStyle get display => GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get headline1 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get headline2 => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headline3 => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        color: AppColors.textMuted,
      );

  static TextStyle get mono => GoogleFonts.robotoMono(
        fontSize: 18,
        color: AppColors.textPrimary,
        letterSpacing: 1.5,
      );

  static TextStyle get monoLarge => GoogleFonts.robotoMono(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 2,
      );

  static TextStyle get wpm => GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      );

  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.6,
      );
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.bgCard,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display,
        headlineLarge: AppTextStyles.headline1,
        headlineMedium: AppTextStyles.headline2,
        headlineSmall: AppTextStyles.headline3,
        bodyLarge: AppTextStyles.body,
        bodySmall: AppTextStyles.bodySmall,
        labelSmall: AppTextStyles.label,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: AppColors.textMuted),
        hintStyle: GoogleFonts.poppins(color: AppColors.textDisabled),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.border,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        titleTextStyle: AppTextStyles.headline3,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.bgSurface,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgSurface,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
      ),
    );
  }

  // Mantém dark como fallback
  static ThemeData get dark => light;

  static Color corNivel(String nivel) {
    switch (nivel) {
      case 'iniciante': return AppColors.iniciante;
      case 'medio': return AppColors.medio;
      case 'avancado': return AppColors.avancado;
      case 'hardcore': return AppColors.hardcore;
      default: return AppColors.primary;
    }
  }

  static Color corDedo(String dedo) {
    switch (dedo) {
      case 'minimo': return AppColors.dedoMinimo;
      case 'anelar': return AppColors.dedoAnelar;
      case 'medio': return AppColors.dedoMedio;
      case 'indicador': return AppColors.dedoIndicador;
      case 'polegar': return AppColors.dedoPolegar;
      default: return AppColors.primary;
    }
  }
}
