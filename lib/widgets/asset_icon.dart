import 'package:flutter/material.dart';

/// Consistent large image renderer for game UI icons.
class AssetIconImage extends StatelessWidget {
  final String asset;
  final double size;

  const AssetIconImage({super.key, required this.asset, this.size = 54});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
