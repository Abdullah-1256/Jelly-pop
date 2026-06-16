import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import 'asset_icon.dart';

/// Image-backed currency or lives pill used in game headers.
class ResourcePill extends StatelessWidget {
  final String asset;
  final String value;

  const ResourcePill({super.key, required this.asset, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.textLight, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AssetIconImage(asset: asset, size: 44),
          const SizedBox(width: AppSizes.smallGap),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
