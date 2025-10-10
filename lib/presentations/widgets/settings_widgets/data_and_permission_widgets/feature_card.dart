import 'package:flutter/material.dart';
import 'package:payfussion/core/utils/setting_utils/data_and_permission_utils/app_styles.dart';
import 'package:payfussion/core/utils/setting_utils/data_and_permission_utils/app_colors_utils.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget content;
  final AppColors colors;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2.0,
      color: colors.cardBackground,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: AppStyles.cardTitleStyle(context)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }
}
