import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/dragon_character.dart';
import '../../../models/drawing_stroke.dart';
import '../../../models/wardrobe_item.dart';
import 'dragon_paths.dart';

class DragonPainter extends CustomPainter {
  final DragonCharacter character;
  final DragonPart? selectedPart;
  final List<DrawingStroke>? activeLiveStrokes;
  final double animationValue;

  DragonPainter({
    required this.character,
    this.selectedPart,
    this.activeLiveStrokes,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outlinePaint = Paint()
      ..color = AppColors.strokeSoft.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final floatOffset = sin(animationValue * 2 * pi) * 4.0;
    canvas.save();
    canvas.translate(0, floatOffset);

    // --- 0. CÁNH TIÊN / LÔNG VŨ PHÍA SAU (Back Wings Deco) ---
    _drawWingsDecoBackground(canvas, size);

    // --- 1. ĐUÔI RỒNG (Tail) ---
    final tailPath = DragonPaths.getTailPath(size);
    final tailPaint = Paint()
      ..color = character.bodyColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(tailPath, tailPaint);
    _drawMaskedStrokes(canvas, tailPath, DragonPart.tail);
    canvas.drawPath(tailPath, outlinePaint);

    // --- 2. CÁNH RỒNG (Wings) ---
    final wingsPath = DragonPaths.getWingsPath(size);
    final wingsPaint = Paint()
      ..color = character.wingsColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(wingsPath, wingsPaint);
    _drawMaskedStrokes(canvas, wingsPath, DragonPart.wings);
    canvas.drawPath(wingsPath, outlinePaint);
    _drawWingRibs(canvas, size);

    // --- 3. GAI LƯNG MÂY (Dorsal Spikes) ---
    _drawDorsalSpikes(canvas, size);

    // --- 4. SỪNG RỒNG (Horns) ---
    final hornsPath = DragonPaths.getHornsPath(size);
    final hornsPaint = Paint()
      ..color = character.hornsColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(hornsPath, hornsPaint);
    _drawMaskedStrokes(canvas, hornsPath, DragonPart.horns);
    canvas.drawPath(hornsPath, outlinePaint);

    // --- 5. THÂN & ĐẦU RỒNG (Body & Head) ---
    final bodyPath = DragonPaths.getBodyPath(size);
    final bodyPaint = Paint()
      ..color = character.bodyColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyPaint);
    _drawMaskedStrokes(canvas, bodyPath, DragonPart.body);
    canvas.drawPath(bodyPath, outlinePaint);

    // --- 6. BỤNG VẢY (Belly Scales) - LUÔN LUÔN VẼ ĐẦY ĐỦ ---
    final bellyPath = DragonPaths.getBellyPath(size);
    final bellyPaint = Paint()
      ..color = character.bellyColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(bellyPath, bellyPaint);
    _drawMaskedStrokes(canvas, bellyPath, DragonPart.belly);
    _drawBellyScalePatterns(canvas, size);
    canvas.drawPath(bellyPath, outlinePaint);

    // --- 7. TRANG PHỤC / ÁO CHOÀNG / VÁY (Robes & Dresses) ---
    _drawEquippedRobe(canvas, size);

    // --- 8. TAY / CHÂN & POSE VẪY TAY (Waving Paw) ---
    _drawPawsAndPose(canvas, size);

    // --- 9. KHUÔN MẶT ĐÁNG YÊU (Eyes, Blush, Mouth) ---
    _drawCuteFace(canvas, size);

    // --- 10. KÍNH MẮT & MẶT NẠ (Glasses & Masks) ---
    _drawEquippedGlasses(canvas, size);

    // --- 11. KHĂN QUÀNG & NƠ (Necklaces & Bows) ---
    _drawEquippedScarf(canvas, size);

    // --- 12. MŨ & VƯƠNG MIỆN (Hats & Tiaras) ---
    _drawEquippedHat(canvas, size);

    // --- 13. HÀO QUANG BAY TRÊN ĐẦU (Floating Halo) ---
    _drawFloatingDeco(canvas, size);

    // --- 14. AURA BỘ PHẬN ĐANG CHỌN (Gợi ý trong Studio) ---
    if (selectedPart != null) {
      _drawSelectionAura(canvas, size, selectedPart!);
    }

    canvas.restore();
  }

  void _drawMaskedStrokes(Canvas canvas, Path maskPath, DragonPart part) {
    canvas.save();
    canvas.clipPath(maskPath);

    final strokes = character.partStrokes[part] ?? [];
    for (final stroke in strokes) {
      _renderSingleStroke(canvas, stroke);
    }

    if (selectedPart == part && activeLiveStrokes != null) {
      for (final stroke in activeLiveStrokes!) {
        _renderSingleStroke(canvas, stroke);
      }
    }

    canvas.restore();
  }

