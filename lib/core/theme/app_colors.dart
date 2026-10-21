import 'package:flutter/material.dart';

/// Centralized color palette for the Dahab Live design system.
///
/// Designed around a luxury fintech aesthetic:
/// Deep Obsidian Slate surfaces paired with Radiant Champagne Gold accents.
abstract final class AppColors {
  AppColors._();

  // ─── Brand identity ────────────────────────────────────────────────────────

  /// Primary gold — luminous champagne gold for highlights and active states.
  static const Color gold = Color(0xFFF3C644);

  /// Softer gold variant for gradients, glow outlines, and secondary badges.
  static const Color goldSoft = Color(0xFFFFDF70);

  /// Deep gold used in the light theme for high-contrast visibility.
  static const Color goldDeep = Color(0xFFC8931C);

  // ─── Trend indicators ──────────────────────────────────────────────────────

  /// Emerald green for positive price changes and gains.
  static const Color trendUp = Color(0xFF2ECC71);

  /// Vibrant coral red for negative price changes and drops.
  static const Color trendDown = Color(0xFFE74C3C);

  // ─── Dark theme surfaces (Obsidian Slate) ──────────────────────────────────

  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkCard = Color(0xFF161B22);
  static const Color darkSurface = Color(0xFF21262D);
  static const Color darkNavBar = Color(0xFF10141B);
  static const Color darkBorder = Color(0xFF30363D);
  static const Color darkBorderStrong = Color(0xFF484F58);
  static const Color darkOnSurface = Color(0xFFF0F6FC);
  static const Color darkSecondary = Color(0xFF8B949E);
  static const Color darkMuted = Color(0xFF6E7681);

  // Convenience aliases for components
  static const Color cardBackground = darkCard;
  static const Color cardBorder = darkBorder;
  static const Color skeletonBorder = darkBorder;
  static const Color skeletonPlaceholder = darkSurface;

  // ─── Light theme surfaces ──────────────────────────────────────────────────

  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF0F2F5);
  static const Color lightBorder = Color(0xFFD0D7DE);
  static const Color lightOnSurface = Color(0xFF1F2328);
  static const Color lightSecondary = Color(0xFF656D76);
  static const Color lightMuted = Color(0xFF8C959F);

  // ─── Metal accent colors ───────────────────────────────────────────────────

  /// Silver metal accent — used on XAG (Silver) price cards.
  static const Color silverAccent = Color(0xFFB7C0CC);

  /// Generic metal accent — used on XPT, XPD, HG and other non-gold metals.
  static const Color metalAccent = Color(0xFF9BA8B5);

  // ─── Network / status indicators ──────────────────────────────────────────

  /// Green badge: network is live, latency < 700ms.
  static const Color statusLive = Color(0xFF2ECC71);
  static const Color liveGreen = statusLive;

  /// Amber badge: latency between 700ms and 1600ms.
  static const Color statusSlow = Color(0xFFF39C12);
  static const Color latencyYellow = statusSlow;

  /// Red badge: latency > 1600ms or network error.
  static const Color statusError = Color(0xFFE74C3C);
  static const Color latencyRed = statusError;
  static const Color lightError = Color(0xFFD32F2F);

  // ─── Semantic helpers ──────────────────────────────────────────────────────

  /// Returns the correct accent color for a given metal symbol.
  static Color accentForMetal(String metalCode, Color primaryColor) {
    return switch (metalCode) {
      'XAU' => primaryColor,
      'XAG' => silverAccent,
      _ => metalAccent,
    };
  }

  /// Returns the status color based on network latency in milliseconds.
  static Color latencyColor(int? latencyMs) {
    if (latencyMs == null) return statusLive;
    if (latencyMs < 700) return statusLive;
    if (latencyMs < 1600) return statusSlow;
    return statusError;
  }
}
