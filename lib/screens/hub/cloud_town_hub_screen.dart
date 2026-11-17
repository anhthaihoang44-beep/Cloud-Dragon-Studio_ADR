import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/audio/audio_service.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/widgets/kids_app_bar.dart';
import '../../models/game_state.dart';
import '../bake_nook/bake_nook_screen.dart';
import '../cloud_bath/cloud_bath_screen.dart';
import '../pet_garden/pet_garden_screen.dart';
import '../photo_booth/photo_booth_screen.dart';
import '../scale_studio/painters/dragon_painter.dart';
import '../scale_studio/scale_studio_screen.dart';
import '../wardrobe/wardrobe_screen.dart';

class CloudTownHubScreen extends StatelessWidget {
  const CloudTownHubScreen({super.key});

  static const List<String> dailyWishesVi = [
    'Bé Rồng Mây: "Hôm nay mình muốn dự tiệc dạ hội dưới ánh trăng rằm!"',
    'Bé Rồng Mây: "Mình ước có một bộ vảy ngọc bích lấp lánh như sương sớm!"',
    'Bé Rồng Mây: "Hôm nay mình rất thèm một chiếc bánh cookie mây giòn rụm!"',
    'Bé Rồng Mây: "Mình muốn được tắm bọt mây thơm ngát và xả nước mát lành!"',
    'Bé Rồng Mây: "Mình muốn thử đeo một chiếc nơ cổ màu đào thật xinh xắn!"',
    'Bé Rồng Mây: "Mình muốn rủ các bạn Thỏ Bông chụp một bức ảnh kỷ niệm!"',
    'Bé Rồng Mây: "Mình muốn đội một chiếc vương miện sao vàng lấp lánh!"',
  ];

  static const List<String> dailyWishesEn = [
    'Cloudy Baby: "Today I want to attend a moonlit cloud party!"',
    'Cloudy Baby: "I wish for shiny jade scales sparkling like morning dew!"',
    'Cloudy Baby: "Today I am craving a sweet crispy star cookie!"',
    'Cloudy Baby: "I want a warm fluffy bubble bath and rainbow rinse!"',
    'Cloudy Baby: "I want to try on a cute peach ribbon bow!"',
    'Cloudy Baby: "I want to snap a sweet memory photo with Bunny!"',
    'Cloudy Baby: "I want to wear a golden sparkling star crown!"',
  ];

