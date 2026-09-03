import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AleraSvgIcon extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final String? semanticLabel;

  const AleraSvgIcon({
    super.key,
    required this.assetPath,
    required this.width,
    required this.height,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}
