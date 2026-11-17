import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'drawing_stroke.dart';

enum DragonPart {
  horns,
  wings,
  body,
  belly,
  tail,
}

enum DragonExpression {
  happy,
  delighted,
  sleepy,
  wink,
  eating,
}

enum DragonPose {
  sitting,
  waving,
  flying,
}

/// Dữ liệu nhân vật Rồng Con Độc Bản
class DragonCharacter {
  final String id;
  String name;
  Color bodyColor;
  Color bellyColor;
  Color wingsColor;
  Color hornsColor;
  Color tailPuffColor;

  // Từng bộ phận có danh sách nét vẽ riêng (masking riêng biệt)
  final Map<DragonPart, List<DrawingStroke>> partStrokes;

  // Lịch sử undo riêng cho từng bộ phận
  final Map<DragonPart, List<DrawingStroke>> undoStrokes;

  // Trang phục đang mặc (key: slotCategory, value: item ID)
  final Map<String, String> equippedItems;
  final Map<String, Color> equippedColors; // Màu custom cho từng trang phục

  DragonExpression expression;
  DragonPose pose;
  bool isFoamed;
  bool isBathed;
  bool isDried;
  bool isBrushed;
  int hungerLevel; // 0..5

  DragonCharacter({
    required this.id,
    this.name = 'Cloudy Baby',
    this.bodyColor = AppColors.mintGreen,
    this.bellyColor = AppColors.butterYellow,
    this.wingsColor = AppColors.lavenderPurple,
    this.hornsColor = AppColors.peachSoft,
    this.tailPuffColor = AppColors.cloudWhite,
    Map<DragonPart, List<DrawingStroke>>? partStrokes,
    Map<DragonPart, List<DrawingStroke>>? undoStrokes,
    Map<String, String>? equippedItems,
    Map<String, Color>? equippedColors,
    this.expression = DragonExpression.happy,
    this.pose = DragonPose.sitting,
    this.isFoamed = false,
    this.isBathed = true,
    this.isDried = true,
    this.isBrushed = true,
    this.hungerLevel = 3,
  })  : partStrokes = partStrokes ?? {for (var part in DragonPart.values) part: []},
        undoStrokes = undoStrokes ?? {for (var part in DragonPart.values) part: []},
        equippedItems = equippedItems ?? {},
        equippedColors = equippedColors ?? {};

  // Thêm nét vẽ vào bộ phận cụ thể
  void addStroke(DragonPart part, DrawingStroke stroke) {
    partStrokes[part] ??= [];
    partStrokes[part]!.add(stroke);
    undoStrokes[part]?.clear();
  }

  // Hoàn tác (Undo) nét vẽ gần nhất của bộ phận
  bool undo(DragonPart part) {
    if (partStrokes[part] != null && partStrokes[part]!.isNotEmpty) {
      final removed = partStrokes[part]!.removeLast();
      undoStrokes[part] ??= [];
      undoStrokes[part]!.add(removed);
      return true;
    }
    return false;
  }

  // Xóa toàn bộ nét vẽ của bộ phận được chọn
  void clearPart(DragonPart part) {
    partStrokes[part]?.clear();
    undoStrokes[part]?.clear();
  }

  // Khởi tạo nhân vật mặc định
  factory DragonCharacter.createDefault(int slotIndex) {
    final names = [
      'Cloudy Baby',
      'Buttercup',
      'Minty Puff',
      'Lavender Star',
      'Peachy Pip',
      'Berry Swirl',
      'Moonbeam',
      'Bellflower',
      'Breezy Wing',
      'Dewdrop',
      'Sunny Sprout',
      'Cotton Candy',
    ];

    final bodyColors = [
      AppColors.mintGreen,
      AppColors.butterYellow,
      AppColors.lavenderPurple,
      AppColors.peachSoft,
      AppColors.skyBlue,
      AppColors.roseSoft,
    ];

    final bellyColors = [
      AppColors.butterWarm,
      AppColors.mintLight,
      AppColors.roseLight,
      AppColors.skyLight,
      AppColors.peachLight,
      AppColors.butterWarm,
    ];

    return DragonCharacter(
      id: 'slot_$slotIndex',
      name: names[slotIndex % names.length],
      bodyColor: bodyColors[slotIndex % bodyColors.length],
      bellyColor: bellyColors[slotIndex % bellyColors.length],
      wingsColor: bodyColors[(slotIndex + 2) % bodyColors.length],
      hornsColor: AppColors.peachSoft,
      tailPuffColor: AppColors.butterWarm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bodyColor': bodyColor.toARGB32(),
      'bellyColor': bellyColor.toARGB32(),
      'wingsColor': wingsColor.toARGB32(),
      'hornsColor': hornsColor.toARGB32(),
      'tailPuffColor': tailPuffColor.toARGB32(),
      'partStrokes': partStrokes.map(
        (key, value) => MapEntry(key.name, value.map((s) => s.toJson()).toList()),
      ),
      'equippedItems': equippedItems,
      'equippedColors': equippedColors.map((k, v) => MapEntry(k, v.toARGB32())),
      'expression': expression.name,
      'pose': pose.name,
      'isBathed': isBathed,
      'isDried': isDried,
      'isBrushed': isBrushed,
      'hungerLevel': hungerLevel,
    };
  }

  factory DragonCharacter.fromJson(Map<String, dynamic> json) {
    final strokesMap = <DragonPart, List<DrawingStroke>>{};
    if (json['partStrokes'] != null) {
      final rawMap = json['partStrokes'] as Map<String, dynamic>;
      for (final part in DragonPart.values) {
        if (rawMap[part.name] != null) {
          strokesMap[part] = (rawMap[part.name] as List)
              .map((item) => DrawingStroke.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          strokesMap[part] = [];
        }
      }
    }

    final eqItems = <String, String>{};
    if (json['equippedItems'] != null) {
      (json['equippedItems'] as Map<String, dynamic>).forEach((k, v) {
        eqItems[k] = v.toString();
      });
    }

    final eqColors = <String, Color>{};
    if (json['equippedColors'] != null) {
      (json['equippedColors'] as Map<String, dynamic>).forEach((k, v) {
        eqColors[k] = Color(v as int);
      });
    }

    return DragonCharacter(
      id: json['id'] as String? ?? 'slot_0',
      name: json['name'] as String? ?? 'Cloudy Baby',
      bodyColor: Color(json['bodyColor'] as int? ?? AppColors.mintGreen.toARGB32()),
      bellyColor: Color(json['bellyColor'] as int? ?? AppColors.butterYellow.toARGB32()),
      wingsColor: Color(json['wingsColor'] as int? ?? AppColors.lavenderPurple.toARGB32()),
      hornsColor: Color(json['hornsColor'] as int? ?? AppColors.peachSoft.toARGB32()),
      tailPuffColor: Color(json['tailPuffColor'] as int? ?? AppColors.cloudWhite.toARGB32()),
      partStrokes: strokesMap,
      equippedItems: eqItems,
      equippedColors: eqColors,
      expression: DragonExpression.values.firstWhere(
        (e) => e.name == json['expression'],
        orElse: () => DragonExpression.happy,
      ),
      pose: DragonPose.values.firstWhere(
        (p) => p.name == json['pose'],
        orElse: () => DragonPose.sitting,
      ),
      isBathed: json['isBathed'] as bool? ?? true,
      isDried: json['isDried'] as bool? ?? true,
      isBrushed: json['isBrushed'] as bool? ?? true,
      hungerLevel: json['hungerLevel'] as int? ?? 3,
    );
  }
}
