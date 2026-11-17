import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_dragon_studio/core/audio/audio_service.dart';
import 'package:cloud_dragon_studio/core/localization/app_strings.dart';
import 'package:cloud_dragon_studio/core/theme/app_colors.dart';
import 'package:cloud_dragon_studio/models/game_state.dart';
import 'package:cloud_dragon_studio/models/wardrobe_item.dart';
import 'package:cloud_dragon_studio/screens/hub/cloud_town_hub_screen.dart';
import 'package:cloud_dragon_studio/screens/scale_studio/painters/dragon_painter.dart';
import 'package:cloud_dragon_studio/screens/scale_studio/scale_studio_screen.dart';
import 'package:cloud_dragon_studio/screens/wardrobe/wardrobe_screen.dart';
import 'package:cloud_dragon_studio/screens/cloud_bath/cloud_bath_screen.dart';
import 'package:cloud_dragon_studio/screens/bake_nook/bake_nook_screen.dart';
import 'package:cloud_dragon_studio/screens/pet_garden/pet_garden_screen.dart';
import 'package:cloud_dragon_studio/screens/photo_booth/photo_booth_screen.dart';

Future<void> loadFonts() async {
  final iconFile = File(r'C:\Users\HP\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf');
  if (iconFile.existsSync()) {
    final iconLoader = FontLoader('MaterialIcons');
    iconLoader.addFont(Future.value(ByteData.view(iconFile.readAsBytesSync().buffer)));
    await iconLoader.load();
  }

  final fontFile = File(r'C:\Windows\Fonts\segoeui.ttf');
  if (fontFile.existsSync()) {
    final fontLoader = FontLoader('Segoe UI');
    fontLoader.addFont(Future.value(ByteData.view(fontFile.readAsBytesSync().buffer)));
    await fontLoader.load();
  }

  final emojiFile = File(r'C:\Windows\Fonts\seguiemj.ttf');
  if (emojiFile.existsSync()) {
    final emojiLoader = FontLoader('Segoe UI Emoji');
    emojiLoader.addFont(Future.value(ByteData.view(emojiFile.readAsBytesSync().buffer)));
    await emojiLoader.load();
  }
}

Widget wrapWidget(Widget child, GlobalKey key, {GameState? gameState}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => gameState ?? GameState()),
      ChangeNotifierProvider(create: (_) => AppStrings()),
      ChangeNotifierProvider(create: (_) => AudioService()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        fontFamilyFallback: const ['Segoe UI Emoji'],
        scaffoldBackgroundColor: AppColors.cloudBackground,
      ),
      home: RepaintBoundary(
        key: key,
        child: child,
      ),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => '.',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (call) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockStreamHandler(
      const EventChannel('xyz.luan/audioplayers.global/events'),
      MockStreamHandler.inline(
        onListen: (arguments, events) {},
        onCancel: (arguments) {},
      ),
    );
  });

  testWidgets('Capture screens', (WidgetTester tester) async {
    await loadFonts();

    tester.view.physicalSize = const Size(720, 1612);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final outDir = Directory(r'C:\Users\HP\.gemini\antigravity\brain\90700c88-e65c-4d11-bc39-bc037a56a29f');

    final screens = <String, Widget>{
      '01_hub.png': const CloudTownHubScreen(),
      '02_scale_studio.png': const ScaleStudioScreen(),
      '03_wardrobe.png': const WardrobeScreen(),
      '04_cloud_bath.png': const CloudBathScreen(),
      '05_bake_nook.png': const BakeNookScreen(),
      '06_pet_garden.png': const PetGardenScreen(),
      '07_photo_booth.png': const PhotoBoothScreen(),
    };

    for (final entry in screens.entries) {
      final key = GlobalKey();
      await tester.pumpWidget(wrapWidget(entry.value, key));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('${outDir.path}\\${entry.key}');
        file.writeAsBytesSync(byteData!.buffer.asUint8List());
      });
    }
  });

  testWidgets('Capture costume preview showcases', (WidgetTester tester) async {
    await loadFonts();

    tester.view.physicalSize = const Size(720, 720);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final outDir = Directory(r'C:\Users\HP\.gemini\antigravity\brain\90700c88-e65c-4d11-bc39-bc037a56a29f');

    final outfits = [
      {
        'file': 'costume_princess_dress.png',
        'items': {
          ItemCategory.robe.name: 'robe_pastel_dress',
          ItemCategory.hat.name: 'hat_cloud_beret',
          ItemCategory.glasses.name: 'glasses_heart',
          ItemCategory.scarf.name: 'scarf_cloud_boa',
          ItemCategory.wingsDeco.name: 'wings_sparkle',
        },
      },
      {
        'file': 'costume_royal_cape.png',
        'items': {
          ItemCategory.robe.name: 'robe_cloud_cape',
          ItemCategory.hat.name: 'hat_star_crown',
          ItemCategory.glasses.name: 'glasses_star',
          ItemCategory.scarf.name: 'scarf_ribbon',
          ItemCategory.wingsDeco.name: 'wings_halo',
        },
      },
      {
        'file': 'costume_dapper_vest.png',
        'items': {
          ItemCategory.robe.name: 'robe_starry_vest',
          ItemCategory.hat.name: 'hat_flower_wreath',
          ItemCategory.glasses.name: 'glasses_cloud_mask',
          ItemCategory.scarf.name: 'scarf_bell_choker',
          ItemCategory.wingsDeco.name: 'wings_feather',
        },
      },
      {
        'file': 'costume_moonlit_gown.png',
        'items': {
          ItemCategory.robe.name: 'robe_night_gown',
          ItemCategory.hat.name: 'hat_nightcap',
          ItemCategory.scarf.name: 'scarf_pearl_necklace',
          ItemCategory.wingsDeco.name: 'wings_halo',
        },
      },
    ];

    for (final outfit in outfits) {
      final state = GameState();
      final char = state.activeDragon;
      final items = outfit['items'] as Map<String, String>;
      items.forEach((k, v) {
        char.equippedItems[k] = v;
      });

      final key = GlobalKey();
      await tester.pumpWidget(
        wrapWidget(
          Container(
            color: const Color(0xFFFFF0F5),
            child: Center(
              child: SizedBox(
                width: 360,
                height: 360,
                child: CustomPaint(
                  painter: DragonPainter(character: char, animationValue: 1.0),
                ),
              ),
            ),
          ),
          key,
          gameState: state,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('${outDir.path}\\${outfit['file']}');
        file.writeAsBytesSync(byteData!.buffer.asUint8List());
      });
    }
  });
}
