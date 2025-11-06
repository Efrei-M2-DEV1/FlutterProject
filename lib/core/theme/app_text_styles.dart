import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextStyle headlineLarge(BuildContext context) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.getOnSurface(context),
  );

  static TextStyle headlineMedium(BuildContext context) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.getOnSurface(context),
  );

  static TextStyle headlineSmall(BuildContext context) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.getOnSurface(context),
  );

  static TextStyle titleLarge(BuildContext context) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.getOnSurface(context),
  );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.getOnSurface(context),
  );

  static TextStyle titleSmall(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.getOnSurface(context),
  );

  static TextStyle labelLarge(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.getOnSurfaceVariant(context),
  );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.getOnSurface(context),
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.getOnSurfaceVariant(context),
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.getOnSurfaceVariant(context),
  );

  static TextStyle taskTitle(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.getOnSurface(context),
  );

  static TextStyle taskTitleCompleted(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.getOnSurfaceVariant(context),
    decoration: TextDecoration.lineThrough,
  );

  static TextStyle taskDescription(BuildContext context) =>
      TextStyle(fontSize: 14, color: AppColors.getOnSurfaceVariant(context));

  static TextStyle sectionTitle(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.getSectionTitle(context),
  );

  static const TextStyle constantTitleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),
  );

  static const TextStyle constantBodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Color(0xFF6B7280),
  );
}
