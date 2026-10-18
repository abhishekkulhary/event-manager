import 'package:flutter/material.dart';

/// Event Manager's palette: deep violet-black with a festive neon
/// magenta → amber accent, matching the app icon.
abstract final class EmColors {
  static const background = Color(0xFF0D0718);
  static const surface = Color(0xFF170E26);
  static const surfaceHigh = Color(0xFF221638);
  static const border = Color(0x1FFFFFFF);
  static const magenta = Color(0xFFFF4FD8);
  static const amber = Color(0xFFFFB347);
  static const mint = Color(0xFF4ADE80);
  static const coral = Color(0xFFFF6B6B);
  static const text = Color(0xFFF4EEFF);
  static const muted = Color(0xFFA99BC4);

  static const accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [magenta, amber],
  );
}

abstract final class EmTheme {
  static const font = 'SpaceGrotesk';

  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: EmColors.magenta,
      brightness: Brightness.dark,
    ).copyWith(
      primary: EmColors.magenta,
      onPrimary: EmColors.background,
      secondary: EmColors.amber,
      surface: EmColors.surface,
      onSurface: EmColors.text,
      onSurfaceVariant: EmColors.muted,
      outline: EmColors.border,
      error: EmColors.coral,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      fontFamily: font,
      scaffoldBackgroundColor: EmColors.background,
    );
    final text = base.textTheme.apply(bodyColor: EmColors.text, displayColor: EmColors.text);

    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c),
        );

    return base.copyWith(
      textTheme: text.copyWith(
        headlineLarge: text.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -1),
        headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -.5),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        bodyMedium: text.bodyMedium?.copyWith(color: EmColors.muted),
        bodySmall: text.bodySmall?.copyWith(color: EmColors.muted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontFamily: font, fontSize: 22, fontWeight: FontWeight.w700, color: EmColors.text),
        foregroundColor: EmColors.text,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EmColors.surface,
        labelStyle: const TextStyle(color: EmColors.muted),
        hintStyle: const TextStyle(color: EmColors.muted),
        prefixIconColor: EmColors.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border(EmColors.border),
        enabledBorder: border(EmColors.border),
        focusedBorder: border(EmColors.magenta),
        errorBorder: border(EmColors.coral),
        focusedErrorBorder: border(EmColors.coral),
      ),
      cardTheme: CardThemeData(
        color: EmColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: EmColors.border),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: EmColors.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: EmColors.border),
        ),
        textStyle: const TextStyle(fontFamily: font, color: EmColors.text),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: EmColors.surfaceHigh,
        contentTextStyle: const TextStyle(fontFamily: font, color: EmColors.text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: EmColors.border),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? EmColors.background : EmColors.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? EmColors.magenta : EmColors.surfaceHigh,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(EmColors.border),
      ),
      dividerColor: EmColors.border,
      iconTheme: const IconThemeData(color: EmColors.text),
    );
  }
}
