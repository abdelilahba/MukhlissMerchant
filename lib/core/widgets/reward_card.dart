import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

class RewardCard extends StatefulWidget {
  final Reward reward;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RewardCard({
    super.key,
    required this.reward,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<RewardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              constraints: const BoxConstraints(
                minHeight: 110, // ✅ RÉDUIRE ENCORE LA HAUTEUR MINIMALE
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : theme.primaryColor.withValues(
                            alpha: 0.1 + (_glowAnimation.value * 0.15)),
                    blurRadius: 20 + (_glowAnimation.value * 10),
                    offset: const Offset(0, 8),
                    spreadRadius: _glowAnimation.value * 2,
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.02)
                        : Colors.white.withValues(alpha: 0.8),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0xFF1F1F23),
                              const Color(0xFF2C2C30),
                              const Color(0xFF1A1A1E),
                            ]
                          : [
                              Colors.white,
                              const Color(0xFFFAFBFC),
                              const Color(0xFFF5F7FA),
                            ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    border: isDark
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          )
                        : Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            width: 1,
                          ),
                  ),
                  child: Stack(
                    children: [
                      // Animated background elements
                      Positioned(
                        right: -30,
                        top: -30,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 80 + (_glowAnimation.value * 20),
                          height: 80 + (_glowAnimation.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primaryColor.withValues(
                                alpha: 0.05 + (_glowAnimation.value * 0.05)),
                          ),
                        ),
                      ),

                      Positioned(
                        left: -20,
                        bottom: -20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primaryColor.withValues(alpha: 0.03),
                          ),
                        ),
                      ),

                      // Shimmer effect
                      Positioned.fill(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isPressed ? 0.1 : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.primaryColor.withValues(alpha: 0.1),
                                  Colors.transparent,
                                  theme.primaryColor.withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(
                            14), // ✅ RÉDUIRE ENCORE LE PADDING
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Points container - VERSION ULTRA COMPACTE
                            Container(
                              width: 55, // ✅ RÉDUIRE ENCORE
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.primaryColor,
                                    theme.primaryColor.withValues(alpha: 0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor
                                        .withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${widget.reward.requiredPoints}',
                                      style: const TextStyle(
                                        fontSize: 13, // ✅ RÉDUIRE ENCORE
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        height:
                                            0.9, // ✅ RÉDUIRE LA HAUTEUR DE LIGNE
                                      ),
                                    ),
                                    Text(
                                      l10n.point,
                                      style: TextStyle(
                                        fontSize: 9, // ✅ RÉDUIRE ENCORE
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        height:
                                            0.9, // ✅ RÉDUIRE LA HAUTEUR DE LIGNE
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10), // ✅ RÉDUIRE ENCORE

                            // Reward information - VERSION ULTRA COMPACTE
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Reward name
                                  Text(
                                    widget.reward.name,
                                    style: TextStyle(
                                      fontSize: 13, // ✅ RÉDUIRE ENCORE
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A1A1A),
                                      letterSpacing: -0.3, // ✅ RÉDUIRE
                                      height:
                                          1.1, // ✅ RÉDUIRE LA HAUTEUR DE LIGNE
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 4), // ✅ RÉDUIRE ENCORE

                                  // Points requirement
                                  Text(
                                    '${l10n.echange} ${widget.reward.requiredPoints} ${l10n.point}',
                                    style: TextStyle(
                                      fontSize: 11, // ✅ RÉDUIRE ENCORE
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : Colors.grey[600],
                                      letterSpacing: 0.1, // ✅ RÉDUIRE
                                      height:
                                          1.0, // ✅ RÉDUIRE LA HAUTEUR DE LIGNE
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Three-dot menu - VERSION ULTRA COMPACTE
                            SizedBox(
                              width: 24, // ✅ FORCER LA LARGEUR
                              height: 24,
                              child: PopupMenuButton<String>(
                                padding:
                                    EdgeInsets.zero, // ✅ SUPPRIMER LE PADDING
                                icon: Icon(
                                  Icons.more_vert,
                                  size: 18, // ✅ RÉDUIRE ENCORE
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : theme.primaryColor,
                                ),
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit,
                                            size: 16,
                                            color: theme.primaryColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.modifier,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.delete,
                                            size: 16, color: Colors.red),
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.supprimer,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (String value) {
                                  if (value == 'edit') {
                                    widget.onEdit();
                                  } else if (value == 'delete') {
                                    widget.onDelete();
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Top accent line - OPTIONNEL: SUPPRIMER SI NÉCESSAIRE
                      Positioned(
                        top: 0,
                        left: 16,
                        right: 16,
                        child: Container(
                          height: 1, // ✅ RÉDUIRE L'ÉPAISSEUR
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1),
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                theme.primaryColor.withValues(alpha: 0.4),
                                theme.primaryColor.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