  void _renderSingleStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    if (stroke.toolType == DrawingToolType.brush || stroke.toolType == DrawingToolType.eraser) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, stroke.strokeWidth / 2, paint..style = PaintingStyle.fill);
      } else {
        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    } else if (stroke.toolType == DrawingToolType.gradient) {
      if (stroke.points.length >= 2) {
        final p1 = stroke.points.first;
        final p2 = stroke.points.last;
        final gradPaint = Paint()
          ..shader = LinearGradient(
            colors: [stroke.color.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.1)],
          ).createShader(Rect.fromPoints(p1, p2))
          ..strokeWidth = stroke.strokeWidth * 1.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawLine(p1, p2, gradPaint);
      }
    } else {
      // Stamp tools (Star, Cloud, Heart)
      final p = stroke.points.last;
      final size = stroke.strokeWidth * 1.4;
      switch (stroke.toolType) {
        case DrawingToolType.stampStar:
          _drawStarStamp(canvas, p, size, stroke.color);
          break;
        case DrawingToolType.stampCloud:
          _drawCloudStamp(canvas, p, size, stroke.color);
          break;
        case DrawingToolType.stampHeart:
          _drawHeartStamp(canvas, p, size, stroke.color);
          break;
        default:
          break;
      }
    }
  }

  void _drawStarStamp(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = -pi / 2 + i * 2 * pi / 5;
      final innerAngle = outerAngle + pi / 5;
      final pOuter = Offset(center.dx + r * cos(outerAngle), center.dy + r * sin(outerAngle));
      final pInner = Offset(center.dx + (r * 0.45) * cos(innerAngle), center.dy + (r * 0.45) * sin(innerAngle));
      if (i == 0) {
        path.moveTo(pOuter.dx, pOuter.dy);
      } else {
        path.lineTo(pOuter.dx, pOuter.dy);
      }
      path.lineTo(pInner.dx, pInner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCloudStamp(Canvas canvas, Offset c, double r, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(c.dx - r * 0.4, c.dy), r * 0.45, paint);
    canvas.drawCircle(Offset(c.dx + r * 0.4, c.dy), r * 0.45, paint);
    canvas.drawCircle(Offset(c.dx, c.dy - r * 0.25), r * 0.55, paint);
  }

  void _drawHeartStamp(Canvas canvas, Offset c, double r, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(c.dx, c.dy + r * 0.4);
    path.cubicTo(c.dx - r * 0.7, c.dy - r * 0.2, c.dx - r * 0.7, c.dy - r * 0.7, c.dx, c.dy - r * 0.35);
    path.cubicTo(c.dx + r * 0.7, c.dy - r * 0.7, c.dx + r * 0.7, c.dy - r * 0.2, c.dx, c.dy + r * 0.4);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCuteFace(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final eyeY = h * 0.33;
    final leftEyeX = w * 0.42;
    final rightEyeX = w * 0.58;
    final eyeRadius = w * 0.045;

    final eyePaint = Paint()..color = const Color(0xFF2B3A42);
    final highlightPaint = Paint()..color = Colors.white;

    // Mắt trái
    canvas.drawCircle(Offset(leftEyeX, eyeY), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(leftEyeX - 3, eyeY - 3), eyeRadius * 0.4, highlightPaint);
    canvas.drawCircle(Offset(leftEyeX + 3, eyeY + 3), eyeRadius * 0.2, highlightPaint);

    // Mắt phải (Nháy mắt / Vui vẻ)
    if (character.expression == DragonExpression.wink) {
      final winkPaint = Paint()
        ..color = const Color(0xFF2B3A42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      final winkPath = Path()
        ..moveTo(rightEyeX - 10, eyeY)
        ..quadraticBezierTo(rightEyeX, eyeY + 8, rightEyeX + 10, eyeY);
      canvas.drawPath(winkPath, winkPaint);
    } else {
      canvas.drawCircle(Offset(rightEyeX, eyeY), eyeRadius, eyePaint);
      canvas.drawCircle(Offset(rightEyeX - 3, eyeY - 3), eyeRadius * 0.4, highlightPaint);
      canvas.drawCircle(Offset(rightEyeX + 3, eyeY + 3), eyeRadius * 0.2, highlightPaint);
    }

    // Má hồng đào kem
    final blushPaint = Paint()..color = AppColors.roseSoft.withValues(alpha: 0.65);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.35, h * 0.37), width: w * 0.09, height: h * 0.04),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.65, h * 0.37), width: w * 0.09, height: h * 0.04),
      blushPaint,
    );

    // Miệng (Ăn bánh hoặc Cười mỉm)
    if (character.expression == DragonExpression.eating) {
      final mouthPaint = Paint()..color = const Color(0xFFE89874);
      canvas.drawCircle(Offset(w * 0.50, h * 0.39), w * 0.035, mouthPaint);
    } else {
      final smilePaint = Paint()
        ..color = const Color(0xFF2B3A42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      final smilePath = Path()
        ..moveTo(w * 0.47, h * 0.38)
        ..quadraticBezierTo(w * 0.50, h * 0.41, w * 0.53, h * 0.38);
      canvas.drawPath(smilePath, smilePaint);
    }
  }

  void _drawPawsAndPose(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pawPaint = Paint()..color = character.bodyColor;
    final pawOutline = Paint()
      ..color = AppColors.strokeSoft.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Tay trái
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.34, h * 0.52), width: w * 0.08, height: h * 0.06), pawPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.34, h * 0.52), width: w * 0.08, height: h * 0.06), pawOutline);

    // Tay phải: nếu Pose waving thì giơ cao vẫy tay
    if (character.pose == DragonPose.waving) {
      final waveWave = sin(animationValue * 4 * pi) * 6.0;
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.68 + waveWave, h * 0.46), width: w * 0.08, height: h * 0.06), pawPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.68 + waveWave, h * 0.46), width: w * 0.08, height: h * 0.06), pawOutline);
    } else {
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.66, h * 0.52), width: w * 0.08, height: h * 0.06), pawPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.66, h * 0.52), width: w * 0.08, height: h * 0.06), pawOutline);
    }
  }

  // ===========================================================================
  // 1. TRANG PHỤC & ÁO CHOÀNG (Robes, Dresses, Vests)
  // ===========================================================================
  void _drawEquippedRobe(Canvas canvas, Size size) {
    final robeId = character.equippedItems[ItemCategory.robe.name];
    if (robeId == null) return;

    final item = WardrobeItem.getById(robeId);
    final robeColor = character.equippedColors[robeId] ?? item?.defaultColor ?? AppColors.skyBlue;

    switch (robeId) {
      case 'robe_cloud_cape':
        _drawCloudCape(canvas, size, robeColor);
        break;
      case 'robe_pastel_dress':
        _drawPastelDress(canvas, size, robeColor);
        break;
      case 'robe_starry_vest':
        _drawStarryVest(canvas, size, robeColor);
        break;
      case 'robe_night_gown':
        _drawNightGown(canvas, size, robeColor);
        break;
      default:
        _drawPastelDress(canvas, size, robeColor);
        break;
    }
  }

  /// Áo Choàng Mây Hoàng Gia (Cloud Cape)
  void _drawCloudCape(Canvas canvas, Size size, Color robeColor) {
    final w = size.width;
    final h = size.height;

    final capePaint = Paint()
      ..color = robeColor
      ..style = PaintingStyle.fill;
    final goldBorderPaint = Paint()
      ..color = AppColors.butterDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Vạt áo choàng bên trái buông rủ dọc sườn
    final leftCape = Path()
      ..moveTo(w * 0.33, h * 0.47)
      ..cubicTo(w * 0.22, h * 0.55, w * 0.20, h * 0.70, w * 0.25, h * 0.78)
      ..cubicTo(w * 0.29, h * 0.79, w * 0.34, h * 0.76, w * 0.36, h * 0.72)
      ..cubicTo(w * 0.32, h * 0.64, w * 0.34, h * 0.54, w * 0.36, h * 0.48)
      ..close();
    canvas.drawPath(leftCape, capePaint);
    canvas.drawPath(leftCape, goldBorderPaint);

    // Vạt áo choàng bên phải buông rủ dọc sườn
    final rightCape = Path()
      ..moveTo(w * 0.67, h * 0.47)
      ..cubicTo(w * 0.78, h * 0.55, w * 0.80, h * 0.70, w * 0.75, h * 0.78)
      ..cubicTo(w * 0.71, h * 0.79, w * 0.66, h * 0.76, w * 0.64, h * 0.72)
      ..cubicTo(w * 0.68, h * 0.64, w * 0.66, h * 0.54, w * 0.64, h * 0.48)
      ..close();
    canvas.drawPath(rightCape, capePaint);
    canvas.drawPath(rightCape, goldBorderPaint);

    // Cổ áo viền lông mây trắng mềm quanh ngực
    final collarPath = Path()
      ..moveTo(w * 0.32, h * 0.46)
      ..quadraticBezierTo(w * 0.50, h * 0.53, w * 0.68, h * 0.46)
      ..quadraticBezierTo(w * 0.50, h * 0.49, w * 0.32, h * 0.46);
    final collarPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    canvas.drawPath(collarPath, collarPaint);

    // Chùm mây lông trắng viền cổ áo
    final puffPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 5; i++) {
      final t = i / 4.0;
      final cx = w * (0.35 + t * 0.30);
      final cy = h * (0.47 + sin(t * pi) * 0.04);
      canvas.drawCircle(Offset(cx, cy), w * 0.024, puffPaint);
    }

    // Trâm cài áo hình ngôi sao vàng kim lấp lánh ở giữa ngực
    _drawStarStamp(canvas, Offset(w * 0.50, h * 0.505), w * 0.038, AppColors.butterWarm);
    canvas.drawCircle(Offset(w * 0.50, h * 0.505), w * 0.012, Paint()..color = Colors.white);
  }

  /// Váy Bồng Công Chúa (Fluffy Tutu Dress)
  void _drawPastelDress(Canvas canvas, Size size, Color robeColor) {
    final w = size.width;
    final h = size.height;

    final dressPaint = Paint()..color = robeColor;
    final lacePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 1. Thân áo trên (Bodice)
    final bodice = Path()
      ..moveTo(w * 0.37, h * 0.52)
      ..cubicTo(w * 0.43, h * 0.54, w * 0.57, h * 0.54, w * 0.63, h * 0.52)
      ..lineTo(w * 0.65, h * 0.62)
      ..lineTo(w * 0.35, h * 0.62)
      ..close();
    canvas.drawPath(bodice, dressPaint);

    // Viền ren cổ áo chữ V mềm mại
    final neckLace = Path()
      ..moveTo(w * 0.37, h * 0.52)
      ..cubicTo(w * 0.43, h * 0.54, w * 0.57, h * 0.54, w * 0.63, h * 0.52);
    canvas.drawPath(neckLace, lacePaint);

    // Dây đan ruy-băng trắng chéo giữa ngực
    final ribbonPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawLine(Offset(w * 0.46, h * 0.54), Offset(w * 0.54, h * 0.58), ribbonPaint);
    canvas.drawLine(Offset(w * 0.54, h * 0.54), Offset(w * 0.46, h * 0.58), ribbonPaint);

    // 2. Tùng váy bồng xòe nhiều tầng (Tutu Skirt)
    final skirt = Path()
      ..moveTo(w * 0.35, h * 0.62)
      ..cubicTo(w * 0.22, h * 0.66, w * 0.20, h * 0.77, w * 0.27, h * 0.79)
      ..cubicTo(w * 0.40, h * 0.81, w * 0.60, h * 0.81, w * 0.73, h * 0.79)
      ..cubicTo(w * 0.80, h * 0.77, w * 0.78, h * 0.66, w * 0.65, h * 0.62)
      ..close();
    canvas.drawPath(skirt, dressPaint);

    // Gấu váy lượn sóng viền ren (Scalloped frills)
    final frillPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (int i = 0; i < 7; i++) {
      final t = i / 6.0;
      final fx = w * (0.28 + t * 0.44);
      final fy = h * (0.785 + sin(t * pi) * 0.02);
      canvas.drawCircle(Offset(fx, fy), w * 0.022, frillPaint);
    }

    // 3. Thắt lưng ruy-băng nơ ngọt ngào
    final sashPaint = Paint()..color = AppColors.butterYellow;
    final sashRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.62), width: w * 0.32, height: h * 0.032),
      const Radius.circular(8),
    );
    canvas.drawRRect(sashRect, sashPaint);
    canvas.drawRRect(sashRect, Paint()..color = AppColors.butterDark..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Trái tim đá quý ở khóa thắt lưng
    _drawHeartStamp(canvas, Offset(w * 0.50, h * 0.62), w * 0.024, AppColors.roseSoft);
  }

  /// Áo Gi-lê Sao Lịch Lãm (Starry Vest)
  void _drawStarryVest(Canvas canvas, Size size, Color robeColor) {
    final w = size.width;
    final h = size.height;

    final vestPaint = Paint()..color = robeColor;
    final goldTrim = Paint()
      ..color = AppColors.butterWarm
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Vạt gi-lê bên trái: để hở phần bụng giữa cho bé rồng
    final leftVest = Path()
      ..moveTo(w * 0.35, h * 0.50)
      ..lineTo(w * 0.30, h * 0.73)
      ..lineTo(w * 0.43, h * 0.71)
      ..lineTo(w * 0.42, h * 0.56)
      ..close();
    canvas.drawPath(leftVest, vestPaint);
    canvas.drawPath(leftVest, goldTrim);

    // Cúc áo vàng kim bên trái
    final buttonPaint = Paint()..color = AppColors.butterYellow;
    canvas.drawCircle(Offset(w * 0.39, h * 0.60), w * 0.016, buttonPaint);
    canvas.drawCircle(Offset(w * 0.38, h * 0.66), w * 0.016, buttonPaint);
    canvas.drawCircle(Offset(w * 0.39, h * 0.60), w * 0.006, Paint()..color = AppColors.butterDark);
    canvas.drawCircle(Offset(w * 0.38, h * 0.66), w * 0.006, Paint()..color = AppColors.butterDark);

    // Vạt gi-lê bên phải
    final rightVest = Path()
      ..moveTo(w * 0.65, h * 0.50)
      ..lineTo(w * 0.70, h * 0.73)
      ..lineTo(w * 0.57, h * 0.71)
      ..lineTo(w * 0.58, h * 0.56)
      ..close();
    canvas.drawPath(rightVest, vestPaint);
    canvas.drawPath(rightVest, goldTrim);

    // Khuyết áo vàng kim bên phải
    final slotPaint = Paint()
      ..color = AppColors.butterDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.60, h * 0.60), Offset(w * 0.62, h * 0.60), slotPaint);
    canvas.drawLine(Offset(w * 0.61, h * 0.66), Offset(w * 0.63, h * 0.66), slotPaint);

    // Khăn tay vàng ngôi sao cài túi áo bên trái
    final pocketPath = Path()
      ..moveTo(w * 0.32, h * 0.66)
      ..lineTo(w * 0.35, h * 0.63)
      ..lineTo(w * 0.37, h * 0.66);
    canvas.drawPath(pocketPath, Paint()..color = Colors.white..style = PaintingStyle.fill);
  }

  /// Áo Lụa Đêm Sao Kimono (Moonlit Gown)
  void _drawNightGown(Canvas canvas, Size size, Color robeColor) {
    final w = size.width;
    final h = size.height;

    final gownPaint = Paint()..color = robeColor;
    final goldTrim = Paint()
      ..color = AppColors.butterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    // Vạt áo lụa đắp chéo phong cách hoàng cung
    final gownBody = Path()
      ..moveTo(w * 0.35, h * 0.50)
      ..cubicTo(w * 0.28, h * 0.60, w * 0.25, h * 0.74, w * 0.30, h * 0.80)
      ..lineTo(w * 0.70, h * 0.80)
      ..cubicTo(w * 0.75, h * 0.74, w * 0.72, h * 0.60, w * 0.65, h * 0.50)
      ..close();
    canvas.drawPath(gownBody, gownPaint);

    // Cổ áo lụa đắp chéo sang phải
    final lapelCross = Path()
      ..moveTo(w * 0.37, h * 0.50)
      ..lineTo(w * 0.60, h * 0.63);
    canvas.drawPath(lapelCross, goldTrim);

    // Đai lụa Obi quanh eo
    final obiRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.63), width: w * 0.36, height: h * 0.05),
      const Radius.circular(6),
    );
    final obiPaint = Paint()..color = AppColors.lavenderPurple;
    canvas.drawRRect(obiRect, obiPaint);
    canvas.drawRRect(obiRect, goldTrim);

    // Huy hiệu trăng khuyết vàng giữa đai lụa
    final moonCenter = Offset(w * 0.50, h * 0.63);
    final moonPaint = Paint()..color = AppColors.butterWarm;
    canvas.drawCircle(moonCenter, w * 0.026, moonPaint);
    canvas.drawCircle(Offset(moonCenter.dx + 4, moonCenter.dy - 2), w * 0.022, Paint()..color = AppColors.lavenderPurple);

    // Dải ruy băng lụa buông rủ từ đai eo
    final ribbonTail = Path()
      ..moveTo(w * 0.48, h * 0.65)
      ..lineTo(w * 0.46, h * 0.76)
      ..lineTo(w * 0.50, h * 0.74)
      ..lineTo(w * 0.54, h * 0.76)
      ..lineTo(w * 0.52, h * 0.65);
    canvas.drawPath(ribbonTail, Paint()..color = AppColors.roseSoft);
  }

  // ===========================================================================
  // 2. MŨ & VƯƠNG MIỆN (Hats & Tiaras)
  // ===========================================================================
  void _drawEquippedHat(Canvas canvas, Size size) {
    final hatId = character.equippedItems[ItemCategory.hat.name];
    if (hatId == null) return;

    final item = WardrobeItem.getById(hatId);
    final hatColor = character.equippedColors[hatId] ?? item?.defaultColor ?? AppColors.butterYellow;

    switch (hatId) {
      case 'hat_star_crown':
        _drawStarCrown(canvas, size, hatColor);
        break;
      case 'hat_cloud_beret':
        _drawCloudBeret(canvas, size, hatColor);
        break;
      case 'hat_flower_wreath':
        _drawFlowerWreath(canvas, size, hatColor);
        break;
      case 'hat_nightcap':
        _drawNightcap(canvas, size, hatColor);
        break;
      case 'hat_dragon_tiara':
        _drawDragonTiara(canvas, size, hatColor);
        break;
      default:
        _drawStarCrown(canvas, size, hatColor);
        break;
    }
  }

  /// Vương Miện Sao Hoàng Gia (Star Crown)
  void _drawStarCrown(Canvas canvas, Size size, Color hatColor) {
    final w = size.width;
    final h = size.height;

    final crownPaint = Paint()..color = hatColor;
    final goldOutline = Paint()
      ..color = AppColors.butterDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    final crownPath = Path()
      ..moveTo(w * 0.38, h * 0.17)
      ..lineTo(w * 0.36, h * 0.09) // Đỉnh nhọn trái
      ..lineTo(w * 0.44, h * 0.13) // Thung lũng 1
      ..lineTo(w * 0.50, h * 0.05) // Đỉnh nhọn giữa (cao nhất)
      ..lineTo(w * 0.56, h * 0.13) // Thung lũng 2
      ..lineTo(w * 0.64, h * 0.09) // Đỉnh nhọn phải
      ..lineTo(w * 0.62, h * 0.17) // Đế vương miện
      ..close();

    canvas.drawPath(crownPath, crownPaint);
    canvas.drawPath(crownPath, goldOutline);

    // Viên hồng ngọc lấp lánh trên đỉnh cao nhất
    _drawHeartStamp(canvas, Offset(w * 0.50, h * 0.06), w * 0.020, AppColors.roseDark);

    // 2 viên ngọc lam ở đỉnh 2 bên
    canvas.drawCircle(Offset(w * 0.36, h * 0.09), w * 0.015, Paint()..color = AppColors.skyBlue);
    canvas.drawCircle(Offset(w * 0.64, h * 0.09), w * 0.015, Paint()..color = AppColors.skyBlue);

    // Hàng ngọc trai đính trên vành đế
    for (int i = 0; i < 4; i++) {
      final px = w * (0.42 + i * 0.05);
      canvas.drawCircle(Offset(px, h * 0.16), w * 0.011, Paint()..color = Colors.white);
    }
  }

  /// Mũ Mây Họa Sĩ Bồng Bềnh (Cloud Beret)
  void _drawCloudBeret(Canvas canvas, Size size, Color hatColor) {
    final w = size.width;
    final h = size.height;

    canvas.save();
    canvas.translate(w * 0.52, h * 0.14);
    canvas.rotate(0.12); // Nghiêng nhẹ tạo vẻ nghệ sĩ đáng yêu

    final beretPaint = Paint()..color = hatColor;
    final beretOutline = Paint()
      ..color = AppColors.strokeSoft.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // 5 chùm mây bồng bềnh ghép thành mũ
    final beretPath = Path()
      ..addOval(Rect.fromCenter(center: const Offset(-20, 0), width: w * 0.22, height: h * 0.09))
      ..addOval(Rect.fromCenter(center: const Offset(20, -2), width: w * 0.22, height: h * 0.09))
      ..addOval(Rect.fromCenter(center: const Offset(0, -10), width: w * 0.26, height: h * 0.10))
      ..addOval(Rect.fromCenter(center: const Offset(0, 4), width: w * 0.32, height: h * 0.08));

    canvas.drawPath(beretPath, beretPaint);
    canvas.drawPath(beretPath, beretOutline);

    // Cuống mũ mây xinh xắn ở đỉnh
    final stemPaint = Paint()
      ..color = AppColors.butterWarm
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, -18), const Offset(2, -26), stemPaint);

    // Huy hiệu ngôi sao đính trên mũ
    _drawStarStamp(canvas, const Offset(22, 2), w * 0.024, AppColors.butterYellow);

    canvas.restore();
  }

  /// Vòng Hoa Chuông Mùa Xuân (Flower Wreath)
  void _drawFlowerWreath(Canvas canvas, Size size, Color hatColor) {
    final w = size.width;
    final h = size.height;

    // Dây leo xanh biếc uốn vòng quanh trán
    final vinePaint = Paint()
      ..color = AppColors.mintGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final vinePath = Path()
      ..moveTo(w * 0.33, h * 0.18)
      ..quadraticBezierTo(w * 0.50, h * 0.13, w * 0.67, h * 0.18);
    canvas.drawPath(vinePath, vinePaint);

    // 5 đóa hoa pastel 5 cánh bung nở
    final flowerData = [
      {'x': w * 0.35, 'y': h * 0.175, 'r': w * 0.024, 'c': AppColors.skyBlue},
      {'x': w * 0.42, 'y': h * 0.150, 'r': w * 0.026, 'c': AppColors.butterYellow},
      {'x': w * 0.50, 'y': h * 0.135, 'r': w * 0.032, 'c': hatColor}, // Bông hoa chính
      {'x': w * 0.58, 'y': h * 0.150, 'r': w * 0.026, 'c': AppColors.lavenderPurple},
      {'x': w * 0.65, 'y': h * 0.175, 'r': w * 0.024, 'c': AppColors.roseSoft},
    ];

    for (final f in flowerData) {
      final center = Offset(f['x'] as double, f['y'] as double);
      final radius = f['r'] as double;
      final color = f['c'] as Color;

      // Vẽ 5 cánh hoa tròn quanh nhụy
      final petalPaint = Paint()..color = color;
      for (int i = 0; i < 5; i++) {
        final angle = i * 2 * pi / 5;
        final px = center.dx + radius * 0.65 * cos(angle);
        final py = center.dy + radius * 0.65 * sin(angle);
        canvas.drawCircle(Offset(px, py), radius * 0.48, petalPaint);
      }
      // Nhụy hoa vàng óng
      canvas.drawCircle(center, radius * 0.32, Paint()..color = AppColors.butterWarm);
    }
  }

  /// Mũ Ngủ Trăng Khuyết (Crescent Nightcap)
  void _drawNightcap(Canvas canvas, Size size, Color hatColor) {
    final w = size.width;
    final h = size.height;

    final capPaint = Paint()..color = hatColor;
    final capOutline = Paint()
      ..color = AppColors.strokeSoft.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Thân nón uốn cong từ trán rồi buông chùng sang bên phải
    final capPath = Path()
      ..moveTo(w * 0.38, h * 0.16)
      ..cubicTo(w * 0.42, h * 0.06, w * 0.56, h * 0.04, w * 0.64, h * 0.10)
      ..cubicTo(w * 0.72, h * 0.15, w * 0.74, h * 0.23, w * 0.71, h * 0.26)
      ..cubicTo(w * 0.66, h * 0.22, w * 0.64, h * 0.15, w * 0.58, h * 0.14)
      ..cubicTo(w * 0.52, h * 0.14, w * 0.46, h * 0.16, w * 0.40, h * 0.18)
      ..close();

    canvas.drawPath(capPath, capPaint);
    canvas.drawPath(capPath, capOutline);

    // Họa tiết trăng khuyết vàng trên mũ
    final moonCenter = Offset(w * 0.47, h * 0.13);
    canvas.drawCircle(moonCenter, w * 0.024, Paint()..color = AppColors.butterWarm);
    canvas.drawCircle(Offset(moonCenter.dx + 4, moonCenter.dy - 1), w * 0.020, capPaint);

    // Quả bông tròn trắng (Pompom) đung đưa ở chóp nón
    final pompomCenter = Offset(w * 0.71, h * 0.26);
    canvas.drawCircle(pompomCenter, w * 0.042, Paint()..color = Colors.white);
    canvas.drawCircle(
      pompomCenter,
      w * 0.042,
      Paint()..color = AppColors.strokeSoft.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 2.0,
    );

    // Vành lông mây trắng quanh đầu
    final rimPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 6; i++) {
      final rx = w * (0.38 + i * 0.045);
      canvas.drawCircle(Offset(rx, h * 0.17), w * 0.022, rimPaint);
    }
  }

  /// Vương Miện Pha Lê Rồng (Dragon Tiara)
  void _drawDragonTiara(Canvas canvas, Size size, Color hatColor) {
    final w = size.width;
    final h = size.height;

    final tiaraPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Vòm vương miện cánh pha lê
    final arch = Path()
      ..moveTo(w * 0.35, h * 0.17)
      ..cubicTo(w * 0.42, h * 0.10, w * 0.46, h * 0.08, w * 0.50, h * 0.07)
      ..cubicTo(w * 0.54, h * 0.08, w * 0.58, h * 0.10, w * 0.65, h * 0.17);
    canvas.drawPath(arch, tiaraPaint);

    // Viên kim cương rồng đa giác lấp lánh ở trung tâm
    final diamondPath = Path()
      ..moveTo(w * 0.50, h * 0.07)
      ..lineTo(w * 0.53, h * 0.11)
      ..lineTo(w * 0.50, h * 0.15)
      ..lineTo(w * 0.47, h * 0.11)
      ..close();
    canvas.drawPath(diamondPath, Paint()..color = hatColor);
    canvas.drawPath(diamondPath, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.8);

    // Ngôi sao lấp lánh phản chiếu trên kim cương
    _drawStarStamp(canvas, Offset(w * 0.50, h * 0.11), w * 0.015, Colors.white);
  }

  // ===========================================================================
  // 3. KHĂN QUÀNG & NƠ CỔ (Scarves, Bows, Necklaces)
  // ===========================================================================
  void _drawEquippedScarf(Canvas canvas, Size size) {
    final scarfId = character.equippedItems[ItemCategory.scarf.name];
    if (scarfId == null) return;

    final item = WardrobeItem.getById(scarfId);
    final scarfColor = character.equippedColors[scarfId] ?? item?.defaultColor ?? AppColors.peachSoft;

    switch (scarfId) {
      case 'scarf_ribbon':
        _drawRibbonBow(canvas, size, scarfColor);
        break;
      case 'scarf_cloud_boa':
        _drawCloudBoa(canvas, size, scarfColor);
        break;
      case 'scarf_bell_choker':
        _drawBellChoker(canvas, size, scarfColor);
        break;
      case 'scarf_pearl_necklace':
        _drawPearlNecklace(canvas, size, scarfColor);
        break;
      default:
        _drawRibbonBow(canvas, size, scarfColor);
        break;
    }
  }

  /// Nơ Lụa Mềm Bồng Bềnh (Silk Ribbon Bow)
  void _drawRibbonBow(Canvas canvas, Size size, Color scarfColor) {
    final w = size.width;
    final h = size.height;

    final bowPaint = Paint()..color = scarfColor;
    final bowOutline = Paint()
      ..color = AppColors.strokeSoft.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(w * 0.50, h * 0.46);

    // Cánh nơ bên trái
    final leftLoop = Path()
      ..moveTo(center.dx, center.dy)
      ..cubicTo(w * 0.44, h * 0.41, w * 0.38, h * 0.42, w * 0.40, h * 0.47)
      ..cubicTo(w * 0.42, h * 0.51, w * 0.46, h * 0.49, center.dx, center.dy)
      ..close();
    canvas.drawPath(leftLoop, bowPaint);
    canvas.drawPath(leftLoop, bowOutline);

    // Cánh nơ bên phải
    final rightLoop = Path()
      ..moveTo(center.dx, center.dy)
      ..cubicTo(w * 0.56, h * 0.41, w * 0.62, h * 0.42, w * 0.60, h * 0.47)
      ..cubicTo(w * 0.58, h * 0.51, w * 0.54, h * 0.49, center.dx, center.dy)
      ..close();
    canvas.drawPath(rightLoop, bowPaint);
    canvas.drawPath(rightLoop, bowOutline);

    // Dải ruy băng trái buông xuống có đuôi cá
    final leftTail = Path()
      ..moveTo(w * 0.48, h * 0.47)
      ..lineTo(w * 0.43, h * 0.56)
      ..lineTo(w * 0.46, h * 0.54)
      ..lineTo(w * 0.49, h * 0.56)
      ..lineTo(w * 0.49, h * 0.47);
    canvas.drawPath(leftTail, bowPaint);

    // Dải ruy băng phải buông xuống có đuôi cá
    final rightTail = Path()
      ..moveTo(w * 0.52, h * 0.47)
      ..lineTo(w * 0.57, h * 0.56)
      ..lineTo(w * 0.54, h * 0.54)
      ..lineTo(w * 0.51, h * 0.56)
      ..lineTo(w * 0.51, h * 0.47);
    canvas.drawPath(rightTail, bowPaint);

    // Nút thắt nơ ở chính giữa
    canvas.drawCircle(center, w * 0.030, bowPaint);
    canvas.drawCircle(center, w * 0.030, bowOutline);
    canvas.drawCircle(Offset(center.dx - 2, center.dy - 2), w * 0.010, Paint()..color = Colors.white);
  }

  /// Khăn Len Mây Mùa Đông Ấm Áp (Warm Cloud Scarf)
  void _drawCloudBoa(Canvas canvas, Size size, Color scarfColor) {
    final w = size.width;
    final h = size.height;

    final scarfPaint = Paint()..color = scarfColor;
    final trimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Vòng khăn quấn quanh cổ
    final wrapRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.465), width: w * 0.34, height: h * 0.065),
      const Radius.circular(16),
    );
    canvas.drawRRect(wrapRect, scarfPaint);
    canvas.drawRRect(wrapRect, trimPaint);

    // Đuôi khăn buông dài bên phải
    final tail = Path()
      ..moveTo(w * 0.56, h * 0.48)
      ..lineTo(w * 0.55, h * 0.64)
      ..lineTo(w * 0.64, h * 0.64)
      ..lineTo(w * 0.63, h * 0.48)
      ..close();
    canvas.drawPath(tail, scarfPaint);
    canvas.drawPath(tail, trimPaint);

    // 4 tua rua len ấm áp ở đuôi khăn
    final fringePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final fx = w * (0.56 + i * 0.024);
      canvas.drawLine(Offset(fx, h * 0.64), Offset(fx, h * 0.67), fringePaint);
    }
  }

  /// Chuông Gió Nhỏ Vàng Kim (Windchime Bell)
  void _drawBellChoker(Canvas canvas, Size size, Color scarfColor) {
    final w = size.width;
    final h = size.height;

    // Vòng cổ ruy băng màu pastel
    final bandPaint = Paint()
      ..color = scarfColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    final bandPath = Path()
      ..moveTo(w * 0.36, h * 0.455)
      ..quadraticBezierTo(w * 0.50, h * 0.48, w * 0.64, h * 0.455);
    canvas.drawPath(bandPath, bandPaint);

    // Chuông vàng tròn đung đưa ở giữa ngực
    final bellCenter = Offset(w * 0.50, h * 0.50);
    final bellRadius = w * 0.038;

    final bellPaint = Paint()..color = AppColors.butterWarm;
    canvas.drawCircle(bellCenter, bellRadius, bellPaint);
    canvas.drawCircle(bellCenter, bellRadius, Paint()..color = AppColors.butterDark..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // Rãnh ngang và lỗ tròn của chuông
    final slitPaint = Paint()
      ..color = const Color(0xFF6A4418)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawLine(
      Offset(bellCenter.dx - bellRadius * 0.7, bellCenter.dy + 3),
      Offset(bellCenter.dx + bellRadius * 0.7, bellCenter.dy + 3),
      slitPaint,
    );
    canvas.drawCircle(Offset(bellCenter.dx, bellCenter.dy + 3), 3.0, Paint()..color = const Color(0xFF6A4418));

    // Điểm bóng sáng trên chuông vàng
    canvas.drawCircle(Offset(bellCenter.dx - 4, bellCenter.dy - 4), bellRadius * 0.3, Paint()..color = Colors.white);
  }

  /// Vòng Ngọc Trai Mây Lấp Lánh (Cloud Pearls)
  void _drawPearlNecklace(Canvas canvas, Size size, Color scarfColor) {
    final w = size.width;
    final h = size.height;

    // Chuỗi 9 viên ngọc trai ánh xà cừ xếp thành vòng cung
    for (int i = 0; i < 9; i++) {
      final t = i / 8.0;
      final px = w * (0.36 + t * 0.28);
      final py = h * (0.455 + sin(t * pi) * 0.05);
      final pr = w * (0.016 + sin(t * pi) * 0.010); // Hạt giữa to nhất

      // Thân hạt ngọc màu trắng sữa ánh pastel
      canvas.drawCircle(Offset(px, py), pr, Paint()..color = const Color(0xFFFFFDF5));
      canvas.drawCircle(
        Offset(px, py),
        pr,
        Paint()..color = AppColors.strokeSoft.withValues(alpha: 0.25)..style = PaintingStyle.stroke..strokeWidth = 1.0,
      );
      // Đốm sáng ngọc trai
      canvas.drawCircle(Offset(px - pr * 0.3, py - pr * 0.3), pr * 0.35, Paint()..color = Colors.white);
    }

    // Mặt dây chuyền hình trái tim đính dưới hạt ngọc chính giữa
    _drawHeartStamp(canvas, Offset(w * 0.50, h * 0.525), w * 0.022, scarfColor);
  }

  // ===========================================================================
  // 4. KÍNH MẮT & MẶT NẠ (Glasses & Masks)
  // ===========================================================================
  void _drawEquippedGlasses(Canvas canvas, Size size) {
    final glassesId = character.equippedItems[ItemCategory.glasses.name];
    if (glassesId == null) return;

    final item = WardrobeItem.getById(glassesId);
    final gColor = character.equippedColors[glassesId] ?? item?.defaultColor ?? AppColors.butterYellow;

    switch (glassesId) {
      case 'glasses_star':
        _drawStarGlasses(canvas, size, gColor);
        break;
      case 'glasses_heart':
        _drawHeartGlasses(canvas, size, gColor);
        break;
      case 'glasses_cloud_mask':
        _drawCloudMask(canvas, size, gColor);
        break;
      default:
        _drawStarGlasses(canvas, size, gColor);
        break;
    }
  }

  /// Kính Ngôi Sao Siêu Ngầu (Star Glasses)
  void _drawStarGlasses(Canvas canvas, Size size, Color gColor) {
    final w = size.width;
    final h = size.height;

    final eyeY = h * 0.33;
    final leftX = w * 0.42;
    final rightX = w * 0.58;
    final starRadius = w * 0.082;

    // Tròng kính ngôi sao trong suốt
    _drawStarStamp(canvas, Offset(leftX, eyeY), starRadius, gColor.withValues(alpha: 0.35));
    _drawStarStamp(canvas, Offset(rightX, eyeY), starRadius, gColor.withValues(alpha: 0.35));

    // Khung kính ngôi sao màu đậm viền nổi
    final framePaint = Paint()
      ..color = gColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeJoin = StrokeJoin.round;

    final leftStar = _createStarPath(Offset(leftX, eyeY), starRadius, starRadius * 0.48);
    final rightStar = _createStarPath(Offset(rightX, eyeY), starRadius, starRadius * 0.48);
    canvas.drawPath(leftStar, framePaint);
    canvas.drawPath(rightStar, framePaint);

    // Cầu kính nối giữa hai mắt
    final bridgePaint = Paint()
      ..color = gColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(leftX + w * 0.05, eyeY), Offset(rightX - w * 0.05, eyeY), bridgePaint);

    // Vệt sáng lấp lánh phản chiếu trên mắt kính
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(leftX - 10, eyeY - 8), Offset(leftX + 2, eyeY - 20), shinePaint);
    canvas.drawLine(Offset(rightX - 10, eyeY - 8), Offset(rightX + 2, eyeY - 20), shinePaint);
  }

  /// Kính Trái Tim Ngọt Ngào (Heart Shades)
  void _drawHeartGlasses(Canvas canvas, Size size, Color gColor) {
    final w = size.width;
    final h = size.height;

    final eyeY = h * 0.33;
    final leftX = w * 0.42;
    final rightX = w * 0.58;
    final hr = w * 0.075;

    // Tròng kính trái tim trong suốt
    _drawHeartStamp(canvas, Offset(leftX, eyeY), hr, gColor.withValues(alpha: 0.40));
    _drawHeartStamp(canvas, Offset(rightX, eyeY), hr, gColor.withValues(alpha: 0.40));

    // Khung kính viền nổi
    final framePaint = Paint()
      ..color = gColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final leftHeart = _createHeartPath(Offset(leftX, eyeY), hr);
    final rightHeart = _createHeartPath(Offset(rightX, eyeY), hr);
    canvas.drawPath(leftHeart, framePaint);
    canvas.drawPath(rightHeart, framePaint);

    // Cầu nối ngang mũi
    canvas.drawLine(Offset(leftX + w * 0.045, eyeY - 4), Offset(rightX - w * 0.045, eyeY - 4), framePaint);

    // Vệt sáng phản chiếu
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(leftX - 8, eyeY - 12), Offset(leftX + 4, eyeY - 18), shinePaint);
    canvas.drawLine(Offset(rightX - 8, eyeY - 12), Offset(rightX + 4, eyeY - 18), shinePaint);
  }

  /// Mặt Nạ Vũ Hội Dạ Yến (Masquerade Mask)
  void _drawCloudMask(Canvas canvas, Size size, Color gColor) {
    final w = size.width;
    final h = size.height;

    final eyeY = h * 0.33;
    final leftX = w * 0.42;
    final rightX = w * 0.58;

    // Mặt nạ cánh bướm dạ hội
    final maskPath = Path()
      ..moveTo(w * 0.28, h * 0.27)
      ..cubicTo(w * 0.36, h * 0.29, w * 0.44, h * 0.32, w * 0.50, h * 0.34) // Mũi
      ..cubicTo(w * 0.56, h * 0.32, w * 0.64, h * 0.29, w * 0.72, h * 0.27) // Cánh phải
      ..cubicTo(w * 0.70, h * 0.38, w * 0.62, h * 0.40, w * 0.50, h * 0.37)
      ..cubicTo(w * 0.38, h * 0.40, w * 0.30, h * 0.38, w * 0.28, h * 0.27)
      ..close();

    final maskPaint = Paint()..color = gColor.withValues(alpha: 0.88);
    final goldBorder = Paint()
      ..color = AppColors.butterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(maskPath, maskPaint);
    canvas.drawPath(maskPath, goldBorder);

    // Khoét 2 lỗ mắt để nhìn thấy mắt rồng con
    final eyeCutout = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(Rect.fromCenter(center: Offset(leftX, eyeY), width: w * 0.10, height: h * 0.06), eyeCutout);
    canvas.drawOval(Rect.fromCenter(center: Offset(rightX, eyeY), width: w * 0.10, height: h * 0.06), eyeCutout);

    // Lông vũ tím đính ở giữa trán mặt nạ
    final featherPath = Path()
      ..moveTo(w * 0.50, h * 0.32)
      ..cubicTo(w * 0.46, h * 0.24, w * 0.47, h * 0.18, w * 0.50, h * 0.16)
      ..cubicTo(w * 0.53, h * 0.18, w * 0.54, h * 0.24, w * 0.50, h * 0.32);
    canvas.drawPath(featherPath, Paint()..color = AppColors.lavenderPurple);
    canvas.drawPath(featherPath, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // Viên ngọc đính ở gốc lông vũ
    canvas.drawCircle(Offset(w * 0.50, h * 0.32), w * 0.016, Paint()..color = AppColors.butterWarm);
  }

  // ===========================================================================
  // 5. CÁNH PHỤ PHÍA SAU & HÀO QUANG (Wings Deco)
  // ===========================================================================
  void _drawWingsDecoBackground(Canvas canvas, Size size) {
    final wingsDecoId = character.equippedItems[ItemCategory.wingsDeco.name];
    if (wingsDecoId == null) return;

    final item = WardrobeItem.getById(wingsDecoId);
    final wColor = character.equippedColors[wingsDecoId] ?? item?.defaultColor ?? AppColors.mintGreen;

    if (wingsDecoId == 'wings_sparkle') {
      _drawFairyWings(canvas, size, wColor);
    } else if (wingsDecoId == 'wings_feather') {
      _drawFeatherWings(canvas, size, wColor);
    }
  }

  /// Cánh Bướm Tiên Lấp Lánh Phía Sau (Fairy Wings)
  void _drawFairyWings(Canvas canvas, Size size, Color wColor) {
    final w = size.width;
    final h = size.height;

    final wingPaint = Paint()
      ..color = wColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final veinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Cánh tiên trên bên trái (rộng và bay bổng hơn cánh rồng tự nhiên)
    final leftTop = Path()
      ..moveTo(w * 0.30, h * 0.40)
      ..cubicTo(w * 0.14, h * 0.24, w * 0.04, h * 0.10, w * 0.08, h * 0.08)
      ..cubicTo(w * 0.16, h * 0.07, w * 0.22, h * 0.20, w * 0.28, h * 0.34)
      ..close();
    canvas.drawPath(leftTop, wingPaint);
    canvas.drawPath(leftTop, veinPaint);

    // Cánh tiên dưới bên trái
    final leftBottom = Path()
      ..moveTo(w * 0.28, h * 0.40)
      ..cubicTo(w * 0.10, h * 0.46, w * 0.06, h * 0.58, w * 0.14, h * 0.62)
      ..cubicTo(w * 0.22, h * 0.62, w * 0.25, h * 0.50, w * 0.30, h * 0.46)
      ..close();
    canvas.drawPath(leftBottom, wingPaint);
    canvas.drawPath(leftBottom, veinPaint);

    // Cánh tiên trên bên phải
    final rightTop = Path()
      ..moveTo(w * 0.70, h * 0.40)
      ..cubicTo(w * 0.86, h * 0.24, w * 0.96, h * 0.10, w * 0.92, h * 0.08)
      ..cubicTo(w * 0.84, h * 0.07, w * 0.78, h * 0.20, w * 0.72, h * 0.34)
      ..close();
    canvas.drawPath(rightTop, wingPaint);
    canvas.drawPath(rightTop, veinPaint);

    // Cánh tiên dưới bên phải
    final rightBottom = Path()
      ..moveTo(w * 0.72, h * 0.40)
      ..cubicTo(w * 0.90, h * 0.46, w * 0.94, h * 0.58, w * 0.86, h * 0.62)
      ..cubicTo(w * 0.78, h * 0.62, w * 0.75, h * 0.50, w * 0.70, h * 0.46)
      ..close();
    canvas.drawPath(rightBottom, wingPaint);
    canvas.drawPath(rightBottom, veinPaint);

    // Những ngôi sao bụi tiên bay quanh cánh
    _drawStarStamp(canvas, Offset(w * 0.08, h * 0.15), w * 0.022, AppColors.butterWarm);
    _drawStarStamp(canvas, Offset(w * 0.92, h * 0.15), w * 0.022, AppColors.butterWarm);
    _drawStarStamp(canvas, Offset(w * 0.06, h * 0.45), w * 0.016, Colors.white);
    _drawStarStamp(canvas, Offset(w * 0.94, h * 0.45), w * 0.016, Colors.white);
  }

  /// Cánh Thiên Thần Lông Vũ Trắng (Feather Wings)
  void _drawFeatherWings(Canvas canvas, Size size, Color wColor) {
    final w = size.width;
    final h = size.height;

    final featherFill = Paint()
      ..color = wColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    final featherEdge = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Cánh lông vũ trái: 3 tầng lông uốn cong mềm mại
    final leftWing = Path()
      ..moveTo(w * 0.30, h * 0.45)
      ..cubicTo(w * 0.18, h * 0.30, w * 0.06, h * 0.18, w * 0.04, h * 0.14) // Lông tầng 1
      ..cubicTo(w * 0.10, h * 0.18, w * 0.12, h * 0.28, w * 0.06, h * 0.26) // Lông tầng 2
      ..cubicTo(w * 0.12, h * 0.32, w * 0.14, h * 0.40, w * 0.10, h * 0.44) // Lông tầng 3
      ..cubicTo(w * 0.16, h * 0.48, w * 0.24, h * 0.52, w * 0.30, h * 0.48)
      ..close();
    canvas.drawPath(leftWing, featherFill);
    canvas.drawPath(leftWing, featherEdge);

    // Cánh lông vũ phải
    final rightWing = Path()
      ..moveTo(w * 0.70, h * 0.45)
      ..cubicTo(w * 0.82, h * 0.30, w * 0.94, h * 0.18, w * 0.96, h * 0.14)
      ..cubicTo(w * 0.90, h * 0.18, w * 0.88, h * 0.28, w * 0.94, h * 0.26)
      ..cubicTo(w * 0.88, h * 0.32, w * 0.86, h * 0.40, w * 0.90, h * 0.44)
      ..cubicTo(w * 0.84, h * 0.48, w * 0.76, h * 0.52, w * 0.70, h * 0.48)
      ..close();
    canvas.drawPath(rightWing, featherFill);
    canvas.drawPath(rightWing, featherEdge);
  }

  /// Hào Quang Thiên Sứ Bay Trên Đỉnh Đầu (Floating Halo)
  void _drawFloatingDeco(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final wingsDecoId = character.equippedItems[ItemCategory.wingsDeco.name];
    if (wingsDecoId == null || wingsDecoId != 'wings_halo') return;

    final item = WardrobeItem.getById(wingsDecoId);
    final wColor = character.equippedColors[wingsDecoId] ?? item?.defaultColor ?? AppColors.butterYellow;

    final haloCenter = Offset(w * 0.50, h * 0.07);

    // Vầng sáng phát quang lan tỏa (Glow Aura)
    final glowPaint = Paint()
      ..color = wColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0;
    canvas.drawOval(Rect.fromCenter(center: haloCenter, width: w * 0.28, height: h * 0.065), glowPaint);

    // Vòng hào quang vàng kim sắc nét
    final haloRing = Paint()
      ..color = AppColors.butterWarm
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawOval(Rect.fromCenter(center: haloCenter, width: w * 0.26, height: h * 0.055), haloRing);

    // 3 ngôi sao lấp lánh quay quanh vòng hào quang
    _drawStarStamp(canvas, Offset(w * 0.38, h * 0.060), w * 0.018, Colors.white);
    _drawStarStamp(canvas, Offset(w * 0.62, h * 0.060), w * 0.018, Colors.white);
    _drawStarStamp(canvas, Offset(w * 0.50, h * 0.095), w * 0.014, AppColors.butterWarm);
  }

  // ===========================================================================
  // CÁC HÀM TIỆN ÍCH HÌNH HỌC (Star & Heart Paths)
  // ===========================================================================
  Path _createStarPath(Offset center, double outerR, double innerR) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = -pi / 2 + i * 2 * pi / 5;
      final innerAngle = outerAngle + pi / 5;
      final pOuter = Offset(center.dx + outerR * cos(outerAngle), center.dy + outerR * sin(outerAngle));
      final pInner = Offset(center.dx + innerR * cos(innerAngle), center.dy + innerR * sin(innerAngle));
      if (i == 0) {
        path.moveTo(pOuter.dx, pOuter.dy);
      } else {
        path.lineTo(pOuter.dx, pOuter.dy);
      }
      path.lineTo(pInner.dx, pInner.dy);
    }
    path.close();
    return path;
  }

  Path _createHeartPath(Offset c, double r) {
    final path = Path();
    path.moveTo(c.dx, c.dy + r * 0.5);
    path.cubicTo(c.dx - r * 0.8, c.dy - r * 0.2, c.dx - r * 0.8, c.dy - r * 0.8, c.dx, c.dy - r * 0.4);
    path.cubicTo(c.dx + r * 0.8, c.dy - r * 0.8, c.dx + r * 0.8, c.dy - r * 0.2, c.dx, c.dy + r * 0.5);
    path.close();
    return path;
  }

  void _drawBellyScalePatterns(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final scalePaint = Paint()
      ..color = AppColors.butterDark.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int row = 0; row < 3; row++) {
      final y = h * (0.55 + row * 0.07);
      final path = Path()
        ..moveTo(w * 0.44, y)
        ..quadraticBezierTo(w * 0.50, y + 8, w * 0.56, y);
      canvas.drawPath(path, scalePaint);
    }
  }

  void _drawDorsalSpikes(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final spikePaint = Paint()
      ..color = character.hornsColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.50, h * 0.16), w * 0.035, spikePaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.20), w * 0.038, spikePaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.25), w * 0.035, spikePaint);
  }

  void _drawWingRibs(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ribPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(w * 0.26, h * 0.36), Offset(w * 0.16, h * 0.24), ribPaint);
    canvas.drawLine(Offset(w * 0.74, h * 0.36), Offset(w * 0.84, h * 0.24), ribPaint);
  }

  void _drawSelectionAura(Canvas canvas, Size size, DragonPart part) {
    final auraPaint = Paint()
      ..color = AppColors.butterYellow.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final maskPath = DragonPaths.getMaskPathForPart(part, size);
    canvas.drawPath(maskPath, auraPaint);
  }

  @override
  bool shouldRepaint(covariant DragonPainter oldDelegate) => true;
}
