import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/presentations/widgets/settings_widgets/data_and_permission_widgets/switch_setting.dart';
import '../../../../core/utils/setting_utils/data_and_permission_utils/app_colors_utils.dart';
import '../../../../core/utils/setting_utils/data_and_permission_utils/app_styles.dart';
import 'bullet_points.dart';
import 'feature_card.dart';


class PrivacySettingsTab extends StatelessWidget {
  final AppColors colors;

  const PrivacySettingsTab({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Preferences',
            style: AppStyles.sectionTitleStyle(context, color: Theme.of(context).secondaryHeaderColor,),
          ),
          const SizedBox(height: 8),
          Text(
            'Control how your information is used and shared within PayFusion.',
            style: AppStyles.bodyTextStyle(context),
          ),
          const SizedBox(height: 24),

          // Data collection settings
          FeatureCard(
            icon: Icons.analytics_outlined,
            iconColor: colors.primary,
            title: 'Data Collection',
            colors: colors,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchSetting(
                  title: 'Usage Analytics',
                  description: 'Allow collection of anonymized app usage data to improve our services',
                  initialValue: true,
                ),
                SwitchSetting(
                  title: 'Transaction Pattern Analysis',
                  description: 'Enable AI analysis of transactions to detect fraud and provide spending insights',
                  initialValue: true,
                ),
                SwitchSetting(
                  title: 'Location-based Services',
                  description: 'Use your location to provide relevant offers and services',
                  initialValue: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Marketing preferences
          FeatureCard(
            icon: Icons.campaign_outlined,
            iconColor: colors.warning,
            title: 'Marketing Preferences',
            colors: colors,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchSetting(
                  title: 'Personalized Offers',
                  description: 'Receive customized promotions based on your activity',
                  initialValue: false,
                ),
                SwitchSetting(
                  title: 'Email Marketing',
                  description: 'Receive newsletters and promotional emails',
                  initialValue: false,
                ),
                SwitchSetting(
                  title: 'Push Notifications',
                  description: 'Receive promotional push notifications',
                  initialValue: false,
                ),
                SwitchSetting(
                  title: 'Partner Offers',
                  description: 'Allow trusted partners to send you relevant offers',
                  initialValue: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Data sharing
          FeatureCard(
            icon: Icons.share_outlined,
            iconColor: colors.error,
            title: 'Data Sharing',
            colors: colors,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchSetting(
                  title: 'Third-party Data Sharing',
                  description: 'Allow sharing data with trusted third-party providers for service improvement',
                  initialValue: false,
                ),
                SwitchSetting(
                  title: 'Public Profile',
                  description: 'Make your profile visible to other PayFusion users',
                  initialValue: true,
                ),
                SwitchSetting(
                  title: 'Social Features',
                  description: 'Enable social features like activity feeds and friend suggestions',
                  initialValue: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Enhanced privacy features
          FeatureCard(
            icon: Icons.security_outlined,
            iconColor: colors.success,
            title: 'Enhanced Privacy',
            colors: colors,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchSetting(
                  title: 'Private Mode',
                  description: 'Hide transaction details on activity feeds',
                  initialValue: true,
                ),
                SwitchSetting(
                  title: 'Do Not Track',
                  description: 'Request websites not to track your browsing when using PayFusion web features',
                  initialValue: true,
                ),
                SwitchSetting(
                  title: 'Biometric Data Storage',
                  description: 'Store biometric templates locally instead of in the cloud',
                  initialValue: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Compliance information
          FeatureCard(
            icon: Icons.policy_outlined,
            iconColor: colors.primary,
            title: 'Privacy Compliance',
            colors: colors,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BulletPoint(
                  'PayFusion complies with major data protection regulations including GDPR, CCPA, and PIPEDA.',
                ),
                BulletPoint(
                  'We implement data minimization principles and only collect information necessary for services.',
                ),
                BulletPoint(
                  'Your data is encrypted both in transit and at rest using industry-standard protocols.',
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () {
                      //context.go('/legal/privacy-policy');
                    },
                    child: Text(
                      'View Detailed Privacy Policy',
                      style: AppStyles.bodyTextStyle(context).copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}