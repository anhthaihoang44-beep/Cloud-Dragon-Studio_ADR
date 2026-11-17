import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/audio/audio_service.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/widgets/kids_app_bar.dart';
import '../../models/game_state.dart';
import 'painters/pet_painter.dart';

enum CloudPetType { rabbit, fox, kitten }
enum PetActivity { petting, feeding, brushing, playing }

class PetGardenScreen extends StatefulWidget {
  const PetGardenScreen({super.key});

  @override
  State<PetGardenScreen> createState() => _PetGardenScreenState();
}

class _PetGardenScreenState extends State<PetGardenScreen> with SingleTickerProviderStateMixin {
  CloudPetType _selectedPet = CloudPetType.rabbit;
  PetActivity _currentActivity = PetActivity.petting;
  int _happinessPoints = 3;
  final List<Offset> _floatingHearts = [];
  double _petScale = 1.0;

  void _addHeart(Offset pos) {
    setState(() {
      _floatingHearts.add(pos);
      _happinessPoints = min(5, _happinessPoints + 1);
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _floatingHearts.remove(pos));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppStrings>();
    final gameState = context.watch<GameState>();
    final audio = context.read<AudioService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFBAE6FD), // Bầu trời xanh biếc
              Color(0xFFD1FAE5), // Đồng cỏ mùa xuân xanh tươi
              Color(0xFFFEF08A), // Ánh nắng vàng bừng sáng
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              KidsAppBar(
                title: strings.zonePetTitle,
                subtitle: strings.zonePetDesc,
              ),

              // Chọn thú cưng (Thỏ Bông, Cáo Mây, Mèo Kem)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPetTab(CloudPetType.rabbit, strings.petBunny, AppColors.mintGreen, audio),
                      const SizedBox(width: 8),
                      _buildPetTab(CloudPetType.fox, strings.petFox, AppColors.peachSoft, audio),
                      const SizedBox(width: 8),
                      _buildPetTab(CloudPetType.kitten, strings.petKitten, AppColors.butterYellow, audio),
                    ],
                  ),
                ),
              ),

              // Sân vườn hoa cỏ đầy sắc màu (Không dùng nền trắng trơn)
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
                            Color(0xFFE0F2FE), // Bầu trời thiên thanh
                            Color(0xFFDCFCE7), // Đồi cỏ xanh mát
                            Color(0xFFBBF7D0), // Hoa cỏ mùa hạ
                          ],
                        ),
                        borderRadius: BorderRadius.circular(38),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mintDark.withValues(alpha: 0.25),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: AppColors.mintGreen, width: 4.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(34),
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            if (_currentActivity == PetActivity.petting) {
                              _addHeart(details.localPosition);
                              audio.playSparkle();
                            }
                          },
                          onTapDown: (details) {
                            setState(() => _petScale = 1.15);
                            _addHeart(details.localPosition);
                            audio.playPop();
                            Future.delayed(const Duration(milliseconds: 150), () {
                              if (mounted) setState(() => _petScale = 1.0);
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ông mặt trời & cầu vồng rực rỡ góc trên
                              Positioned(
                                top: 18,
                                right: 25,
                                child: Text('🌞', style: TextStyle(fontSize: 34)),
                              ),
                              Positioned(
                                top: 20,
                                left: 25,
                                child: Text('🌈', style: TextStyle(fontSize: 32)),
                              ),

                              // Thảm cỏ hoa & nấm đầy màu sắc dưới chân
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: const [
                                    Text('🌻', style: TextStyle(fontSize: 28)),
                                    Text('🍄', style: TextStyle(fontSize: 26)),
                                    Text('🌸', style: TextStyle(fontSize: 26)),
                                    Text('🌷', style: TextStyle(fontSize: 28)),
                                    Text('🍄', style: TextStyle(fontSize: 26)),
                                    Text('🌼', style: TextStyle(fontSize: 28)),
                                  ],
                                ),
                              ),

                              // Thú cưng đáng yêu
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedScale(
                                    duration: const Duration(milliseconds: 150),
                                    scale: _petScale,
                                    child: SizedBox(
                                      width: 140,
                                      height: 130,
                                      child: CustomPaint(
                                        painter: PetPainter(petType: _selectedPet),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Thanh 5 Trái Tim Hạnh Phúc đỏ rực
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      5,
                                      (i) => Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Icon(
                                          Icons.favorite_rounded,
                                          color: i < _happinessPoints ? const Color(0xFFFF4757) : Colors.white.withValues(alpha: 0.7),
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Trái tim bay bổng khi vuốt ve
                              ..._floatingHearts.map((pos) => Positioned(
                                    left: pos.dx - 14,
                                    top: pos.dy - 14,
                                    child: const Icon(Icons.favorite_rounded, color: Color(0xFFFF4757), size: 30),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4 Hành động chăm sóc
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8),
                      _buildActionBtn(PetActivity.petting, strings.actPetting, AppColors.roseSoft, audio),
                      const SizedBox(width: 8),
                      _buildActionBtn(PetActivity.feeding, strings.actFeeding, AppColors.butterYellow, audio, onTrigger: () {
                        gameState.collectSticker('sticker_pet_care');
                      }),
                      const SizedBox(width: 8),
                      _buildActionBtn(PetActivity.brushing, strings.actBrushing, AppColors.lavenderPurple, audio),
                      const SizedBox(width: 8),
                      _buildActionBtn(PetActivity.playing, strings.actPlaying, AppColors.mintGreen, audio),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(PetActivity act, String label, Color color, AudioService audio, {VoidCallback? onTrigger}) {
    final isSelected = _currentActivity == act;
    return KidButton(
      label: label,
      backgroundColor: isSelected ? color : Colors.white.withValues(alpha: 0.95),
      textColor: AppColors.textDark,
      minHeight: 46,
      minWidth: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      onTap: () {
        setState(() {
          _currentActivity = act;
          _happinessPoints = min(5, _happinessPoints + 1);
        });
        audio.playSparkle();
        onTrigger?.call();
      },
    );
  }

  Widget _buildPetTab(CloudPetType type, String title, Color tabColor, AudioService audio) {
    final isSelected = _selectedPet == type;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPet = type);
        audio.playPop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? tabColor : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.textDark : AppColors.cardBorder,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