  void _navigateTo(BuildContext context, Widget screen) {
    final gameState = context.read<GameState>();
    final audio = context.read<AudioService>();
    audio.playPop();

    if (gameState.canShowTransitionAd()) {
      debugPrint('Kids-safe ad cooldown check passed. Showing quiet interstitial.');
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppStrings>();
    final gameState = context.watch<GameState>();
    final audio = context.read<AudioService>();
    final character = gameState.activeDragon;

    final zones = [
      {
        'title': strings.zoneScaleTitle,
        'desc': strings.zoneScaleDesc,
        'icon': '🎨',
        'colors': [Color(0xFFE8F8F5), Color(0xFFD4EDDA)],
        'borderColor': AppColors.mintGreen,
        'screen': const ScaleStudioScreen(),
      },
      {
        'title': strings.zoneWardrobeTitle,
        'desc': strings.zoneWardrobeDesc,
        'icon': '👑',
        'colors': [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
        'borderColor': AppColors.lavenderPurple,
        'screen': const WardrobeScreen(),
      },
      {
        'title': strings.zoneBathTitle,
        'desc': strings.zoneBathDesc,
        'icon': '🛁',
        'colors': [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
        'borderColor': AppColors.skyBlue,
        'screen': const CloudBathScreen(),
      },
      {
        'title': strings.zoneBakeTitle,
        'desc': strings.zoneBakeDesc,
        'icon': '🧁',
        'colors': [Color(0xFFFFFDE7), Color(0xFFFFF9C4)],
        'borderColor': AppColors.butterYellow,
        'screen': const BakeNookScreen(),
      },
      {
        'title': strings.zonePetTitle,
        'desc': strings.zonePetDesc,
        'icon': '🐰',
        'colors': [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        'borderColor': AppColors.mintDark,
        'screen': const PetGardenScreen(),
      },
      {
        'title': strings.zonePhotoTitle,
        'desc': strings.zonePhotoDesc,
        'icon': '📸',
        'colors': [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
        'borderColor': AppColors.roseSoft,
        'screen': const PhotoBoothScreen(),
      },
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F2FE), // Xanh thiên thanh
              Color(0xFFEDE7F6), // Tím oải hương ấm
              Color(0xFFFEF3C7), // Vàng mật ong bừng sáng
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KidsAppBar(
                  title: strings.gameTitle,
                  subtitle: strings.gameSubtitle,
                  showHomeButton: false,
                  showSoundToggle: true,
                  showLangToggle: true,
                  showParentalGate: true,
                ),

                const SizedBox(height: 2),

                // Thanh 3 Chế Độ Chơi sắc màu rực rỡ
                Row(
                  children: [
                    Expanded(
                      child: _buildModeCard(
                        title: strings.modeFreeStudio,
                        badge: '${gameState.activeSlotIndex + 1}/12',
                        icon: Icons.auto_awesome_rounded,
                        colors: const [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
                        borderColor: AppColors.mintGreen,
                        onTap: () => _showSlotSelector(context, gameState, audio),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModeCard(
                        title: strings.modeDailyWish,
                        badge: gameState.dailyWishCompleted ? strings.completed : strings.fresh,
                        icon: Icons.favorite_rounded,
                        colors: const [Color(0xFFFEF08A), Color(0xFFFDE047)],
                        borderColor: AppColors.butterDark,
                        onTap: () => _showDailyWishDialog(context, strings, gameState, audio),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModeCard(
                        title: strings.modeStickerBook,
                        badge: '🏷️ ${gameState.collectedStickers.length}',
                        icon: Icons.collections_bookmark_rounded,
                        colors: const [Color(0xFFE9D5FF), Color(0xFFD8B4FE)],
                        borderColor: AppColors.lavenderDark,
                        onTap: () => _showStickerBook(context, gameState, audio),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Thẻ nhân vật Rồng Con hiện tại (Đảo mây thần tiên đầy màu sắc)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFF5E8FF)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.butterYellow, width: 3.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lavenderDark.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Vòng tròn Avatar rồng phát sáng
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.mintGreen, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mintGreen.withOpacity(0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: CustomPaint(
                                painter: DragonPainter(
                                  character: character,
                                  animationValue: 1.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        character.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textDark,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text('✨', style: TextStyle(fontSize: 17)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    strings.babyDragonCheer,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      KidButton(
                        label: strings.styleDragon,
                        backgroundColor: AppColors.mintGreen,
                        textColor: AppColors.textDark,
                        minHeight: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        onTap: () => _navigateTo(context, const ScaleStudioScreen()),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Lưới 6 Khu Vực sắc màu phong phú
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.18,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: zones.length,
                  itemBuilder: (context, index) {
                    final zone = zones[index];
                    final title = zone['title'] as String;
                    final desc = zone['desc'] as String;
                    final icon = zone['icon'] as String;
                    final colors = zone['colors'] as List<Color>;
                    final borderColor = zone['borderColor'] as Color;
                    final screen = zone['screen'] as Widget;

                    return GestureDetector(
                      onTap: () => _navigateTo(context, screen),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: colors,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: borderColor, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: borderColor.withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(icon, style: const TextStyle(fontSize: 22)),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_rounded, size: 16, color: borderColor),
                              ],
                            ),
                            const Spacer(),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 1),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                desc,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String badge,
    required IconData icon,
    required List<Color> colors,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textDark, size: 22),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  badge,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSlotSelector(BuildContext context, GameState gameState, AudioService audio) {
    final strings = context.read<AppStrings>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: AppColors.roomStudioBg,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.currentLanguage == AppLanguage.vi
                  ? 'Chọn Slot Nhân Vật Rồng (12 Slots)'
                  : 'Choose Dragon Slot (12 Slots)',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 180,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: GameState.maxSlots,
                itemBuilder: (context, index) {
                  final isSelected = gameState.activeSlotIndex == index;
                  final dragon = gameState.characters[index];
                  return GestureDetector(
                    onTap: () {
                      gameState.selectSlot(index);
                      audio.playPop();
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [AppColors.mintGreen, AppColors.mintLight]
                              : [Colors.white, const Color(0xFFF0F4F8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.mintDark : AppColors.cardBorder,
                          width: 2.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🐲', style: TextStyle(fontSize: 22)),
                          Text(
                            'Slot ${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          Text(
                            dragon.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyWishDialog(BuildContext context, AppStrings strings, GameState gameState, AudioService audio) {
    final wishes = strings.currentLanguage == AppLanguage.vi ? dailyWishesVi : dailyWishesEn;
    final todayWish = wishes[DateTime.now().day % wishes.length];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: AppColors.roomBakeBg,
        title: Row(
          children: [
            const Text('🎁 ', style: TextStyle(fontSize: 24)),
            Text(
              strings.currentLanguage == AppLanguage.vi ? 'Ước Mơ Hôm Nay' : 'Daily Wish',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.butterYellow, width: 2),
              ),
              child: Text(
                todayWish,
                style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              strings.currentLanguage == AppLanguage.vi
                  ? 'Bé hãy vào Xưởng Vảy, Tủ Đồ hoặc Bếp Bánh để trang trí theo ý thích nhé! Không có đúng hay sai đâu!'
                  : 'Visit Scale Studio, Wardrobe, or Bake Nook to style your baby dragon! There is no wrong way to create!',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          KidButton(
            label: strings.currentLanguage == AppLanguage.vi ? 'Mình Làm Liền! ✨' : "Let's Go! ✨",
            backgroundColor: AppColors.mintGreen,
            textColor: AppColors.textDark,
            minHeight: 46,
            onTap: () {
              gameState.completeDailyWish();
              audio.playCheer();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showStickerBook(BuildContext context, GameState gameState, AudioService audio) {
    final strings = context.read<AppStrings>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: AppColors.roomStudioBg,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.currentLanguage == AppLanguage.vi
                  ? 'Sổ Sticker Kỷ Niệm 📖'
                  : 'Sticker Collection Book 📖',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              strings.currentLanguage == AppLanguage.vi
                  ? 'Hoàn thành hoạt động sáng tạo để thu thập sticker, hoàn toàn miễn phí!'
                  : 'Complete creative salon activities to collect cute stickers for free!',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStickerBadge(
                  strings.currentLanguage == AppLanguage.vi ? '☁️ Mây Đầu Tiên' : '☁️ First Cloud',
                  gameState.collectedStickers.contains('sticker_welcome_cloud'),
                ),
                _buildStickerBadge(
                  strings.currentLanguage == AppLanguage.vi ? '🎨 Nghệ Sĩ Vảy' : '🎨 Scale Artist',
                  gameState.collectedStickers.contains('sticker_scale_artist'),
                ),
                _buildStickerBadge(
                  strings.currentLanguage == AppLanguage.vi ? '🧼 Rồng Sạch Mát' : '🧼 Fresh Dragon',
                  gameState.collectedStickers.contains('sticker_clean_dragon'),
                ),
                _buildStickerBadge(
                  strings.currentLanguage == AppLanguage.vi ? '🧁 Bếp Trưởng Sao' : '🧁 Star Baker',
                  gameState.collectedStickers.contains('sticker_baker_star'),
                ),
                _buildStickerBadge(
                  strings.currentLanguage == AppLanguage.vi ? '🐰 Yêu Động Vật' : '🐰 Pet Lover',
                  gameState.collectedStickers.contains('sticker_pet_care'),
                ),
                _buildStickerBadge(
                  strings.currentLanguage == AppLanguage.vi ? '📸 Nhiếp Ảnh Gia' : '📸 Photographer',
                  gameState.collectedStickers.contains('sticker_photographer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerBadge(String label, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.butterYellow : AppColors.cardBorder.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? AppColors.butterDark : AppColors.strokeSoft.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isUnlocked ? AppColors.textDark : AppColors.textMuted,
        ),
      ),
    );
  }
}
