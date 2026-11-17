import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../core/audio/audio_service.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kid_button.dart';
import '../../core/widgets/kids_app_bar.dart';
import '../../models/dragon_character.dart';
import '../../models/game_state.dart';
import '../scale_studio/painters/dragon_painter.dart';

class PhotoBoothSticker {
  Offset position;
  String text;
  PhotoBoothSticker({required this.position, required this.text});
}

class PhotoBoothScreen extends StatefulWidget {
  const PhotoBoothScreen({super.key});

  @override
  State<PhotoBoothScreen> createState() => _PhotoBoothScreenState();
}

class _PhotoBoothScreenState extends State<PhotoBoothScreen> {
  final GlobalKey _previewBoundaryKey = GlobalKey();
  int _selectedBackdrop = 0;
  bool _showFlash = false;
  bool _isCapturing = false;
  final List<PhotoBoothSticker> _placedStickers = [];

  final List<Map<String, dynamic>> _backdrops = [
    {
      'titleVi': 'Bình Minh Mây',
      'titleEn': 'Cloud Sunrise',
      'colors': [Color(0xFFFF7E67), Color(0xFFFFD166), Color(0xFFFFEAA7)],
      'icon': '🌅',
    },
    {
      'titleVi': 'Bầu Trời Sao',
      'titleEn': 'Starry Night',
      'colors': [Color(0xFF1E272C), Color(0xFF34495E), Color(0xFF5F27CD)],
      'icon': '🌌',
    },
    {
      'titleVi': 'Vườn Hoa Mây',
      'titleEn': 'Flower Garden',
      'colors': [Color(0xFF1DD1A1), Color(0xFF48DBFB), Color(0xFFFF9FF3)],
      'icon': '🌸',
    },
    {
      'titleVi': 'Lâu Đài Kẹo',
      'titleEn': 'Candy Castle',
      'colors': [Color(0xFFFF6B81), Color(0xFFFFA502), Color(0xFFFFE66D)],
      'icon': '🏰',
    },
  ];

