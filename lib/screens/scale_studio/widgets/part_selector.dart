import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/dragon_character.dart';

class PartSelector extends StatelessWidget {
  final DragonPart selectedPart;
  final ValueChanged<DragonPart> onPartSelected;

  const PartSelector({
    super.key,
    required this.selectedPart,
    required this.onPartSelected,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppStrings>();

    final parts = [
      {'part': DragonPart.belly, 'label': strings.partBelly, 'emoji': '✨'},
      {'part': DragonPart.wings, 'label': strings.partWings, 'emoji': '🪄'},
      {'part': DragonPart.horns, 'label': strings.partHorns, 'emoji': '🦄'},
      {'part': DragonPart.body, 'label': strings.partBody, 'emoji': '🐲'},
      {'part': DragonPart.tail, 'label': strings.partTail, 'emoji': '☁️'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: parts.map((item) {
          final part = item['part'] as DragonPart;
          final label = item['label'] as String;
          final emoji = item['emoji'] as String;
          final isSelected = selectedPart == part;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: GestureDetector(
              onTap: () => onPartSelected(part),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.lavenderPurple : AppColors.cloudWhite.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.lavenderDark : Colors.white,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppColors.textDark : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

