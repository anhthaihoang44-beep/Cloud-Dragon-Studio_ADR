import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../audio/audio_service.dart';
import '../localization/app_strings.dart';
import '../theme/app_colors.dart';
import 'kid_button.dart';
import 'parental_gate_dialog.dart';

class KidsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showHomeButton;
  final bool showSoundToggle;
  final bool showLangToggle;
  final bool showParentalGate;
  final VoidCallback? onHomePressed;
  final List<Widget>? actions;

  const KidsAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showHomeButton = true,
    this.showSoundToggle = true,
    this.showLangToggle = false,
    this.showParentalGate = false,
    this.onHomePressed,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68.0);

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppStrings>();
    final audio = context.watch<AudioService>();

    return SafeArea(
      bottom: false,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            // Nút Nhà/Quay lại luôn cố định góc trái, kích thước >= 48dp
            if (showHomeButton) ...[
              KidButton(
                icon: Icons.home_rounded,
                label: strings.home,
                backgroundColor: AppColors.butterYellow,
                textColor: AppColors.textDark,
                minHeight: 48,
                minWidth: 88,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onTap: () {
                  if (onHomePressed != null) {
                    onHomePressed!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(width: 8),
            ],

            // Tiêu đề khu vực
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  if (subtitle != null)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // Các hành động riêng của màn hình (Undo, Reset, Save...)
            if (actions != null) ...actions!,

            // Nút Âm thanh nhanh (SFX/Mute)
            if (showSoundToggle) ...[
              const SizedBox(width: 6),
              KidButton(
                icon: audio.isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                backgroundColor: audio.isSoundEnabled ? AppColors.mintGreen : AppColors.cardBorder,
                textColor: AppColors.textDark,
                minHeight: 46,
                minWidth: 46,
                padding: const EdgeInsets.all(8),
                onTap: () => audio.toggleSound(),
              ),
            ],

            // Nút Chuyển đổi Ngôn ngữ (Chỉ hiện khi cần, ví dụ tại Hub)
            if (showLangToggle) ...[
              const SizedBox(width: 6),
              KidButton(
                icon: Icons.language_rounded,
                label: strings.currentLanguage == AppLanguage.en ? 'EN' : 'VI',
                backgroundColor: AppColors.lavenderPurple,
                textColor: AppColors.textDark,
                minHeight: 46,
                minWidth: 66,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onTap: () {
                  audio.playPop();
                  strings.toggleLanguage();
                },
              ),
            ],

            // Nút Parental Gate (Chỉ hiện ở Hub)
            if (showParentalGate) ...[
              const SizedBox(width: 6),
              KidButton(
                icon: Icons.shield_rounded,
                backgroundColor: AppColors.cloudWhite,
                textColor: AppColors.strokeSoft,
                minHeight: 46,
                minWidth: 46,
                padding: const EdgeInsets.all(8),
                onTap: () async {
                  audio.playPop();
                  final passed = await ParentalGateDialog.verify(context);
                  if (passed && context.mounted) {
                    _showParentMenu(context, strings);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showParentMenu(BuildContext context, AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.family_restroom_rounded, color: AppColors.lavenderDark),
            const SizedBox(width: 8),
            Text(strings.parentalGate),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.privacyNotice,
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mintLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.mintDark),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'COPPA & GDPR-K Compliant.\nZero data collection.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          KidButton(
            label: strings.done,
            backgroundColor: AppColors.butterYellow,
            textColor: AppColors.textDark,
            minHeight: 44,
            onTap: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
