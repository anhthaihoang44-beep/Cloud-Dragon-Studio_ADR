import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../pet_garden_screen.dart';

class PetPainter extends CustomPainter {
  final CloudPetType petType;

  PetPainter({required this.petType});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (petType) {
      case CloudPetType.rabbit:
        _drawRabbit(canvas, cx, cy, size);
        break;
      case CloudPetType.fox:
        _drawFox(canvas, cx, cy, size);
        break;
      case CloudPetType.kitten:
        _drawKitten(canvas, cx, cy, size);
        break;
    }
  }

  void _drawRabbit(Canvas canvas, double cx, double cy, Size size) {
    final bodyPaint = Paint()..color = const Color(0xFFF8FAFC);
    final shadowPaint = Paint()..color = AppColors.strokeSoft.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 3.5;
    final pinkPaint = Paint()..color = AppColors.roseSoft;
    final eyePaint = Paint()..color = AppColors.textDark;
    final whitePaint = Paint()..color = Colors.white;

    // Tai thỏ (Ears)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 28, cy - 45), width: 22, height: 60), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 28, cy - 45), width: 22, height: 60), shadowPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 28, cy - 43), width: 12, height: 42), pinkPaint);

    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 28, cy - 45), width: 22, height: 60), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 28, cy - 45), width: 22, height: 60), shadowPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 28, cy - 43), width: 12, height: 42), pinkPaint);

    // Đầu thỏ (Head)
    canvas.drawCircle(Offset(cx, cy + 8), 44, bodyPaint);
    canvas.drawCircle(Offset(cx, cy + 8), 44, shadowPaint);

    // Má hồng (Cheeks)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 26, cy + 18), width: 14, height: 9), pinkPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 26, cy + 18), width: 14, height: 9), pinkPaint);

    // Mắt to long lanh (Eyes)
    canvas.drawCircle(Offset(cx - 16, cy + 6), 7, eyePaint);
    canvas.drawCircle(Offset(cx - 14, cy + 4), 2.5, whitePaint);
    canvas.drawCircle(Offset(cx + 16, cy + 6), 7, eyePaint);
    canvas.drawCircle(Offset(cx + 18, cy + 4), 2.5, whitePaint);

    // Mũi & miệng (Nose & Mouth)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 14), width: 7, height: 5), pinkPaint);
    final mouthPaint = Paint()..color = AppColors.textDark..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx - 5, cy + 20), width: 10, height: 8), 0, pi, false, mouthPaint);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx + 5, cy + 20), width: 10, height: 8), 0, pi, false, mouthPaint);
  }

  void _drawFox(Canvas canvas, double cx, double cy, Size size) {
    final orangePaint = Paint()..color = const Color(0xFFFF9F43);
    final whitePaint = Paint()..color = const Color(0xFFFFFDF8);
    final strokePaint = Paint()..color = AppColors.strokeSoft.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 3.5;
    final eyePaint = Paint()..color = AppColors.textDark;
    final pinkPaint = Paint()..color = AppColors.roseSoft;

    // Tai cáo nhọn (Pointed Ears)
    final leftEar = Path()..moveTo(cx - 42, cy - 8)..lineTo(cx - 30, cy - 50)..lineTo(cx - 10, cy - 20)..close();
    canvas.drawPath(leftEar, orangePaint);
    canvas.drawPath(leftEar, strokePaint);

    final rightEar = Path()..moveTo(cx + 42, cy - 8)..lineTo(cx + 30, cy - 50)..lineTo(cx + 10, cy - 20)..close();
    canvas.drawPath(rightEar, orangePaint);
    canvas.drawPath(rightEar, strokePaint);

    // Đầu cáo (Head)
    canvas.drawCircle(Offset(cx, cy + 5), 44, orangePaint);
    canvas.drawCircle(Offset(cx, cy + 5), 44, strokePaint);

    // Mõm trắng (White Muzzle)
    final muzzle = Path()..moveTo(cx - 32, cy + 12)..quadraticBezierTo(cx, cy - 4, cx + 32, cy + 12)..quadraticBezierTo(cx, cy + 50, cx - 32, cy + 12)..close();
    canvas.drawPath(muzzle, whitePaint);

    // Má hồng
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 24, cy + 16), width: 12, height: 8), pinkPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 24, cy + 16), width: 12, height: 8), pinkPaint);

    // Mắt
    canvas.drawCircle(Offset(cx - 15, cy + 4), 6, eyePaint);
    canvas.drawCircle(Offset(cx - 13, cy + 2), 2.2, whitePaint);
    canvas.drawCircle(Offset(cx + 15, cy + 4), 6, eyePaint);
    canvas.drawCircle(Offset(cx + 17, cy + 2), 2.2, whitePaint);

    // Mũi & miệng
    canvas.drawCircle(Offset(cx, cy + 18), 4.5, eyePaint);
    final mouthPaint = Paint()..color = AppColors.textDark..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy + 24), width: 12, height: 8), 0, pi, false, mouthPaint);
  }

  void _drawKitten(Canvas canvas, double cx, double cy, Size size) {
    final butterPaint = Paint()..color = const Color(0xFFFFE066);
    final pinkPaint = Paint()..color = AppColors.roseSoft;
    final strokePaint = Paint()..color = AppColors.strokeSoft.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 3.5;
    final eyePaint = Paint()..color = AppColors.textDark;
    final whitePaint = Paint()..color = Colors.white;

    // Tai mèo (Cat Ears)
    final leftEar = Path()..moveTo(cx - 38, cy - 5)..lineTo(cx - 28, cy - 45)..lineTo(cx - 8, cy - 22)..close();
    canvas.drawPath(leftEar, butterPaint);
    canvas.drawPath(leftEar, strokePaint);

    final rightEar = Path()..moveTo(cx + 38, cy - 5)..lineTo(cx + 28, cy - 45)..lineTo(cx + 8, cy - 22)..close();
    canvas.drawPath(rightEar, butterPaint);
    canvas.drawPath(rightEar, strokePaint);

    // Đầu mèo (Cat Head)
    canvas.drawCircle(Offset(cx, cy + 6), 44, butterPaint);
    canvas.drawCircle(Offset(cx, cy + 6), 44, strokePaint);

    // Má hồng
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 25, cy + 18), width: 14, height: 9), pinkPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 25, cy + 18), width: 14, height: 9), pinkPaint);

    // Mắt mèo to tròn
    canvas.drawCircle(Offset(cx - 15, cy + 5), 7, eyePaint);
    canvas.drawCircle(Offset(cx - 13, cy + 3), 2.5, whitePaint);
    canvas.drawCircle(Offset(cx + 15, cy + 5), 7, eyePaint);
    canvas.drawCircle(Offset(cx + 17, cy + 3), 2.5, whitePaint);

    // Mũi & râu mèo (Nose & Whiskers)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 15), width: 6, height: 4.5), pinkPaint);

    final whiskerPaint = Paint()..color = AppColors.textDark..style = PaintingStyle.stroke..strokeWidth = 2.0..strokeCap = StrokeCap.round;
    // Râu trái
    canvas.drawLine(Offset(cx - 24, cy + 12), Offset(cx - 42, cy + 10), whiskerPaint);
    canvas.drawLine(Offset(cx - 24, cy + 17), Offset(cx - 42, cy + 19), whiskerPaint);
    // Râu phải
    canvas.drawLine(Offset(cx + 24, cy + 12), Offset(cx + 42, cy + 10), whiskerPaint);
    canvas.drawLine(Offset(cx + 24, cy + 17), Offset(cx + 42, cy + 19), whiskerPaint);

    // Miệng
    canvas.drawArc(Rect.fromCenter(center: Offset(cx - 4, cy + 20), width: 8, height: 7), 0, pi, false, whiskerPaint);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx + 4, cy + 20), width: 8, height: 7), 0, pi, false, whiskerPaint);
  }

  @override
  bool shouldRepaint(covariant PetPainter oldDelegate) => oldDelegate.petType != petType;
}
