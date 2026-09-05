import 'package:flutter/material.dart';

import '../alera_colors.dart';
import '../alera_spacing.dart';

class AleraCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AleraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AleraSpacing.medium),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(padding: padding, child: child);

    return Material(
      color: AleraColors.surface,
      elevation: 2,
      shadowColor: AleraColors.primary.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(AleraSpacing.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
