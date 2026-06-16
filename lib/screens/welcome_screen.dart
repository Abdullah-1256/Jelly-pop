import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../routes/routes.dart';
import '../widgets/asset_icon.dart';
import '../widgets/glass_play_button.dart';

/// Welcome entry screen shown after splash before the map flow.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: AppSizes.welcomeBlurSigma,
                sigmaY: AppSizes.welcomeBlurSigma,
              ),
              child: Image.asset(AppAssets.background, fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(child: _buildBackgroundOverlay()),
          Center(
            child: Image.asset(
              AppAssets.logo,
              width: size.width * AppSizes.welcomeLogoWidthFactor,
              fit: BoxFit.contain,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.welcomeSettingsPadding),
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.settingsRoute),
                  child: const AssetIconImage(
                    asset: AppAssets.settings,
                    size: AppSizes.welcomeSettingsSize,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: size.height * AppSizes.welcomeButtonBottomFactor,
                ),
                child: GlassPlayButton(
                  label: AppStrings.play,
                  width: size.width * AppSizes.welcomeButtonWidthFactor,
                  onPressed: () => context.go(AppRoutes.mapRoute),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.backgroundBlackSoft,
            AppColors.backgroundColorWash,
            AppColors.backgroundBlackOverlay,
          ],
          stops: const <double>[0, 0.5, 1],
        ),
      ),
    );
  }
}
