import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                        ? Colors.black.withOpacity(0.4)
                        : theme.primaryColor.withOpacity(0.1 + (_glowAnimation.value * 0.15)),
                    blurRadius: 20 + (_glowAnimation.value * 10),
                    offset: const Offset(0, 8),
                    spreadRadius: _glowAnimation.value * 2,
                  ),
                  BoxShadow(
                    color: isDark 
                        ? Colors.white.withOpacity(0.02)
                        : Colors.white.withOpacity(0.8),
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
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          )
                        : Border.all(
                            color: theme.primaryColor.withOpacity(0.1),
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
                            color: theme.primaryColor.withOpacity(0.05 + (_glowAnimation.value * 0.05)),
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
                            color: theme.primaryColor.withOpacity(0.03),
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
                                  theme.primaryColor.withOpacity(0.1),
                                  Colors.transparent,
                                  theme.primaryColor.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Points container with glassmorphism effect
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.primaryColor,
                                    theme.primaryColor.withOpacity(0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                  BoxShadow(
                                    color: theme.primaryColor.withOpacity(0.2),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Inner glow
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: RadialGradient(
                                        center: Alignment.topLeft,
                                        radius: 1.5,
                                        colors: [
                                          Colors.white.withOpacity(0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Points text
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        FittedBox(
                                          child: Text(
                                            '${widget.reward.requiredPoints}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          'pts',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Reward information
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
                                      fontWeight: FontWeight.w700,
                                      color: isDark 
                                          ? Colors.white 
                                          : const Color(0xFF1A1A1A),
                                      letterSpacing: -0.5,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Points requirement
                                  Text(
                                    'Échangeable avec ${widget.reward.requiredPoints} points',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isDark 
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.grey[600],
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Three-dot menu for actions
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: isDark 
                                    ? Colors.white.withOpacity(0.8)
                                    : theme.primaryColor,
                              ),
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20, color: theme.primaryColor),
                                      const SizedBox(width: 8),
                                      const Text('Modifier'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                      const SizedBox(width: 8),
                                      const Text('Supprimer'),
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ],
                        ),
                      ),
                      
                      // Top accent line
                      Positioned(
                        top: 0,
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1),
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                theme.primaryColor.withOpacity(0.6),
                                theme.primaryColor.withOpacity(0.3),
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