import 'package:flutter/material.dart';

import '../alera_colors.dart';
import '../alera_typography.dart';
import 'alera_card.dart';

class AleraSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final double contentSpacing;

  const AleraSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onActionPressed,
    this.contentSpacing = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return AleraCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AleraTypography.sectionTitle.copyWith(fontSize: 16),
                ),
              ),
              if (actionLabel != null)
                TextButton(
                  onPressed: onActionPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: AleraColors.primary,
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),
          SizedBox(height: contentSpacing),
          child,
        ],
      ),
    );
  }
}
