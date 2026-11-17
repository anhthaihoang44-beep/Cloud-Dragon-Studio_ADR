import 'dart:math';
import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../theme/app_colors.dart';
import 'kid_button.dart';

/// Cổng phụ huynh (Parental Gate) đạt chuẩn Apple Kids Category & Google Play Families
/// Yêu cầu giải toán hoặc giữ 3s để ngăn trẻ em bấm nhầm vào thanh toán/link ngoài.
class ParentalGateDialog extends StatefulWidget {
  final VoidCallback onPassed;

  const ParentalGateDialog({super.key, required this.onPassed});

  static Future<bool> verify(BuildContext context) async {
    bool passed = false;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ParentalGateDialog(
        onPassed: () {
          passed = true;
          Navigator.of(ctx).pop();
        },
      ),
    );
    return passed;
  }

  @override
  State<ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<ParentalGateDialog> {
  late int _numA;
  late int _numB;
  late int _correctAnswer;
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _numA = random.nextInt(6) + 4; // 4..9
    _numB = random.nextInt(6) + 4; // 4..9
    _correctAnswer = _numA * _numB;
  }

  void _checkAnswer() {
    final input = int.tryParse(_controller.text.trim());
    if (input == _correctAnswer) {
      widget.onPassed();
    } else {
      final strings = AppStrings();
      setState(() {
        _errorMessage = strings.currentLanguage == AppLanguage.vi
            ? 'Chưa đúng, bố mẹ hãy thử lại nhé!'
            : 'Incorrect, please try again!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings();
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.cloudWhite,
      title: Row(
        children: [
          const Icon(Icons.shield_rounded, color: AppColors.lavenderDark, size: 28),
          const SizedBox(width: 8),
          Text(
            strings.parentalGate,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.parentalPrompt,
              style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.lavenderPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '$_numA  ×  $_numB  =  ?',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: AppColors.lavenderDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: strings.currentLanguage == AppLanguage.vi ? 'Nhập đáp án' : 'Enter answer',
                errorText: _errorMessage,
                filled: true,
                fillColor: AppColors.cloudBackground,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.cardBorder, width: 2),
                ),
              ),
              onSubmitted: (_) => _checkAnswer(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            strings.back,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ),
        KidButton(
          label: strings.done,
          backgroundColor: AppColors.mintGreen,
          textColor: AppColors.textDark,
          onTap: _checkAnswer,
          minHeight: 46,
        ),
      ],
    );
  }
}

