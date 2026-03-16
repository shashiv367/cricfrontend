import 'package:flutter/material.dart';

/// App color palette. Change colors here to update the app theme.
class AppColors {
  // Main Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  // Default page background: light base + pastel purple & pink blurs
  static const Color scaffoldSurface = Color(0xFFF5F3FF);
  static const Color blurShapeLightPurple = Color(0xFFDDD0F0);
  static const Color blurShapeLightPink = Color(0xFFF5D8E0);
  static const Color blurShapeLightAqua = Color(0xFFE0F2F0);

  // Primary (app bars, main actions, selected states)
  static const Color primaryElectric = Color(0xFF6D28D9);
  static const Color primaryElectricLight = Color(0xFF8B5CF6);
  static const Color primaryPurpleDark = Color(0xFF5B21B6);

  // Secondary / accent (leaderboard bar, live, CTAs)
  static const Color accentSunset = Color(0xFFF43F5E);
  static const Color accentTeal = Color(0xFF00A381);
  static const Color accentGlow = Color(0xFFFB923C);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentYellow = Color(0xFFF59E0B);

  // App bar variants (use primaryElectric for most screens; accentRed for leaderboard-style)
  static const Color appBarPrimary = Color(0xFF6D28D9);
  static const Color appBarRed = Color(0xFFB91C1C);
  static const Color promoTitle = Color(0xFF8B4512);

  // Aliases
  static const Color primaryTeal = accentTeal;
  static const Color primaryPurple = primaryElectric;
  static const Color primaryPurpleLight = primaryElectricLight;
  static const Color accentRed = accentSunset;
  static const Color errorRed = accentSunset;

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937); // Dark Grey
  static const Color textSecondary = Color(0xFF6B7280); // Medium Grey
  static const Color textWhite = Color(0xFFFFFFFF); // White text

  // Dividers & Borders
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFE5E7EB);

  // Shadows
  static Color shadowColor = const Color(0xFF9CA3AF).withOpacity(0.2);

  // Backward compatibility (mapping old names to new palette where sensible)
  static const Color backgroundDark = Color(0xFF1E1B4B); // Indigo 950 (from splash)
  static const Color backgroundCard = backgroundWhite;
  static const Color backgroundCardAlt = Color(0xFFF9FAFB);
  static const Color backgroundWhiteAlt = backgroundCardAlt;
  static const Color primaryBlue = primaryElectric; // Map old primary to original indigo
  static const Color liveRed = accentSunset;
  static const Color successGreen = accentGreen;
  
  // Re-added missing aliases
  static const Color textDark = textPrimary;    
  static const Color textLight = textSecondary; 
  static const Color textMuted = textSecondary;

  // Light Violet/Lavender Palette (for Player Dashboard) - Correct Design
  static const Color lavenderBg = Color(0xFFE8E3F3);        // Main background
  static const Color cardLavender = Color(0xFFEDE8F8);      // Light lavender cards (batting)
  static const Color cardPink = Color(0xFFFCE8E8);          // Light pink cards (bowling)  
  static const Color cardPeach = Color(0xFFFFF4E6);         // Peach cards (recent form)
  static const Color cardWhitePurple = Color(0xFFF5F2FF);   // White-purple stats cards
  static const Color accentPurple = Color(0xFF7E6FCC);      // Primary purple accent (buttons, icons)
  static const Color profileRing = Color(0xFFB8A9E8);       // Profile photo ring
  static const Color softGreen = Color(0xFF6BCF7F);         // Success/positive indicators
}
