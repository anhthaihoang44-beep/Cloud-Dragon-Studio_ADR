import 'package:flutter/material.dart';

enum DrawingToolType {
  brush,
  gradient,
  stampCloud,
  stampStar,
  stampHeart,
  eraser,
}

/// Một nét vẽ hoặc con dấu lưu giữ tọa độ
class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final DrawingToolType toolType;
  final List<Color>? gradientColors; // Nếu là gradient fill

  DrawingStroke({
    required this.points,
    required this.color,
    this.strokeWidth = 14.0,
    this.toolType = DrawingToolType.brush,
    this.gradientColors,
  });

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'color': color.value,
      'strokeWidth': strokeWidth,
      'toolType': toolType.index,
      if (gradientColors != null)
        'gradientColors': gradientColors!.map((c) => c.value).toList(),
    };
  }

  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    final pointsList = (json['points'] as List)
        .map((item) => Offset((item['x'] as num).toDouble(), (item['y'] as num).toDouble()))
        .toList();
    return DrawingStroke(
      points: pointsList,
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 14.0,
      toolType: DrawingToolType.values[json['toolType'] as int? ?? 0],
      gradientColors: json['gradientColors'] != null
          ? (json['gradientColors'] as List).map((c) => Color(c as int)).toList()
          : null,
    );
  }
}