  Future<void> _takeSnapshot(AudioService audio, GameState gameState, AppStrings strings) async {
    if (_isCapturing) return;
    _isCapturing = true;

    try {
      // 1. Chụp ảnh từ khung hình RepaintBoundary
      final boundary = _previewBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.5);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();

          final appDir = await getApplicationDocumentsDirectory();
          final photosDir = Directory('${appDir.path}/photos');
          if (!photosDir.existsSync()) {
            photosDir.createSync(recursive: true);
          }

          final filePath = '${photosDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File(filePath);
          await file.writeAsBytes(pngBytes);

          // 2. Thêm vào Album GameState
          gameState.addSavedPhoto(filePath);
          gameState.collectSticker('sticker_photographer');
        }
      }

      // 3. Hiệu ứng Flash máy ảnh & Âm thanh
      audio.playSparkle();
      audio.playCheer();
      if (mounted) {
        setState(() => _showFlash = true);
      }

      await Future.delayed(const Duration(milliseconds: 240));
      if (mounted) {
        setState(() => _showFlash = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strings.currentLanguage == AppLanguage.vi
                        ? 'Đã lưu ảnh kỷ niệm vào Album! 📸✨'
                        : 'Saved photo to Photo Album! 📸✨',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.lavenderDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Snapshot error: $e');
    } finally {
      _isCapturing = false;
    }
  }

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
              Color(0xFFEDE7F6), // Tím oải hương sáng
              Color(0xFFE0F2FE), // Xanh sương sớm
              Color(0xFFFFF3E0), // Cam sữa dịu mát
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              KidsAppBar(
                title: strings.zonePhotoTitle,
                subtitle: strings.zonePhotoDesc,
                actions: [
                  KidButton(
                    icon: Icons.photo_library_rounded,
                    label: '${gameState.savedPhotoPaths.length}',
                    backgroundColor: AppColors.butterYellow,
                    textColor: AppColors.textDark,
                    minHeight: 46,
                    minWidth: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    onTap: () => _showAlbumDialog(context, gameState, audio, strings),
                  ),
                ],
              ),

              // Thanh chọn phông nền & Tư thế
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _backdrops.asMap().entries.map((e) {
                            final index = e.key;
                            final bd = e.value;
                            final isSelected = _selectedBackdrop == index;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _selectedBackdrop = index);
                                  audio.playPop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: bd['colors'] as List<Color>),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? AppColors.textDark : Colors.white,
                                      width: isSelected ? 3 : 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(bd['icon'] as String, style: const TextStyle(fontSize: 20)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    KidButton(
                      label: character.pose == DragonPose.sitting ? strings.poseSit : strings.poseWave,
                      backgroundColor: AppColors.lavenderPurple,
                      textColor: AppColors.textDark,
                      minHeight: 44,
                      minWidth: 80,
                      onTap: () {
                        setState(() {
                          character.pose = character.pose == DragonPose.sitting
                              ? DragonPose.waving
                              : DragonPose.sitting;
                        });
                        audio.playPop();
                      },
                    ),
                  ],
                ),
              ),

              // Khung hình Studio Ảnh sắc màu rực rỡ (RepaintBoundary chụp ảnh)
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Stack(
                      children: [
                        RepaintBoundary(
                          key: _previewBoundaryKey,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(38),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: _backdrops[_selectedBackdrop]['colors'] as List<Color>,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 22,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(color: Colors.white, width: 5.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Stack(
                                children: [
                                  // Nhân vật rồng con tạo dáng
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: DragonPainter(
                                        character: character,
                                        animationValue: 1.0,
                                      ),
                                    ),
                                  ),

                                  // Các sticker đã dán lên ảnh
                                  ..._placedStickers.map((st) => Positioned(
                                        left: st.position.dx - 40,
                                        top: st.position.dy - 16,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() => _placedStickers.remove(st));
                                            audio.playPop();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.95),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: AppColors.cardBorder, width: 2),
                                            ),
                                            child: Text(st.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          ),
                                        ),
                                      )),

                                  // Vùng chạm dán sticker
                                  Positioned.fill(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTapUp: (details) {
                                        final enStickers = ['✨ Sparkle', '💖 Love', '🧁 Sweet', '👑 Royal', '☁️ Cloud', '⭐ Star'];
                                        final viStickers = ['✨ Lấp lánh', '💖 Yêu thương', '🧁 Ngon tuyệt', '👑 Công chúa', '☁️ Mây bay', '⭐ Ngôi sao'];
                                        final list = strings.currentLanguage == AppLanguage.en ? enStickers : viStickers;
                                        final text = list[DateTime.now().millisecond % list.length];
                                        setState(() {
                                          _placedStickers.add(PhotoBoothSticker(position: details.localPosition, text: text));
                                        });
                                        audio.playSparkle();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Flash khi bấm chụp ảnh
                        if (_showFlash)
                          Positioned.fill(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(38),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Nút Chụp Ảnh & Xóa Sticker
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: KidButton(
                        icon: Icons.camera_alt_rounded,
                        label: strings.photoSnap,
                        backgroundColor: AppColors.butterYellow,
                        textColor: AppColors.textDark,
                        minHeight: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        onTap: () => _takeSnapshot(audio, gameState, strings),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: KidButton(
                        icon: Icons.cleaning_services_rounded,
                        label: strings.photoClearStickers,
                        backgroundColor: Colors.white.withValues(alpha: 0.95),
                        textColor: AppColors.textMuted,
                        minHeight: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        onTap: () {
                          setState(() => _placedStickers.clear());
                          audio.playPop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlbumDialog(BuildContext context, GameState gameState, AudioService audio, AppStrings strings) {
    audio.playSparkle();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      backgroundColor: AppColors.roomStudioBg,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final photos = gameState.savedPhotoPaths;
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thanh kéo handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.photo_library_rounded, color: AppColors.lavenderDark, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            strings.currentLanguage == AppLanguage.vi
                                ? 'Album Kỷ Niệm (${photos.length})'
                                : 'Photo Album (${photos.length})',
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 26),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (photos.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.cardBorder, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Text('📷✨', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 10),
                          Text(
                            strings.currentLanguage == AppLanguage.vi
                                ? 'Chưa có ảnh nào trong Album!\nBé hãy bấm nút "Chụp Ảnh" để lưu lại khoảnh khắc đáng yêu nhé!'
                                : 'No photos yet!\nTap "Snap Photo" to capture beautiful memories of your baby dragon!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, i) {
                          final photoPath = photos[i];
                          final file = File(photoPath);

                          return Container(
                            width: 175,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AppColors.butterYellow, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Ảnh thực tế đã chụp
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showFullScreenPhoto(context, photoPath, i, strings),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: file.existsSync()
                                          ? Image.file(
                                              file,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => const Center(
                                                child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
                                              ),
                                            )
                                          : const Center(
                                              child: Icon(Icons.image_not_supported_rounded, color: AppColors.textMuted),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Hàng thông tin & nút thao tác
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      strings.currentLanguage == AppLanguage.vi ? 'Ảnh #${photos.length - i}' : 'Photo #${photos.length - i}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                                    ),
                                    Row(
                                      children: [
                                        // Phóng to
                                        GestureDetector(
                                          onTap: () => _showFullScreenPhoto(context, photoPath, i, strings),
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: AppColors.mintGreen.withValues(alpha: 0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.fullscreen_rounded, size: 18, color: AppColors.textDark),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        // Xóa ảnh
                                        GestureDetector(
                                          onTap: () {
                                            gameState.deleteSavedPhoto(photoPath);
                                            audio.playPop();
                                            setSheetState(() {});
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFullScreenPhoto(BuildContext context, String photoPath, int index, AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.butterYellow, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(File(photoPath)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    strings.currentLanguage == AppLanguage.vi ? 'Kỷ Niệm Của Rồng Con 💖' : 'Cloud Dragon Memory 💖',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            KidButton(
              icon: Icons.check_rounded,
              label: strings.currentLanguage == AppLanguage.vi ? 'Đóng' : 'Close',
              backgroundColor: AppColors.mintGreen,
              textColor: AppColors.textDark,
              minHeight: 46,
              minWidth: 120,
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}
