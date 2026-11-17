import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/audio/audio_service.dart';
import 'core/localization/app_strings.dart';
import 'core/theme/app_colors.dart';
import 'models/game_state.dart';
import 'screens/hub/cloud_town_hub_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CloudDragonApp());
}

class CloudDragonApp extends StatelessWidget {
  const CloudDragonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
        ChangeNotifierProvider(create: (_) => AppStrings()),
        ChangeNotifierProvider(create: (_) => AudioService()),
      ],
      child: Consumer<AppStrings>(
        builder: (context, strings, child) {
          return MaterialApp(
            title: strings.gameTitle,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.cloudBackground,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.mintGreen,
                primary: AppColors.mintDark,
                secondary: AppColors.lavenderDark,
                surface: AppColors.cloudWhite,
              ),
              fontFamily: null, // Sử dụng hệ thống font mặc định sắc nét
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              cardTheme: CardThemeData(
                color: AppColors.cloudWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            home: const CloudTownHubScreen(),
          );
        },
      ),
    );
  }
}
