import 'package:flutter/material.dart';

import '../alera_colors.dart';

class AleraRefreshIndicator extends StatelessWidget {
  final RefreshCallback onRefresh;
  final Widget child;
  final Color backgroundColor;
  final Color? color;
  final double displacement;
  final double edgeOffset;

  const AleraRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.backgroundColor = Colors.white,
    this.color = AleraColors.primary,
    this.displacement = 40,
    this.edgeOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: backgroundColor,
      color: color,
      displacement: displacement,
      edgeOffset: edgeOffset,
      child: child,
    );
  }
}
