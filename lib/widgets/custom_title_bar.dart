// widgets/modern_title_bar.dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../utils/couleurs.dart';

class ModernTitleBar extends StatefulWidget {
  final String title;
  final VoidCallback? onThemeToggle;
  final bool isDarkMode;

  const ModernTitleBar({
    super.key,
    required this.title,
    this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<ModernTitleBar> createState() => _ModernTitleBarState();
}

class _ModernTitleBarState extends State<ModernTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _checkMaximized() async {
    final isMaximized = await windowManager.isMaximized();
    if (mounted) {
      setState(() {
        _isMaximized = isMaximized;
      });
    }
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);
  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Zone de glissement
          Expanded(
            child: GestureDetector(
              onPanStart: (details) => windowManager.startDragging(),
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Logo animé
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        size: 18,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Titre avec effet
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'Chillax',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: AppColors.white.withAlpha(100),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bouton thème
          if (widget.onThemeToggle != null)
            _buildActionButton(
              icon: widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              onTap: widget.onThemeToggle!,
              tooltip: widget.isDarkMode ? 'Mode clair' : 'Mode sombre',
            ),
          // Bouton réduire
          _buildActionButton(
            icon: Icons.remove,
            onTap: () => windowManager.minimize(),
            tooltip: 'Réduire',
          ),
          // Bouton agrandir/restaurer
          _buildActionButton(
            icon: _isMaximized ? Icons.fullscreen_exit : Icons.fullscreen,
            onTap: () async {
              if (_isMaximized) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
            tooltip: _isMaximized ? 'Restaurer' : 'Agrandir',
          ),
          // Bouton fermer
          _buildActionButton(
            icon: Icons.close,
            onTap: () => windowManager.close(),
            tooltip: 'Fermer',
            isClose: true,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isClose = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 48,
          decoration: BoxDecoration(
            color: isClose ? Colors.transparent : Colors.transparent,
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isClose ? Colors.transparent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isClose ? Colors.white : AppColors.white.withAlpha(200),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
