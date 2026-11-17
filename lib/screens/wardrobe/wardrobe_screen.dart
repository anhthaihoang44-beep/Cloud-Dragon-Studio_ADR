import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/audio/audio_service.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kids_app_bar.dart';
import '../../models/dragon_character.dart';
import '../../models/game_state.dart';
import '../../models/wardrobe_item.dart';
import '../scale_studio/painters/dragon_painter.dart';
import '../scale_studio/widgets/color_selector.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  ItemCategory _activeCategory = ItemCategory.hat;
  Color _selectedItemColor = AppColors.butterYellow;

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppStrings>();
    final gameState = context.watch<GameState>();
    final audio = context.read<AudioService>();
    final character = gameState.activeDragon;

    final categoryItems = WardrobeItem.catalog
        .where((item) => item.category == _activeCategory)
        .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFEEF3), // Hồng phấn ngọt ngào
              Color(0xFFEDE7F6), // Tím oải hương nhạt
              Color(0xFFFFF9C4), // Vàng bơ ấm
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              KidsAppBar(
                title: strings.zoneWardrobeTitle,
                subtitle: strings.zoneWardrobeDesc,
              ),

              // Thanh chuyển 5 danh mục thời trang sinh động
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryTab(ItemCategory.hat, strings.catHats, AppColors.butterYellow, audio, character),
                      const SizedBox(width: 8),
                      _buildCategoryTab(ItemCategory.robe, strings.catRobes, AppColors.skyBlue, audio, character),
                      const SizedBox(width: 8),
                      _buildCategoryTab(ItemCategory.scarf, strings.catScarves, AppColors.roseSoft, audio, character),
                      const SizedBox(width: 8),
                      _buildCategoryTab(ItemCategory.glasses, strings.catGlasses, AppColors.mintGreen, audio, character),
                      const SizedBox(width: 8),
                      _buildCategoryTab(ItemCategory.wingsDeco, strings.catWings, AppColors.lavenderPurple, audio, character),
                    ],
                  ),
                ),
              ),

              // Phòng thay đồ hoàng gia sắc màu (Rèm lụa, thảm hoa, sao lấp lánh)
              Expanded(
                flex: 5,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFF0F5), // Lavender blush
                            Color(0xFFE8F5E9), // Mint sương sớm
                            Color(0xFFFFFDE7), // Nắng sớm
                          ],
                        ),
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.roseDark.withValues(alpha: 0.2),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: AppColors.roseSoft, width: 4.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Stack(
                          children: [
                            // Rèm nhung dạ hội hai bên phòng thử đồ
                            Positioned(
                              top: 0,
                              left: 10,
                              child: Text('🎪', style: TextStyle(fontSize: 32)),
                            ),
                            Positioned(
                              top: 0,
                              right: 10,
                              child: Text('🎪', style: TextStyle(fontSize: 32)),
                            ),
                            // Thảm nhung tròn màu hồng dâu dưới chân
                            Positioned(
                              bottom: 20,
                              left: 35,
                              right: 35,
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.roseSoft.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: Colors.white, width: 2.5),
                                ),
                              ),
                            ),
                            // Ngôi sao lấp lánh
                            Positioned(top: 25, left: 60, child: Text('✨', style: TextStyle(fontSize: 22))),
                            Positioned(top: 30, right: 60, child: Text('💫', style: TextStyle(fontSize: 22))),

                            // Nhân vật rồng con
                            Positioned.fill(
                              child: CustomPaint(
                                painter: DragonPainter(
                                  character: character,
                                  animationValue: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Danh sách vật phẩm có card màu sắc ngọt ngào (Không dùng màu trắng trơn)
              SizedBox(
                height: 108,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categoryItems.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isNone = character.equippedItems[_activeCategory.name] == null;
                      return GestureDetector(
                        onTap: () {
                          audio.playPop();
                          setState(() {
                            character.equippedItems.remove(_activeCategory.name);
                          });
                          gameState.notifyCharacterUpdated();
                        },
                        child: Container(
                          width: 88,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isNone
                                  ? [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)]
                                  : [const Color(0xFFFFF9E6), const Color(0xFFFFECEF)],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isNone ? AppColors.roseDark : AppColors.cardBorder,
                              width: isNone ? 3.0 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.peachDark.withValues(alpha: 0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🚫', style: TextStyle(fontSize: 32)),
                              const SizedBox(height: 4),
                              Text(
                                strings.currentLanguage == AppLanguage.vi ? 'Cởi bỏ' : 'None',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isNone ? AppColors.roseDark : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final item = categoryItems[index - 1];
                    final isEquipped = character.equippedItems[item.category.name] == item.id;

                    return GestureDetector(
                      onTap: () {
                        audio.playPop();
                        setState(() {
                          if (isEquipped) {
                            character.equippedItems.remove(item.category.name);
                          } else {
                            character.equippedItems[item.category.name] = item.id;
                            _selectedItemColor = character.equippedColors[item.id] ?? item.defaultColor;
                            character.equippedColors[item.id] = _selectedItemColor;
                            character.expression = DragonExpression.delighted;
                          }
                        });
                        gameState.notifyCharacterUpdated();
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 96,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isEquipped
                                    ? [AppColors.butterYellow, AppColors.butterWarm]
                                    : [const Color(0xFFFFF9E6), const Color(0xFFFFECEF)],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isEquipped ? AppColors.butterDark : AppColors.cardBorder,
                                width: isEquipped ? 3.5 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.peachDark.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(item.previewSymbol, style: const TextStyle(fontSize: 36)),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    strings.currentLanguage == AppLanguage.vi ? item.nameVi : item.nameEn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isEquipped)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.butterDark,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 14, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Bộ đổi màu cho MỌI món đồ
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: ColorSelector(
                  selectedColor: _selectedItemColor,
                  onColorChanged: (newColor) {
                    setState(() {
                      _selectedItemColor = newColor;
                      final currentEquipped = character.equippedItems[_activeCategory.name];
                      if (currentEquipped != null) {
                        character.equippedColors[currentEquipped] = newColor;
                      }
                    });
                    audio.playSparkle();
                    gameState.notifyCharacterUpdated();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(
    ItemCategory cat,
    String title,
    Color tabColor,
    AudioService audio,
    DragonCharacter character,
  ) {
    final isSelected = _activeCategory == cat;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeCategory = cat;
          final equippedId = character.equippedItems[cat.name];
          if (equippedId != null) {
            final item = WardrobeItem.getById(equippedId);
            _selectedItemColor = character.equippedColors[equippedId] ?? item?.defaultColor ?? AppColors.butterYellow;
          }
        });
        audio.playPop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? tabColor : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.textDark : AppColors.cardBorder,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
