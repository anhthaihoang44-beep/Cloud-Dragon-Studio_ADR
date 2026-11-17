import 'package:flutter/foundation.dart';

enum AppLanguage { en, vi }

class AppStrings extends ChangeNotifier {
  static final AppStrings _instance = AppStrings._internal();
  factory AppStrings() => _instance;
  AppStrings._internal();

  // Mặc định tiếng Anh theo yêu cầu người dùng
  AppLanguage _currentLanguage = AppLanguage.en;
  AppLanguage get currentLanguage => _currentLanguage;

  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    setLanguage(_currentLanguage == AppLanguage.en ? AppLanguage.vi : AppLanguage.en);
  }

  // --- Strings Dictionary ---
  String get gameTitle => 'Cloud Dragon Studio';
  String get gameSubtitle => _isVi ? 'Tiệm tạo mẫu rồng mây' : 'Cloud Dragon Styling Salon';

  // Navigation & General
  String get home => _isVi ? 'Trang chủ' : 'Home';
  String get back => _isVi ? 'Quay lại' : 'Back';
  String get undo => _isVi ? 'Hoàn tác' : 'Undo';
  String get reset => _isVi ? 'Làm lại' : 'Reset';
  String get save => _isVi ? 'Lưu' : 'Save';
  String get done => _isVi ? 'Xong' : 'Done';
  String get soundOn => _isVi ? 'Bật âm' : 'Sound On';
  String get soundOff => _isVi ? 'Tắt âm' : 'Sound Off';
  String get settings => _isVi ? 'Cài đặt' : 'Settings';
  String get parentalGate => _isVi ? 'Bố mẹ' : 'Parents';
  String get styleDragon => _isVi ? 'Tạo Mẫu Rồng Con ✨' : 'Style Baby Dragon ✨';
  String get completed => _isVi ? 'Xong ✨' : 'Done ✨';
  String get fresh => _isVi ? 'Mới 🎁' : 'New 🎁';
  String get babyDragonCheer => _isVi
      ? 'Bé rồng đang rất vui và sẵn sàng làm đẹp!'
      : 'Happy & ready for a magical makeover!';

  // Hub Zones
  String get zoneBathTitle => _isVi ? 'Tắm Mây' : 'Cloud Bath';
  String get zoneBathDesc => _isVi ? 'Tắm bọt & sấy mây' : 'Bubble Bath & Spa';

  String get zoneScaleTitle => _isVi ? 'Xưởng Vảy' : 'Scale Studio';
  String get zoneScaleDesc => _isVi ? 'Tô màu & vẽ hoa văn' : 'Paint & Patterns';

  String get zoneWardrobeTitle => _isVi ? 'Tủ Đồ Mây' : 'Wardrobe';
  String get zoneWardrobeDesc => _isVi ? 'Mũ nón & áo choàng' : 'Outfits & Crowns';

  String get zoneBakeTitle => _isVi ? 'Bếp Bánh' : 'Bake Nook';
  String get zoneBakeDesc => _isVi ? 'Nướng bánh & cho ăn' : 'Bake & Feed Treats';

  String get zonePetTitle => _isVi ? 'Vườn Bạn Nhỏ' : 'Pet Garden';
  String get zonePetDesc => _isVi ? 'Chăm sóc thú cưng' : 'Care for Cloud Pets';

  String get zonePhotoTitle => _isVi ? 'Studio Ảnh' : 'Photo Booth';
  String get zonePhotoDesc => _isVi ? 'Chụp ảnh & dán nhãn' : 'Snap & Photo Album';

  // Scale Studio Specific
  String get selectPart => _isVi ? 'Chọn bộ phận để tô' : 'Pick a part to color';
  String get partBody => _isVi ? 'Thân' : 'Body';
  String get partWings => _isVi ? 'Cánh' : 'Wings';
  String get partBelly => _isVi ? 'Bụng vảy' : 'Belly Scales';
  String get partHorns => _isVi ? 'Sừng rồng' : 'Horns';
  String get partTail => _isVi ? 'Đuôi mây' : 'Cloud Tail';

  String get toolBrush => _isVi ? 'Cọ' : 'Brush';
  String get toolGradient => _isVi ? 'Loang' : 'Gradient';
  String get toolStampStar => _isVi ? 'Sao' : 'Star';
  String get toolStampCloud => _isVi ? 'Mây' : 'Cloud';
  String get toolStampHeart => _isVi ? 'Tim' : 'Heart';
  String get toolEraser => _isVi ? 'Tẩy' : 'Eraser';

  String get colorPalette => _isVi ? 'Bảng màu pastel' : 'Pastel Palette';
  String get customHue => _isVi ? 'Pha màu riêng' : 'Custom Shade';

  // Daily Wish & Modes
  String get modeFreeStudio => _isVi ? 'Tự Do Sáng Tạo' : 'Free Studio';
  String get modeDailyWish => _isVi ? 'Ước Mơ Hôm Nay' : 'Daily Wish';
  String get modeStickerBook => _isVi ? 'Sổ Sticker' : 'Sticker Book';
  String get dailyWishMsg1 => _isVi
      ? 'Bé Rồng Mây: "Hôm nay mình muốn có bộ vảy lấp lánh như bầu trời sao đêm!"'
      : 'Cloud Baby: "Today I wish for sparkly scales like starry night skies!"';

  // Wardrobe categories
  String get catHats => _isVi ? '👑 Mũ & Miện' : '👑 Hats & Crowns';
  String get catRobes => _isVi ? '🧥 Áo Choàng' : '🧥 Robes';
  String get catScarves => _isVi ? '🎀 Nơ & Khăn' : '🎀 Scarves & Bows';
  String get catGlasses => _isVi ? '⭐ Kính Mắt' : '⭐ Glasses';
  String get catWings => _isVi ? '✨ Cánh Tiên' : '✨ Fairy Wings';

  // Cloud Bath tools & hints
  String get bathSponge => _isVi ? '1. Bông Bọt ☁️' : '1. Sponge ☁️';
  String get bathShower => _isVi ? '2. Vòi Sen 🚿' : '2. Shower 🚿';
  String get bathDryer => _isVi ? '3. Sấy Mây 💨' : '3. Dryer 💨';
  String get bathBrush => _isVi ? '4. Chải Lông 🪮' : '4. Brush 🪮';
  String get hintSoap => _isVi
      ? 'Kéo bông mây để chà bọt xà phòng khắp người rồng!'
      : 'Drag the cloud sponge to lather fluffy bubbles!';
  String get hintShower => _isVi
      ? 'Kéo vòi sen để xả sạch hết bong bóng!'
      : 'Drag the shower head to rinse away bubbles!';
  String get hintDryer => _isVi
      ? 'Kéo máy sấy mây ấm để sấy khô cánh & lông!'
      : 'Drag the warm dryer to fluff up wings & fur!';
  String get hintBrush => _isVi
      ? 'Chải lông nhẹ nhàng cho bé rồng tỏa sáng lung linh!'
      : 'Gently brush to make the baby dragon sparkle!';

  // Bake Nook
  String get bakeDecorate => _isVi ? 'Trang Trí Bánh 🧁' : 'Decorate 🧁';
  String get bakeFeed => _isVi ? 'Cho Rồng Ăn 🐲' : 'Feed Dragon 🐲';
  String get bakeWarning => _isVi
      ? 'Bé hãy nướng bánh xong trước khi cho rồng con ăn nhé!'
      : 'Please finish baking your treat first!';
  String get bakeButton => _isVi ? 'Nướng Bánh Lò Mây 🔥' : 'Bake in Oven 🔥';
  String get shapeCloud => _isVi ? '☁️ Mây' : '☁️ Cloud';
  String get shapeStar => _isVi ? '⭐ Sao' : '⭐ Star';
  String get shapeMoon => _isVi ? '🌙 Trăng' : '🌙 Moon';
  String get shapeHeart => _isVi ? '💖 Tim' : '💖 Heart';
  String get shapeFlower => _isVi ? '🌸 Hoa' : '🌸 Flower';

  // Pet Garden
  String get petBunny => _isVi ? '🐰 Thỏ Bông' : '🐰 Bunny';
  String get petFox => _isVi ? '🦊 Cáo Mây' : '🦊 Cloud Fox';
  String get petKitten => _isVi ? '🐱 Mèo Kem' : '🐱 Butter Cat';
  String get actPetting => _isVi ? 'Xoa Đầu 💖' : 'Pet 💖';
  String get actFeeding => _isVi ? 'Cho Ăn 🥕' : 'Feed 🥕';
  String get actBrushing => _isVi ? 'Chải Lông 🪮' : 'Brush 🪮';
  String get actPlaying => _isVi ? 'Chơi Bóng ⚽' : 'Play Ball ⚽';

  // Photo Booth
  String get photoSnap => _isVi ? 'Tách! Chụp Ảnh 📸' : 'Snap Photo! 📸';
  String get photoClearStickers => _isVi ? 'Bỏ Nhãn Dán 🧹' : 'Clear Stickers 🧹';
  String get photoAlbum => _isVi ? 'Album Ảnh' : 'Photo Album';
  String get photoSavedToast => _isVi
      ? '📸 Tách! Đã lưu ảnh đẹp vào Album của bé Rồng!'
      : '📸 Click! Photo saved to Baby Dragon\'s Album!';
  String get poseSit => _isVi ? '🪑 Ngồi' : '🪑 Sit';
  String get poseWave => _isVi ? '👋 Chào' : '👋 Wave';

  // Parental Gate & Safety
  String get parentalPrompt => _isVi
      ? 'Hỏi người lớn: Hãy giải phép tính bên dưới để tiếp tục:'
      : 'Grown-ups only: Please solve this math equation to continue:';
  String get holdToEnter => _isVi ? 'Giữ nút 3 giây để mở' : 'Hold for 3s to enter';
  String get privacyPolicy => _isVi ? 'Chính sách bảo vệ trẻ em' : 'Kids Privacy Policy';
  String get privacyNotice => _isVi
      ? 'Trò chơi Cloud Dragon Studio cam kết 100% tuân thủ chính sách gia đình của Apple & Google. Không thu thập thông tin định danh, không quảng cáo theo dõi hành vi.'
      : 'Cloud Dragon Studio is 100% compliant with Apple Kids Category & Google Play Families Policy. No personal data collected, no behavioral ads.';

  bool get _isVi => _currentLanguage == AppLanguage.vi;
}
