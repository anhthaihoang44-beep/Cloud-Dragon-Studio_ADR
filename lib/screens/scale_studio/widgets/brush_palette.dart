 import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/drawing_stroke.dart';

class BrushPalette extends StatelessWidget {
  final DrawingToolType selectedTool;
  final ValueChanged<DrawingToolType> onToolSelected;

  const BrushPalette({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tools = [
      {'type': DrawingToolType.brush, 'icon': Icons.brush_rounded},
      {'type': DrawingToolType.gradient, 'icon': Icons.gradient_rounded},
      {'type': DrawingToolType.stampStar, 'icon': Icons.star_rounded},
      {'type': DrawingToolType.stampCloud, 'icon': Icons.cloud_rounded},
      {'type': DrawingToolType.stampHeart, 'icon': Icons.favorite_rounded},
      {'type': DrawingToolType.eraser, 'icon': Icons.auto_fix_high_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cloudWhite.withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: tools.map((tool) {
            final type = tool['type'] as DrawingToolType;
            final icon = tool['icon'] as IconData;
            final isSelected = selectedTool == type;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => onToolSelected(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: isSelected ? 52 : 44,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.mintGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isSelected ? AppColors.textDark : AppColors.textMuted,
                      size: 24,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
