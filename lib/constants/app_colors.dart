import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Gradient from deep purple to soft lavender
  static const Color primaryPurple = Color(0xFF6B46C1);
  static const Color primaryLavender = Color(0xFF9F7AEA);
  static const Color primaryLight = Color(0xFFE9D5FF);

  // Secondary Colors - Calming blues and teals
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color secondaryTeal = Color(0xFF14B8A6);
  static const Color secondaryLight = Color(0xFFE0F2FE);

  // Accent Colors - Warm and energizing
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentGreen = Color(0xFF10B981);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color onSurface = Color(0xFF1F2937);
  static const Color onSurfaceVariant = Color(0xFF6B7280);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Mood Colors for tracking
  static const Color moodExcellent = Color(0xFF10B981);
  static const Color moodGood = Color(0xFF3B82F6);
  static const Color moodNeutral = Color(0xFFF59E0B);
  static const Color moodBad = Color(0xFFEF4444);
  static const Color moodTerrible = Color(0xFF7C2D12);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryLavender],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryBlue, secondaryTeal],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentOrange, accentPink],
  );

  // Glassmorphism Colors
  static const Color glassBackground = Color(0x20FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);

  // Dark mode specific colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkOnSurfaceVariant = Color(0xFFB0B0B0);

  // Shadow Colors
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x1F000000);
}
