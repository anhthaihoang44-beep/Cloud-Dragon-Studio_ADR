import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/audio/audio_service.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/widgets/kids_app_bar.dart';
import '../../models/dragon_character.dart';
import '../../models/drawing_stroke.dart';
import '../../models/game_state.dart';
import 'widgets/brush_palette.dart';
import 'widgets/color_selector.dart';
import 'widgets/dragon_canvas.dart';
import 'widgets/part_selector.dart';

class ScaleStudioScreen extends StatefulWidget {
  const ScaleStudioScreen({super.key});

  @override
  State<ScaleStudioScreen> createState() => _ScaleStudioScreenState();
}

class _ScaleStudioScreenState extends State<ScaleStudioScreen> {
  DragonPart _selectedPart = DragonPart.belly;
  DrawingToolType _selectedTool = DrawingToolType.brush;
  Color _selectedColor = AppColors.roseSoft;
  final double _strokeWidth = 16.0;

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
              Color(0xFFEFE6FD), // Tím oải hương sáng
              Color(0xFFDCF8ED), // Lục bạc hà tươi mát
              Color(0xFFFFF9DE), // Vàng nắng ấm
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              KidsAppBar(
                title: strings.zoneScaleTitle,
                subtitle: strings.zoneScaleDesc,
                actions: [
                  KidButton(
                    icon: Icons.undo_rounded,
                    backgroundColor: AppColors.butterWarm,
                    textColor: AppColors.textDark,
                    minHeight: 48,
                    minWidth: 48,
                    padding: const EdgeInsets.all(10),
                    onTap: () {
                      final didUndo = character.undo(_selectedPart);
                      if (didUndo) {
                        audio.playPop();
                        setState(() {});
                        gameState.notifyCharacterUpdated();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  KidButton(
                    icon: Icons.refresh_rounded,
                    backgroundColor: AppColors.roseLight,
                    textColor: AppColors.textDark,
                    minHeight: 48,
                    minWidth: 48,
                    padding: const EdgeInsets.all(10),
                    onTap: () {
                      _showConfirmResetDialog(context, character, gameState, audio, strings);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Thanh chọn bộ phận vẽ
              PartSelector(
                selectedPart: _selectedPart,
                onPartSelected: (part) {
                  setState(() => _selectedPart = part);
                  audio.playPop();
                },
              ),

              const SizedBox(height: 8),

              // Khung vẽ chính: Bối cảnh Xưởng vẽ sắc màu rực rỡ (Không còn hộp trắng đơn điệu)
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
                            Color(0xFFE1F5FE), // Bầu trời xanh pastel
                            Color(0xFFFFFDE7), // Ánh nắng ấm áp
                            Color(0xFFF1F8E9), // Đồng cỏ mùa xuân
                          ],
                        ),
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lavenderDark.withValues(alpha: 0.25),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.butterYellow,
                          width: 4.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Stack(
                          children: [
                            // Dây cờ trang trí lễ hội màu sắc trên nóc xưởng vẽ
                            Positioned(
                              top: 10,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: const [
                                  Text('🚩', style: TextStyle(fontSize: 22)),
                                  Text('🎈', style: TextStyle(fontSize: 22)),
                                  Text('✨', style: TextStyle(fontSize: 20)),
                                  Text('🎀', style: TextStyle(fontSize: 22)),
                                  Text('⭐', style: TextStyle(fontSize: 20)),
                                  Text('🎈', style: TextStyle(fontSize: 22)),
                                  Text('🚩', style: TextStyle(fontSize: 22)),
                                ],
                              ),
                            ),

                            // Cầu vồng nhỏ xinh xắn góc trên
                            Positioned(
                              top: 35,
                              right: 25,
                              child: Text('🌈', style: TextStyle(fontSize: 34)),
                            ),

                            // Đám mây hồng bồng bềnh góc trái
                            Positioned(
                              top: 45,
                              left: 20,
                              child: Text('🌸', style: TextStyle(fontSize: 26)),
                            ),

                            // Thảm mây tròn dưới chân bé rồng
                            Positioned(
                              bottom: 22,
                              left: 40,
                              right: 40,
                              child: Container(
                                height: 35,
                                decoration: BoxDecoration(
                                  color: AppColors.butterYellow.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),

                            // Canvas vẽ với Masking
                            DragonCanvas(
                              character: character,
                              selectedPart: _selectedPart,
                              selectedTool: _selectedTool,
                              selectedColor: _selectedColor,
                              strokeWidth: _strokeWidth,
                              onStrokeCompleted: () {
                                gameState.notifyCharacterUpdated();
                                gameState.collectSticker('sticker_scale_artist');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bảng công cụ vẽ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: BrushPalette(
                  selectedTool: _selectedTool,
                  onToolSelected: (tool) {
                    setState(() => _selectedTool = tool);
                    audio.playPop();
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Bảng màu sắc rực rỡ phong phú
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: ColorSelector(
                  selectedColor: _selectedColor,
                  onColorChanged: (newColor) {
                    setState(() => _selectedColor = newColor);
                    audio.playSparkle();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmResetDialog(
    BuildContext context,
    DragonCharacter character,
    GameState gameState,
    AudioService audio,
    AppStrings strings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.roomStudioBg,
        title: Text(strings.reset, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          strings.currentLanguage == AppLanguage.vi
              ? 'Bé có muốn xóa hết nét vẽ trên ${_getPartName(strings, _selectedPart)} để vẽ lại từ đầu không?'
              : 'Do you want to clear all drawings on ${_getPartName(strings, _selectedPart)} and start over?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(strings.back, style: const TextStyle(color: AppColors.textMuted)),
          ),
          KidButton(
            label: strings.done,
            backgroundColor: AppColors.roseSoft,
            textColor: AppColors.textDark,
            minHeight: 44,
            onTap: () {
              character.clearPart(_selectedPart);
              gameState.notifyCharacterUpdated();
              audio.playPop();
              setState(() {});
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  String _getPartName(AppStrings strings, DragonPart part) {
    switch (part) {
      case DragonPart.horns:
        return strings.partHorns;
      case DragonPart.wings:
        return strings.partWings;
      case DragonPart.tail:
        return strings.partTail;
      case DragonPart.belly:
        return strings.partBelly;
      case DragonPart.body:
        return strings.partBody;
    }
  }
}
