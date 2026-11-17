import 'package:flutter/material.dart';
import '../../../models/dragon_character.dart';

/// Bộ tính toán Path Vector cho Bé Rồng Mây (Chibi Cloud Dragon)
/// Chuẩn hóa theo kích thước Canvas (tự co giãn hoàn hảo trên mọi màn hình điện thoại & tablet)
class DragonPaths {
  // 1. Path Cánh Rồng (Wings) - 2 cánh dang rộng nhẹ phía sau
  static Path getWingsPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Cánh trái
    path.moveTo(w * 0.28, h * 0.44);
    path.cubicTo(w * 0.10, h * 0.36, w * 0.05, h * 0.20, w * 0.16, h * 0.18);
    path.cubicTo(w * 0.25, h * 0.18, w * 0.20, h * 0.30, w * 0.28, h * 0.35);
    path.cubicTo(w * 0.18, h * 0.40, w * 0.22, h * 0.48, w * 0.30, h * 0.50);
    path.close();

    // Cánh phải
    path.moveTo(w * 0.72, h * 0.44);
    path.cubicTo(w * 0.90, h * 0.36, w * 0.95, h * 0.20, w * 0.84, h * 0.18);
    path.cubicTo(w * 0.75, h * 0.18, w * 0.80, h * 0.30, w * 0.72, h * 0.35);
    path.cubicTo(w * 0.82, h * 0.40, w * 0.78, h * 0.48, w * 0.70, h * 0.50);
    path.close();

    return path;
  }

  // 2. Path Đuôi Rồng (Tail) - Uốn lượn mềm sang bên phải
  static Path getTailPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    path.moveTo(w * 0.65, h * 0.72);
    path.cubicTo(w * 0.78, h * 0.72, w * 0.88, h * 0.68, w * 0.92, h * 0.60);
    path.cubicTo(w * 0.96, h * 0.62, w * 0.94, h * 0.75, w * 0.85, h * 0.80);
    path.cubicTo(w * 0.75, h * 0.84, w * 0.66, h * 0.80, w * 0.60, h * 0.78);
    path.close();

    // Thêm chỏm mây ở chóp đuôi
    path.addOval(Rect.fromCircle(center: Offset(w * 0.91, h * 0.60), radius: w * 0.065));
    path.addOval(Rect.fromCircle(center: Offset(w * 0.88, h * 0.56), radius: w * 0.05));

    return path;
  }

  // 3. Path Sừng Rồng (Horns) - 2 sừng xoắn nhẹ kiểu pastel
  static Path getHornsPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Sừng trái
    path.moveTo(w * 0.36, h * 0.22);
    path.cubicTo(w * 0.34, h * 0.14, w * 0.26, h * 0.08, w * 0.24, h * 0.06);
    path.cubicTo(w * 0.28, h * 0.12, w * 0.38, h * 0.16, w * 0.42, h * 0.20);
    path.close();

    // Sừng phải
    path.moveTo(w * 0.64, h * 0.22);
    path.cubicTo(w * 0.66, h * 0.14, w * 0.74, h * 0.08, w * 0.76, h * 0.06);
    path.cubicTo(w * 0.72, h * 0.12, w * 0.62, h * 0.16, w * 0.58, h * 0.20);
    path.close();

    return path;
  }

  // 4. Path Thân & Đầu Rồng (Body & Head) - Dáng quả lê mập mạp siêu đáng yêu
  static Path getBodyPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Bắt đầu từ đỉnh đầu
    path.moveTo(w * 0.50, h * 0.18);
    // Vòm đầu phải sang má phải
    path.cubicTo(w * 0.65, h * 0.18, w * 0.72, h * 0.26, w * 0.72, h * 0.36);
    // Má phải xuống vai & sườn phải
    path.cubicTo(w * 0.72, h * 0.44, w * 0.66, h * 0.50, w * 0.72, h * 0.60);
    // Hông phải xuống chân phải
    path.cubicTo(w * 0.76, h * 0.68, w * 0.74, h * 0.80, w * 0.65, h * 0.82);
    // Chân phải (bàn chân tròn múp)
    path.cubicTo(w * 0.58, h * 0.83, w * 0.55, h * 0.79, w * 0.50, h * 0.80);
    // Chân trái (bàn chân tròn múp)
    path.cubicTo(w * 0.45, h * 0.79, w * 0.42, h * 0.83, w * 0.35, h * 0.82);
    // Hông trái lên sườn trái
    path.cubicTo(w * 0.26, h * 0.80, w * 0.24, h * 0.68, w * 0.28, h * 0.60);
    // Sườn trái lên má trái
    path.cubicTo(w * 0.34, h * 0.50, w * 0.28, h * 0.44, w * 0.28, h * 0.36);
    // Má trái lên đỉnh đầu
    path.cubicTo(w * 0.28, h * 0.26, w * 0.35, h * 0.18, w * 0.50, h * 0.18);
    path.close();

    return path;
  }

  // 5. Path Bụng Vảy (Belly Scales) - Phần bụng sáng màu để bé tô vảy
  static Path getBellyPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Hình bầu dục mềm mại trên bụng
    path.moveTo(w * 0.50, h * 0.48);
    path.cubicTo(w * 0.62, h * 0.48, w * 0.65, h * 0.60, w * 0.64, h * 0.72);
    path.cubicTo(w * 0.63, h * 0.79, w * 0.56, h * 0.80, w * 0.50, h * 0.80);
    path.cubicTo(w * 0.44, h * 0.80, w * 0.37, h * 0.79, w * 0.36, h * 0.72);
    path.cubicTo(w * 0.35, h * 0.60, w * 0.38, h * 0.48, w * 0.50, h * 0.48);
    path.close();

    return path;
  }

  // Lấy Mask Path tương ứng cho từng bộ phận được chọn để tô màu
  static Path getMaskPathForPart(DragonPart part, Size size) {
    switch (part) {
      case DragonPart.horns:
        return getHornsPath(size);
      case DragonPart.wings:
        return getWingsPath(size);
      case DragonPart.tail:
        return getTailPath(size);
      case DragonPart.belly:
        return getBellyPath(size);
      case DragonPart.body:
        return getBodyPath(size);
    }
  }
}

