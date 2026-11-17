import 'dart:math';
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

enum BathTool { soap, shower, dryer, brush }

class CloudBubble {
  Offset position;
  double radius;
  Color color;
  CloudBubble({required this.position, required this.radius, required this.color});
}

class CloudBathScreen extends StatefulWidget {
  const CloudBathScreen({super.key});

  @override
  State<CloudBathScreen> createState() => _CloudBathScreenState();
}

class _CloudBathScreenState extends State<CloudBathScreen> {
  BathTool _activeTool = BathTool.soap;
  final List<CloudBubble> _bubbles = [];
  final List<Offset> _sparkles = [];
  double _cleanProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppStrings>();
    final gameState = context.watch<GameState>();
    final audio = context.read<AudioService>();
    final character = gameState.activeDragon;

    final tools = [
      {'tool': BathTool.soap, 'label': strings.bathSponge, 'color': AppColors.butterYellow},
      {'tool': BathTool.shower, 'label': strings.bathShower, 'color': AppColors.mintGreen},
      {'tool': BathTool.dryer, 'label': strings.bathDryer, 'color': AppColors.skyBlue},
      {'tool': BathTool.brush, 'label': strings.bathBrush, 'color': AppColors.lavenderPurple},
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFBAE6FD), // Xanh biển ngọc trong vắt
              Color(0xFFE0F2FE), // Xanh sương sớm
              Color(0xFFD1FAE5), // Lục bạc hà mát lành
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              KidsAppBar(
                title: strings.zoneBathTitle,
                subtitle: strings.zoneBathDesc,
              ),

              // Thanh 4 Công cụ Spa
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: tools.map((t) {
                      final tool = t['tool'] as BathTool;
                      final label = t['label'] as String;
                      final color = t['color'] as Color;
                      final isSelected = _activeTool == tool;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: KidButton(
                          label: label,
                          backgroundColor: isSelected ? color : Colors.white.withValues(alpha: 0.9),
                          textColor: AppColors.textDark,
                          minHeight: 48,
                          onTap: () {
                            setState(() => _activeTool = tool);
                            audio.playPop();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Bồn tắm mây bọt nước sinh động (Không dùng nền trắng trơn)
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFE0F7FA), // Nước suối khoáng xanh ngọc
                            Color(0xFFFFF9C4), // Váng bọt bơ vàng
                            Color(0xFFB2EBF2), // Sóng nước bồng bềnh
                          ],
                        ),
                        borderRadius: BorderRadius.circular(38),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.skyDark.withValues(alpha: 0.25),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: AppColors.skyBlue, width: 4.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(34),
                        child: Stack(
                          children: [
                            // Chú vịt cao su vàng bơi trong bồn tắm
                            Positioned(
                              top: 25,
                              left: 20,
                              child: Text('🐥', style: TextStyle(fontSize: 34)),
                            ),
                            // Cầu vồng nhỏ
                            Positioned(
                              top: 20,
                              right: 25,
                              child: Text('🌈', style: TextStyle(fontSize: 32)),
                            ),
                            // Sóng nước bọt mây dưới đáy bồn
                            Positioned(
                              bottom: 15,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: const [
                                  Text('🫧', style: TextStyle(fontSize: 26)),
                                  Text('🌊', style: TextStyle(fontSize: 28)),
                                  Text('🫧', style: TextStyle(fontSize: 24)),
                                  Text('🌊', style: TextStyle(fontSize: 28)),
                                  Text('🫧', style: TextStyle(fontSize: 26)),
                                ],
                              ),
                            ),

                            // Nhân vật rồng con đang tắm
                            Positioned.fill(
                              child: CustomPaint(
                                painter: DragonPainter(
                                  character: character,
                                  animationValue: 1.0,
                                ),
                              ),
                            ),

                            // Các tia sáng lấp lánh khi sấy/chải lông
                            ..._sparkles.map((sp) => Positioned(
                                  left: sp.dx - 12,
                                  top: sp.dy - 12,
                                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.butterDark, size: 28),
                                )),

                            // Bong bóng bọt xà phòng bồng bềnh pastel
                            ..._bubbles.map((b) => Positioned(
                                  left: b.position.dx - b.radius,
                                  top: b.position.dy - b.radius,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _bubbles.remove(b));
                                      audio.playPop();
                                    },
                                    child: Container(
                                      width: b.radius * 2,
                                      height: b.radius * 2,
                                      decoration: BoxDecoration(
                                        color: b.color.withValues(alpha: 0.65),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.5),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.bubble_chart_rounded, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ),
                                )),

                            // Vùng tương tác kéo thả bằng ngón tay
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onPanUpdate: (details) {
                                  final pos = details.localPosition;
                                  final random = Random();

                                  if (_activeTool == BathTool.soap) {
                                    if (_bubbles.length < 40) {
                                      setState(() {
                                        _bubbles.add(CloudBubble(
                                          position: pos + Offset(random.nextDouble() * 20 - 10, random.nextDouble() * 20 - 10),
                                          radius: random.nextDouble() * 18 + 14,
                                          color: random.nextBool() ? AppColors.roseSoft : AppColors.butterYellow,
                                        ));
                                      });
                                      audio.playPop();
                                    }
                                  } else if (_activeTool == BathTool.shower) {
                                    setState(() {
                                      _bubbles.removeWhere((b) => (b.position - pos).distance < 60);
                                      _cleanProgress = min(1.0, _cleanProgress + 0.04);
                                    });
                                    audio.playPop();
                                  } else if (_activeTool == BathTool.dryer) {
                                    if (_sparkles.length < 15) {
                                      setState(() => _sparkles.add(pos));
                                      audio.playSparkle();
                                    }
                                  } else if (_activeTool == BathTool.brush) {
                                    setState(() => character.expression = DragonExpression.delighted);
                                    audio.playCheer();
                                    gameState.collectSticker('sticker_clean_dragon');
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Dải thông báo thân thiện
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getToolEmoji(_activeTool), style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          _getToolHint(_activeTool, strings),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 13),
                        ),
                      ),
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

  String _getToolEmoji(BathTool tool) {
    switch (tool) {
      case BathTool.soap:
        return '🧼';
      case BathTool.shower:
        return '🚿';
      case BathTool.dryer:
        return '💨';
      case BathTool.brush:
        return '🪮';
    }
  }

  String _getToolHint(BathTool tool, AppStrings strings) {
    switch (tool) {
      case BathTool.soap:
        return strings.hintSoap;
      case BathTool.shower:
        return strings.hintShower;
      case BathTool.dryer:
        return strings.hintDryer;
      case BathTool.brush:
        return strings.hintBrush;
    }
  }
}
