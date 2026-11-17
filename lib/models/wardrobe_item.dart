import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum ItemCategory {
  hat,
  robe,
  scarf,
  glasses,
  wingsDeco,
}

class WardrobeItem {
  final String id;
  final ItemCategory category;
  final String nameVi;
  final String nameEn;
  final Color defaultColor;
  final bool isFree;
  final String previewSymbol; // Icon emoji trực quan

  const WardrobeItem({
    required this.id,
    required this.category,
    required this.nameVi,
    required this.nameEn,
    this.defaultColor = AppColors.lavenderPurple,
    this.isFree = true,
    required this.previewSymbol,
  });

  static WardrobeItem? getById(String id) {
    for (final item in catalog) {
      if (item.id == id) return item;
    }
    return null;
  }

  static const List<WardrobeItem> catalog = [
    // 1. HATS & TIARAS (Mũ & Vương miện)
    WardrobeItem(
      id: 'hat_star_crown',
      category: ItemCategory.hat,
      nameVi: 'Vương Miện Sao',
      nameEn: 'Star Crown',
      defaultColor: AppColors.butterYellow,
      previewSymbol: '👑',
      isFree: true,
    ),
    WardrobeItem(
      id: 'hat_cloud_beret',
      category: ItemCategory.hat,
      nameVi: 'Mũ Mây Bồng',
      nameEn: 'Cloud Beret',
      defaultColor: AppColors.skyBlue,
      previewSymbol: '☁️',
      isFree: true,
    ),
    WardrobeItem(
      id: 'hat_flower_wreath',
      category: ItemCategory.hat,
      nameVi: 'Vòng Hoa Chuông',
      nameEn: 'Flower Wreath',
      defaultColor: AppColors.roseSoft,
      previewSymbol: '🌸',
      isFree: true,
    ),
    WardrobeItem(
      id: 'hat_nightcap',
      category: ItemCategory.hat,
      nameVi: 'Mũ Ngủ Trăng',
      nameEn: 'Crescent Cap',
      defaultColor: AppColors.lavenderPurple,
      previewSymbol: '🌙',
      isFree: true,
    ),
    WardrobeItem(
      id: 'hat_dragon_tiara',
      category: ItemCategory.hat,
      nameVi: 'Vương Miện Rồng',
      nameEn: 'Dragon Tiara',
      defaultColor: AppColors.mintGreen,
      previewSymbol: '💎',
      isFree: false, // 1 món thưởng
    ),

    // 2. ROBES & CAPES (Trang phục & Áo choàng)
    WardrobeItem(
      id: 'robe_cloud_cape',
      category: ItemCategory.robe,
      nameVi: 'Áo Choàng Mây',
      nameEn: 'Cloud Cape',
      defaultColor: AppColors.skyBlue,
      previewSymbol: '🧥',
      isFree: true,
    ),
    WardrobeItem(
      id: 'robe_pastel_dress',
      category: ItemCategory.robe,
      nameVi: 'Váy Bồng Xòe',
      nameEn: 'Fluffy Dress',
      defaultColor: AppColors.roseSoft,
      previewSymbol: '👗',
      isFree: true,
    ),
    WardrobeItem(
      id: 'robe_starry_vest',
      category: ItemCategory.robe,
      nameVi: 'Áo Gi-lê Sao',
      nameEn: 'Starry Vest',
      defaultColor: AppColors.butterYellow,
      previewSymbol: '🎽',
      isFree: true,
    ),
    WardrobeItem(
      id: 'robe_night_gown',
      category: ItemCategory.robe,
      nameVi: 'Áo Lụa Đêm Sao',
      nameEn: 'Moonlit Gown',
      defaultColor: AppColors.lavenderPurple,
      previewSymbol: '👘',
      isFree: false,
    ),

    // 3. SCARVES & BOWS (Khăn & Nơ cổ)
    WardrobeItem(
      id: 'scarf_ribbon',
      category: ItemCategory.scarf,
      nameVi: 'Nơ Lụa Mềm',
      nameEn: 'Silk Ribbon Bow',
      defaultColor: AppColors.peachSoft,
      previewSymbol: '🎀',
      isFree: true,
    ),
    WardrobeItem(
      id: 'scarf_cloud_boa',
      category: ItemCategory.scarf,
      nameVi: 'Khăn Choàng Ấm',
      nameEn: 'Warm Cloud Scarf',
      defaultColor: AppColors.cloudWhite,
      previewSymbol: '🧣',
      isFree: true,
    ),
    WardrobeItem(
      id: 'scarf_bell_choker',
      category: ItemCategory.scarf,
      nameVi: 'Chuông Gió Nhỏ',
      nameEn: 'Windchime Bell',
      defaultColor: AppColors.butterYellow,
      previewSymbol: '🔔',
      isFree: true,
    ),
    WardrobeItem(
      id: 'scarf_pearl_necklace',
      category: ItemCategory.scarf,
      nameVi: 'Vòng Ngọc Mây',
      nameEn: 'Cloud Pearls',
      defaultColor: AppColors.mintGreen,
      previewSymbol: '📿',
      isFree: true,
    ),

    // 4. GLASSES & MASKS (Kính mắt & Mặt nạ)
    WardrobeItem(
      id: 'glasses_star',
      category: ItemCategory.glasses,
      nameVi: 'Kính Ngôi Sao',
      nameEn: 'Star Glasses',
      defaultColor: AppColors.butterYellow,
      previewSymbol: '⭐',
      isFree: true,
    ),
    WardrobeItem(
      id: 'glasses_heart',
      category: ItemCategory.glasses,
      nameVi: 'Kính Trái Tim',
      nameEn: 'Heart Shades',
      defaultColor: AppColors.roseSoft,
      previewSymbol: '💖',
      isFree: true,
    ),
    WardrobeItem(
      id: 'glasses_cloud_mask',
      category: ItemCategory.glasses,
      nameVi: 'Mặt Nạ Vũ Hội',
      nameEn: 'Masquerade Mask',
      defaultColor: AppColors.lavenderPurple,
      previewSymbol: '🎭',
      isFree: false,
    ),

    // 5. WINGS & BACK DECORATIONS (Cánh tiên & Phụ kiện lưng)
    WardrobeItem(
      id: 'wings_sparkle',
      category: ItemCategory.wingsDeco,
      nameVi: 'Cánh Bướm Tiên',
      nameEn: 'Fairy Wings',
      defaultColor: AppColors.mintGreen,
      previewSymbol: '✨',
      isFree: true,
    ),
    WardrobeItem(
      id: 'wings_feather',
      category: ItemCategory.wingsDeco,
      nameVi: 'Cánh Lông Vũ',
      nameEn: 'Feather Wings',
      defaultColor: AppColors.lavenderPurple,
      previewSymbol: '🪶',
      isFree: true,
    ),
    WardrobeItem(
      id: 'wings_halo',
      category: ItemCategory.wingsDeco,
      nameVi: 'Vòng Hào Quang',
      nameEn: 'Star Halo',
      defaultColor: AppColors.butterYellow,
      previewSymbol: '💫',
      isFree: false,
    ),
  ];
}
