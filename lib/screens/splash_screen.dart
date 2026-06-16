import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_sizes.dart';
import '../routes/routes.dart';
import '../widgets/game_background.dart';

/// Splash screen that shows the loading state before the welcome screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: AppSizes.splashDelayMs), () {
      if (mounted) {
        context.go(AppRoutes.welcomeRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        asset: AppAssets.splash,
        child: const SizedBox.expand(),
      ),
    );
  }
}
