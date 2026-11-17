import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// Quản lý âm thanh cho trẻ em:
/// - SFX vui nhộn (pop bong bóng, sparkle lấp lánh, tiếng quệt cọ, tiếng kèn chúc mừng)
/// - BGM nhẹ nhàng ru êm nhạc hộp (music box lullaby)
/// - Nút bật/tắt nhanh 1 chạm luôn hiển thị rõ ràng
class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    _initAudio();
  }

  AudioPlayer? _bgmPlayer;
  AudioPlayer? _sfxPlayer;
  bool get _isTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _isBgmPlaying = false;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;

  Future<void> _initAudio() async {
    if (_isTest) return;
    try {
      _bgmPlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.setVolume(0.4);
      startBgm();
    } catch (_) {}
  }

  void startBgm() {
    if (_isTest || !_isSoundEnabled || !_isMusicEnabled) return;
    try {
      _bgmPlayer ??= AudioPlayer();
      _bgmPlayer!.play(AssetSource('audio/bgm.wav'));
      _isBgmPlaying = true;
    } catch (_) {}
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    if (!_isSoundEnabled) {
      _bgmPlayer?.pause();
      _isBgmPlaying = false;
    } else if (_isMusicEnabled) {
      if (_isBgmPlaying) {
        _bgmPlayer?.resume();
      } else {
        startBgm();
      }
    }
    notifyListeners();
  }

  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    if (!_isMusicEnabled) {
      _bgmPlayer?.pause();
      _isBgmPlaying = false;
    } else if (_isSoundEnabled) {
      startBgm();
    }
    notifyListeners();
  }

  // SFX triggers
  void _playSfx(String path, double volume) {
    if (_isTest || !_isSoundEnabled) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      _sfxPlayer!.play(AssetSource(path), volume: volume);
    } catch (_) {}
  }

  void playBrushStroke() => _playSfx('audio/brush.wav', 0.6);
  void playPop() => _playSfx('audio/pop.wav', 0.85);
  void playSparkle() => _playSfx('audio/sparkle.wav', 0.7);
  void playCheer() => _playSfx('audio/cheer.wav', 0.75);

  @override
  void dispose() {
    _bgmPlayer?.dispose();
    _sfxPlayer?.dispose();
    super.dispose();
  }
}
