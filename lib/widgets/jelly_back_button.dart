import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../routes/routes.dart';

/// Image-based back button that falls back to the map route.
class JellyBackButton extends StatelessWidget {
  final String fallbackRoute;

  const JellyBackButton({super.key, this.fallbackRoute = AppRoutes.mapRoute});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => goBack(context, fallbackRoute: fallbackRoute),
      child: SizedBox(
        width: 58,
        height: 58,
        child: Image.asset(AppAssets.back, fit: BoxFit.contain),
      ),
    );
  }

  /// Handles both visible back button and device back-key behavior.
  static void goBack(BuildContext context, {required String fallbackRoute}) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(fallbackRoute);
  }
}
