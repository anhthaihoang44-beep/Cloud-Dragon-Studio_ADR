import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/audio/audio_service.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/widgets/kids_app_bar.dart';
import '../../models/dragon_character.dart';
import '../../models/game_state.dart';
import '../scale_studio/painters/dragon_painter.dart';

enum CookieShape { cloud, star, moon, heart, flower }

class BakeNookScreen extends StatefulWidget {
  const BakeNookScreen({super.key});

  @override
  State<BakeNookScreen> createState() => _BakeNookScreenState();
}

class _BakeNookScreenState extends State<BakeNookScreen> {
  CookieShape _selectedShape = CookieShape.cloud;
  Color _icingColor = AppColors.butterWarm;
  final List<Offset> _sprinkles = [];
  bool _isOvenBaking = false;
  bool _isBaked = false;
  int _bitesCount = 0;
  bool _isFeedingMode = false;

  final List<Color> _icingFlavors = [
    Color(0xFFFFDD59), // Vani bơ vàng
    Color(0xFFFF5E7E), // Dâu tây sữa
    Color(0xFF2ED573), // Bạc hà tươi
    Color(0xFFD980FA), // Việt quất mây
    Color(0xFFFF9F43), // Đào mật ong
  ];

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppStrings>();
    final gameState = context.watch<GameState>();
    final audio = context.read<AudioService>();
    final character = gameState.activeDragon;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFEF3C7), // Vàng mật ong ngọt ngào
              Color(0xFFFFEDD5), // Cam đào kem
              Color(0xFFFCE7F3), // Hồng dâu tây dịu
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              KidsAppBar(
                title: strings.zoneBakeTitle,
                subtitle: strings.zoneBakeDesc,
              ),

              // Thanh chuyển chế độ (Nướng bánh hoặc Cho rồng ăn)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: KidButton(
                        icon: Icons.cookie_rounded,
                        label: strings.bakeDecorate,
                        backgroundColor: !_isFeedingMode ? AppColors.butterYellow : Colors.white.withValues(alpha: 0.9),
                        textColor: AppColors.textDark,
                        onTap: () {
                          setState(() => _isFeedingMode = false);
                          audio.playPop();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: KidButton(
                        icon: Icons.sentiment_very_satisfied_rounded,
                        label: strings.bakeFeed,
                        backgroundColor: _isFeedingMode ? AppColors.mintGreen : Colors.white.withValues(alpha: 0.9),
                        textColor: AppColors.textDark,
                        onTap: () {
                          if (!_isBaked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(strings.bakeWarning),
                                backgroundColor: AppColors.lavenderDark,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _isFeedingMode = true;
                            _bitesCount = 0;
                            character.expression = DragonExpression.happy;
                          });
                          audio.playCheer();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              if (!_isFeedingMode) ...[
                // Chọn khuôn bánh (Mây, Sao, Trăng, Tim, Hoa)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildShapeButton(CookieShape.cloud, strings.shapeCloud, audio),
                        const SizedBox(width: 8),
                        _buildShapeButton(CookieShape.star, strings.shapeStar, audio),
                        const SizedBox(width: 8),
                        _buildShapeButton(CookieShape.moon, strings.shapeMoon, audio),
                        const SizedBox(width: 8),
                        _buildShapeButton(CookieShape.heart, strings.shapeHeart, audio),
                        const SizedBox(width: 8),
                        _buildShapeButton(CookieShape.flower, strings.shapeFlower, audio),
                      ],
                    ),
                  ),
                ),
              ],

              // Khung bếp bánh ấm cúng rực rỡ (Không dùng hộp trắng)
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFF7ED), // Kem sữa ấm
                            Color(0xFFFFEDD5), // Bột bánh mì nướng
                            Color(0xFFFED7AA), // Khay gỗ sồi ấm áp
                          ],
                        ),
                        borderRadius: BorderRadius.circular(38),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.peachDark.withValues(alpha: 0.25),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: AppColors.butterYellow, width: 4.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(34),
                        child: Stack(
                          children: [
                            // Kệ bếp với lọ mứt & gia vị ngọt
                            Positioned(
                              top: 14,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: const [
                                  Text('🍓', style: TextStyle(fontSize: 24)),
                                  Text('🍯', style: TextStyle(fontSize: 24)),
                                  Text('✨', style: TextStyle(fontSize: 20)),
                                  Text('🥛', style: TextStyle(fontSize: 24)),
                                  Text('🧁', style: TextStyle(fontSize: 24)),
                                ],
                              ),
                            ),

                            // Khăn trải bàn caro màu vàng bơ ấm dưới khay bánh
                            Positioned(
                              bottom: 15,
                              left: 30,
                              right: 30,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.butterWarm.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),

                            Positioned.fill(
                              child: _isFeedingMode
                                  ? _buildFeedingView(character, audio, gameState)
                                  : _buildBakingTrayView(audio, gameState, strings),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Thanh chọn vị kem & Nút nướng bánh
              if (!_isFeedingMode) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          strings.currentLanguage == AppLanguage.vi ? 'Kem phủ: ' : 'Icing: ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                        ),
                        ..._icingFlavors.map((c) => GestureDetector(
                              onTap: () {
                                setState(() => _icingColor = c);
                                audio.playSparkle();
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _icingColor == c ? AppColors.textDark : Colors.white,
                                    width: _icingColor == c ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 2)),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: KidButton(
                          icon: Icons.local_fire_department_rounded,
                          label: _isOvenBaking
                              ? (strings.currentLanguage == AppLanguage.vi ? 'Đang Nướng ♨️' : 'Baking ♨️')
                              : (_isBaked
                                  ? (strings.currentLanguage == AppLanguage.vi ? 'Đã Nướng Xong ✨' : 'Baked Fresh ✨')
                                  : strings.bakeButton),
                          backgroundColor: AppColors.mintGreen,
                          textColor: AppColors.textDark,
                          onTap: () {
                            if (_isOvenBaking) return;
                            setState(() => _isOvenBaking = true);
                            audio.playSparkle();
                            Future.delayed(const Duration(seconds: 1), () {
                              if (mounted) {
                                setState(() {
                                  _isOvenBaking = false;
                                  _isBaked = true;
                                });
                                audio.playCheer();
                                gameState.collectSticker('sticker_baker_star');
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: KidButton(
                          icon: Icons.refresh_rounded,
                          label: strings.reset,
                          backgroundColor: Colors.white.withValues(alpha: 0.95),
                          textColor: AppColors.textMuted,
                          onTap: () {
                            setState(() {
                              _sprinkles.clear();
                              _isBaked = false;
                              _bitesCount = 0;
                            });
                            audio.playPop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                  child: KidButton(
                    icon: Icons.cake_rounded,
                    label: _bitesCount >= 3
                        ? (strings.currentLanguage == AppLanguage.vi ? 'Bé Rồng No Nê! 💖' : 'Full Dragon! 💖 Bake More')
                        : (strings.currentLanguage == AppLanguage.vi ? 'Chạm Bánh Để Cho Rồng Cắn 🍓' : 'Tap Treat to Feed Bites 🍓'),
                    backgroundColor: AppColors.butterYellow,
                    textColor: AppColors.textDark,
                    onTap: () {
                      if (_bitesCount >= 3) {
                        setState(() {
                          _isFeedingMode = false;
                          _isBaked = false;
                          _sprinkles.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBakingTrayView(AudioService audio, GameState gameState, AppStrings strings) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _sprinkles.add(details.localPosition);
        });
        audio.playSparkle();
      },
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (_isOvenBaking)
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Center(
                  child: Text(
                    strings.currentLanguage == AppLanguage.vi
                        ? '♨️ Đang nướng thơm lừng... ♨️'
                        : '♨️ Baking sweet treats... ♨️',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            // Bánh quy trung tâm
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: _isBaked ? const Color(0xFFE5B27D) : _icingColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _getShapeIcon(_selectedShape),
                  size: 92,
                  color: _isBaked ? const Color(0xFF8D5B28) : Colors.white.withOpacity(0.92),
                ),
              ),
            ),

          // Kẹo đường & Topping rắc lên
          ..._sprinkles.map((p) => Positioned(
                left: p.dx - 8,
                top: p.dy - 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.roseDark,
                    shape: BoxShape.circle,
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingView(DragonCharacter character, AudioService audio, GameState gameState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 170,
          height: 170,
          child: CustomPaint(
            painter: DragonPainter(
              character: character,
              animationValue: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            if (_bitesCount < 3) {
              setState(() {
                _bitesCount++;
                character.expression = DragonExpression.eating;
              });
              audio.playCheer();
              Future.delayed(const Duration(milliseconds: 600), () {
                if (mounted) {
                  setState(() => character.expression = DragonExpression.delighted);
                }
              });
            }
          },
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: 1.0 - (_bitesCount * 0.25),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE5B27D),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.5),
              ),
              child: Text(_getShapeEmoji(_selectedShape), style: const TextStyle(fontSize: 48)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShapeButton(CookieShape shape, String label, AudioService audio) {
    final isSelected = _selectedShape == shape;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedShape = shape);
        audio.playPop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.butterYellow : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.textDark : AppColors.cardBorder,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  IconData _getShapeIcon(CookieShape shape) {
    switch (shape) {
      case CookieShape.cloud:
        return Icons.cloud_rounded;
      case CookieShape.star:
        return Icons.star_rounded;
      case CookieShape.moon:
        return Icons.nightlight_round;
      case CookieShape.heart:
        return Icons.favorite_rounded;
      case CookieShape.flower:
        return Icons.local_florist_rounded;
    }
  }

  String _getShapeEmoji(CookieShape shape) {
    switch (shape) {
      case CookieShape.cloud:
        return '☁️';
      case CookieShape.star:
        return '⭐';
      case CookieShape.moon:
        return '🌙';
      case CookieShape.heart:
        return '💖';
      case CookieShape.flower:
        return '🌸';
    }
  }
}
