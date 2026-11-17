import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ColorSelector extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const ColorSelector({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  double _hueValue = 180.0;
  bool _showCustomHue = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cloudWhite.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dải màu Swatches tròn to dễ bấm
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppColors.kidSwatches.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == AppColors.kidSwatches.length) {
                  // Nút mở thanh Hue Slider tùy chỉnh
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCustomHue = !_showCustomHue;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          colors: [
                            AppColors.roseSoft,
                            AppColors.butterYellow,
                            AppColors.mintGreen,
                            AppColors.skyBlue,
                            AppColors.lavenderPurple,
                            AppColors.roseSoft,
                          ],
                        ),
                        border: Border.all(
                          color: _showCustomHue ? AppColors.textDark : Colors.white,
                          width: 3,
                        ),
                      ),
                      child: const Icon(Icons.colorize_rounded, size: 22, color: AppColors.textDark),
                    ),
                  );
                }

                final color = AppColors.kidSwatches[index];
                final isSelected = widget.selectedColor.value == color.value;

                return GestureDetector(
                  onTap: () => widget.onColorChanged(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: isSelected ? 52 : 44,
                    height: isSelected ? 52 : 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.textDark : Colors.white,
                        width: isSelected ? 3.5 : 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(Icons.star_rounded, color: Colors.white, size: 22),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),

          // Thanh Hue Slider thân thiện cho trẻ em khi mở
          if (_showCustomHue) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.palette_outlined, size: 20, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 14,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: Slider(
                      value: _hueValue,
                      min: 0,
                      max: 360,
                      onChanged: (val) {
                        setState(() => _hueValue = val);
                        // Tạo màu pastel êm dịu từ Hue
                        final hsv = HSVColor.fromAHSV(1.0, val, 0.45, 0.95);
                        widget.onColorChanged(hsv.toColor());
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
