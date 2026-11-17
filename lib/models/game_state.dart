import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dragon_character.dart';

class GameState extends ChangeNotifier {
  static const int maxSlots = 12;
  static const String _saveKey = 'cloud_dragon_save_v1';

  final List<DragonCharacter> _characters = [];
  final List<String> _savedPhotoPaths = [];
  int _activeSlotIndex = 0;
  bool _isPremiumUnlocked = false;
  final Set<String> _unlockedRewardItems = {};
  final Set<String> _collectedStickers = {
    'sticker_welcome_cloud',
    'sticker_first_brush',
  };

  DateTime _lastAdTime = DateTime.fromMillisecondsSinceEpoch(0);
  bool _dailyWishCompleted = false;

  GameState() {
    _initDefaultSlots();
    loadSaveGame();
  }

  void _initDefaultSlots() {
    _characters.clear();
    for (int i = 0; i < maxSlots; i++) {
      _characters.add(DragonCharacter.createDefault(i));
    }
  }

  // Active Dragon
  DragonCharacter get activeDragon => _characters[_activeSlotIndex];
  int get activeSlotIndex => _activeSlotIndex;
  List<DragonCharacter> get characters => _characters;
  List<String> get savedPhotoPaths => List.unmodifiable(_savedPhotoPaths);
  bool get isPremiumUnlocked => _isPremiumUnlocked;
  Set<String> get collectedStickers => _collectedStickers;
  bool get dailyWishCompleted => _dailyWishCompleted;

  void addSavedPhoto(String path) {
    _savedPhotoPaths.insert(0, path);
    notifyListeners();
    saveGame();
  }

  void deleteSavedPhoto(String path) {
    _savedPhotoPaths.remove(path);
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
    notifyListeners();
    saveGame();
  }

  void selectSlot(int index) {
    if (index >= 0 && index < _characters.length) {
      _activeSlotIndex = index;
      notifyListeners();
      saveGame();
    }
  }

  void notifyCharacterUpdated() {
    notifyListeners();
    saveGame();
  }

  void unlockRewardItem(String itemId) {
    _unlockedRewardItems.add(itemId);
    notifyListeners();
    saveGame();
  }

  void collectSticker(String stickerId) {
    _collectedStickers.add(stickerId);
    notifyListeners();
    saveGame();
  }

  void completeDailyWish() {
    _dailyWishCompleted = true;
    _collectedStickers.add('sticker_daily_wish_star');
    notifyListeners();
    saveGame();
  }

  void unlockPremium() {
    _isPremiumUnlocked = true;
    notifyListeners();
    saveGame();
  }

  // Kid-safe ad control: >= 3 mins cooldown, returns true if ad is allowed
  bool canShowTransitionAd() {
    if (_isPremiumUnlocked) return false;
    final now = DateTime.now();
    if (now.difference(_lastAdTime).inSeconds >= 180) {
      _lastAdTime = now;
      return true;
    }
    return false;
  }

  // Persistence
  Future<void> saveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'activeSlotIndex': _activeSlotIndex,
        'isPremiumUnlocked': _isPremiumUnlocked,
        'unlockedRewardItems': _unlockedRewardItems.toList(),
        'collectedStickers': _collectedStickers.toList(),
        'savedPhotoPaths': _savedPhotoPaths,
        'dailyWishCompleted': _dailyWishCompleted,
        'characters': _characters.map((c) => c.toJson()).toList(),
      };
      await prefs.setString(_saveKey, jsonEncode(data));
    } catch (e) {
      debugPrint('Save error: $e');
    }
  }

  Future<void> loadSaveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_saveKey);
      if (raw != null) {
        final Map<String, dynamic> data = jsonDecode(raw);
        _activeSlotIndex = data['activeSlotIndex'] as int? ?? 0;
        _isPremiumUnlocked = data['isPremiumUnlocked'] as bool? ?? false;
        _dailyWishCompleted = data['dailyWishCompleted'] as bool? ?? false;

        if (data['savedPhotoPaths'] != null) {
          _savedPhotoPaths.clear();
          for (final item in (data['savedPhotoPaths'] as List)) {
            final p = item.toString();
            if (File(p).existsSync()) {
              _savedPhotoPaths.add(p);
            }
          }
        }

        if (data['unlockedRewardItems'] != null) {
          _unlockedRewardItems.clear();
          for (final item in (data['unlockedRewardItems'] as List)) {
            _unlockedRewardItems.add(item.toString());
          }
        }

        if (data['collectedStickers'] != null) {
          _collectedStickers.clear();
          for (final item in (data['collectedStickers'] as List)) {
            _collectedStickers.add(item.toString());
          }
        }

        if (data['characters'] != null) {
          final list = (data['characters'] as List);
          for (int i = 0; i < list.length && i < maxSlots; i++) {
            _characters[i] = DragonCharacter.fromJson(list[i] as Map<String, dynamic>);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load save error: $e');
    }
  }
}

