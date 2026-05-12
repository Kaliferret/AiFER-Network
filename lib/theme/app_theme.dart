import 'package:flutter/material.dart';
import '../core/color_polyfill.dart';
import 'package:google_fonts/google_fonts.dart';

/// FER Network — Official Theme
///
/// Palette = Claude backend `FERColors` + base44 dashboard tile accents.
/// Dark-first, mobile-first, gamified.
///
///   FERColors (protocol palette):
///     primary       #00FF88   FER green
///     primaryDark   #00CC66
///     accent        #FF006E   hot pink
///     secondary     #00CCFF   cyan
///     background    #1A1A1A   near-black
///     surface       #2A2A2A   card dark-grey
///
///   Tile accents (base44 dashboard):
///     tileBlue      #3B82F6   New Message
///     tilePink      #EC4899   Browse Market
///     tileGreen     #10B981   Play Games
///     tilePurple    #8B5CF6   AI Assistant
///     balanceOrange #F97316   Balance card icon
class AppTheme {
  AppTheme._();

  // ── Protocol palette ─────────────────────────────────────────
  static const Color primary = Color(0xFF00FF88);
  static const Color primaryDark = Color(0xFF00CC66);
  static const Color accent = Color(0xFFFF006E);
  static const Color secondary = Color(0xFF00CCFF);

  // ── Surfaces ─────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0A0A); // screenshot is near-black
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF2A2A2A);
  static const Color divider = Color(0xFF2A2A2A);

  // ── Tile / action accents ────────────────────────────────────
  static const Color tileBlue = Color(0xFF3B82F6);
  static const Color tilePink = Color(0xFFEC4899);
  static const Color tileGreen = Color(0xFF10B981);
  static const Color tilePurple = Color(0xFF8B5CF6);
  static const Color balanceOrange = Color(0xFFF97316);

  // ── State colours ────────────────────────────────────────────
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF71717A);

  // Backwards-compat aliases (old code references these names)
  static const Color primaryLight = primary;
  static const Color secondaryLight = secondary;
  static const Color secondaryDark = primaryDark;
  static const Color accentColor = accent;
  static const Color backgroundLight = background;
  static const Color backgroundDark = background;
  static const Color surfaceLight = surface;
  static const Color surfaceDark = surface;
  static const Color cardLight = surfaceElevated;
  static const Color cardDark = surfaceElevated;
  static const Color dialogLight = surfaceElevated;
  static const Color dialogDark = surfaceElevated;
  static const Color shadowLight = Color(0x3F000000);
  static const Color shadowDark = Color(0x3F000000);
  static const Color dividerLight = divider;
  static const Color dividerDark = divider;
  static const Color textPrimaryDark = textPrimary;
  static const Color textSecondaryDark = textSecondary;

  // ── Tile accent list (for dashboards) ────────────────────────
  static const List<Color> tilePalette = [
    tileBlue,
    tilePink,
    tileGreen,
    tilePurple,
  ];

  // ── Themes ────────────────────────────────────────────────────

  static ThemeData darkTheme = _build();
  static ThemeData lightTheme = _build(); // dark-first; light falls back to same

  static ThemeData _build() {
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Color(0xFF002E14),
      primaryContainer: Color(0xFF003E1C),
      onPrimaryContainer: primary,
      secondary: accent,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF3F001C),
      onSecondaryContainer: accent,
      tertiary: secondary,
      onTertiary: Color(0xFF00202E),
      tertiaryContainer: Color(0xFF003A52),
      onTertiaryContainer: secondary,
      error: errorColor,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: divider,
      outlineVariant: Color(0xFF3A3A3A),
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: textPrimary,
      onInverseSurface: background,
      inversePrimary: primaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: surfaceElevated,
      dividerColor: divider,
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // AppBar — flat, base44 style
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 24),
        actionsIconTheme: const IconThemeData(color: textPrimary, size: 22),
      ),

      // Cards — rounded 20 px, deep surface
      cardTheme: CardThemeData(
        color: surfaceElevated,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Bottom nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500),
      ),

      // FAB — FER green
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Color(0xFF002E14),
        elevation: 4,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color(0xFF002E14),
          backgroundColor: primary,
          disabledBackgroundColor: surfaceElevated,
          disabledForegroundColor: textTertiary,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: divider, width: 1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Typography
      textTheme: _buildTextTheme(),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        fillColor: surfaceElevated,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.inter(
            color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.inter(
            color: textTertiary, fontSize: 14, fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
      ),

      // Checkbox / switch / slider — accent in primary
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return surfaceElevated;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFF002E14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: divider, width: 1.5),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.4);
          }
          return surfaceElevated;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: surfaceElevated,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.2),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: primary),

      // Tab bar
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(color: primary, width: 2),
          borderRadius: BorderRadius.circular(2),
        ),
        labelStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500),
      ),

      // Snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: GoogleFonts.inter(
            color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Dividers
      dividerTheme:
          const DividerThemeData(color: divider, thickness: 1, space: 1),

      // Icon theme
      iconTheme: const IconThemeData(color: textPrimary, size: 24),
    );
  }

  /// Google Fonts Inter text scale, mobile-appropriate.
  static TextTheme _buildTextTheme({bool isLight = false}) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
          fontSize: 36, fontWeight: FontWeight.w700, color: textPrimary),
      displayMedium: base.displayMedium?.copyWith(
          fontSize: 30, fontWeight: FontWeight.w700, color: textPrimary),
      displaySmall: base.displaySmall?.copyWith(
          fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary),
      headlineLarge: base.headlineLarge?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
      headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
      headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: base.titleLarge?.copyWith(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: base.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      titleSmall: base.titleSmall?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: base.bodyLarge?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
      bodyMedium: base.bodyMedium?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
      bodySmall: base.bodySmall?.copyWith(
          fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary),
      labelLarge: base.labelLarge?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      labelMedium: base.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5),
      labelSmall: base.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textTertiary,
          letterSpacing: 0.6),
    );
  }

  // ── Legacy helpers retained for existing widgets ───────────────────
  // These were referenced by network_status_bar.dart, chat_message_item.dart,
  // etc. Kept here so the Phase-6 wiring work doesn't have to touch widget
  // code that's already doing the right thing visually.

  static Color getNetworkStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
      case 'online':
      case 'active':
        return primary; // FER green
      case 'connecting':
      case 'syncing':
      case 'hopping':
        return secondary; // cyan
      case 'weak':
      case 'degraded':
        return balanceOrange;
      case 'disconnected':
      case 'offline':
      case 'error':
      case 'failed':
        return accent; // hot pink
      default:
        return textTertiary;
    }
  }

  static Color getPackageTypeColor(String packageType) {
    switch (packageType) {
      case '.AiFp':
      case '.aif':
        return primary; // quantum-packaged
      case 'encrypted':
        return secondary;
      case 'plain':
        return textTertiary;
      default:
        return textSecondary;
    }
  }

  static TextStyle getMonospaceStyle({
    bool isLight = false, // legacy param kept for backward compat with older widgets
    double fontSize = 12,
    Color? color,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      letterSpacing: 0.2,
    );
  }
}
