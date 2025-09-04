import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';

/// Switch pour basculer entre thème clair/sombre - VERSION CORRIGÉE
class ThemeSwitch extends StatefulWidget {
  final bool showLabel;
  final EdgeInsets? padding;

  const ThemeSwitch({super.key, this.showLabel = true, this.padding});

  @override
  State<ThemeSwitch> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animation principale pour le slide
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Animation de pulse pour le feedback
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onThemeToggle() {
    // Animation de feedback
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });

    // Changer le thème
    context.read<ThemeProvider>().toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // ✅ SYNCHRONISATION : Utiliser l'état réel du thème
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Synchroniser l'animation avec l'état réel
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isDark && !_controller.isCompleted) {
            _controller.forward();
          } else if (!isDark && _controller.isCompleted) {
            _controller.reverse();
          }
        });

        return Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showLabel) ...[
                Icon(
                  Icons.light_mode,
                  size: 20,
                  color: AppColors.getOnSurfaceVariant(
                    context,
                  ).withOpacity(isDark ? 0.5 : 1.0),
                ),
                const SizedBox(width: 8),
              ],

              // ✅ SWITCH AMÉLIORÉ
              ScaleTransition(
                scale: _pulseAnimation,
                child: GestureDetector(
                  onTap: _onThemeToggle,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: 60,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppColors.primary, AppColors.secondary]
                                : [Colors.grey[300]!, Colors.grey[400]!],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // ✅ INDICATEUR SYNCHRONISÉ
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              left: isDark ? 30 : 2, // ✅ Basé sur le thème réel
                              top: 2,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      isDark
                                          ? Icons.dark_mode
                                          : Icons.light_mode,
                                      key: ValueKey(
                                        isDark,
                                      ), // ✅ Key basée sur l'état réel
                                      size: 16,
                                      color: isDark
                                          ? AppColors.primary
                                          : Colors.orange[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              if (widget.showLabel) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.dark_mode,
                  size: 20,
                  color: AppColors.getOnSurfaceVariant(
                    context,
                  ).withOpacity(isDark ? 1.0 : 0.5),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
