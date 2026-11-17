import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class KidButton extends StatefulWidget {
  final Widget? child;
  final String? label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;
  final double minHeight;
  final double minWidth;
  final EdgeInsetsGeometry padding;
  final bool isPill;

  const KidButton({
    super.key,
    this.child,
    this.label,
    this.icon,
    this.backgroundColor = AppColors.butterYellow,
    this.textColor = AppColors.textDark,
    this.onTap,
    this.minHeight = 48.0, // >= 48dp theo tiêu chuẩn trẻ em
    this.minWidth = 48.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.isPill = true,
  });

  @override
  State<KidButton> createState() => _KidButtonState();
}

class _KidButtonState extends State<KidButton> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _anim.forward(),
      onTapUp: (_) {
        _anim.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _anim.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          constraints: BoxConstraints(
            minHeight: widget.minHeight,
            minWidth: widget.minWidth,
          ),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.isPill ? 32 : 18),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withOpacity(0.35),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
              const BoxShadow(
                color: Colors.white70,
                offset: Offset(0, -1.5),
                blurRadius: 2,
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          ),
          child: Center(
            child: widget.child ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: widget.textColor, size: 22),
                      if (widget.label != null) const SizedBox(width: 6),
                    ],
                    if (widget.label != null)
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.label!,
                            maxLines: 1,
                            style: TextStyle(
                              color: widget.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
