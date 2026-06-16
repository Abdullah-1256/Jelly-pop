import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/routes.dart';

/// Applies consistent Android back-key behavior to route screens.
class JellyPageScope extends StatelessWidget {
  final String fallbackRoute;
  final Widget child;

  const JellyPageScope({
    super.key,
    this.fallbackRoute = AppRoutes.mapRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        context.go(fallbackRoute);
      },
      child: child,
    );
  }
}
