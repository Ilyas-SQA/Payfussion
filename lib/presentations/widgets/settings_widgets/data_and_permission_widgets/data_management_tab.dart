import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../../core/constants/fonts.dart';
import '../../../../core/constants/routes_name.dart';
import '../../../../core/utils/setting_utils/data_and_permission_utils/app_colors_utils.dart';
import '../../background_theme.dart';
import 'bullet_points.dart';
import 'feature_card.dart';

class DataManagementTab extends StatefulWidget {
  final AppColors colors;

  const DataManagementTab({super.key, required this.colors});

  @override
  State<DataManagementTab> createState() => _DataManagementTabState();
}

class _DataManagementTabState extends State<DataManagementTab> with TickerProviderStateMixin{

  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedBackground(
          animationController: _backgroundAnimationController,
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
               Text(
                'Your Data Control Center',
                style: Font.montserratFont(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your personal data and control how it\'s used within PayFusion.',
                style: Font.montserratFont(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),

              // Data access section
              FeatureCard(
                icon: Icons.description_outlined,
                iconColor: MyTheme.primaryColor,
                title: 'Access Your Data',
                colors: widget.colors,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const BulletPoint(
                      'View and download a comprehensive report of all your personal data stored with PayFusion.',
                    ),
                    const BulletPoint(
                      'Reports include transaction history, personal details, linked accounts, and usage patterns.',
                    ),
                    const BulletPoint(
                      'Data is provided in machine-readable formats (JSON, CSV) for portability.',
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Request Data Report'),
                      onPressed: () {
                        _showDataReportDialog(context, widget.colors);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Data deletion section
              FeatureCard(
                icon: Icons.delete_outline,
                iconColor: widget.colors.error,
                title: 'Data Deletion',
                colors: widget.colors,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const BulletPoint(
                      'Delete specific data categories or request complete account deletion.',
                    ),
                    const BulletPoint(
                      'Account deletion will remove all your personal data after legally mandated retention periods.',
                    ),
                    const BulletPoint(
                      'Note: Financial records may be retained for regulatory compliance even after deletion requests.',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            child: Text('Delete Specific Data', style: Font.montserratFont(fontSize: 12,)),
                            onPressed: () {
                              _showSelectionDialog(context, widget.colors);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: widget.colors.warning,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: ElevatedButton(
                            child: Text('Delete Account', style: Font.montserratFont(fontSize: 12,)),
                            onPressed: () {
                              _showAccountDeletionDialog(context, widget.colors);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: widget.colors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Other cards...
              const SizedBox(height: 16),

              FeatureCard(
                icon: Icons.edit_outlined,
                iconColor: MyTheme.primaryColor,
                title: 'Data Correction',
                colors: widget.colors,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const BulletPoint(
                      'Update or correct inaccurate personal information in our system.',
                    ),
                    const BulletPoint(
                      'Some changes may require identity verification for security purposes.',
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      child: Text('Update Personal Details', style: Font.montserratFont(color: Colors.white)),
                      onPressed: () {
                        context.go(RouteNames.profile);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              FeatureCard(
                icon: Icons.gavel_outlined,
                iconColor: MyTheme.primaryColor,
                title: 'Your Data Rights',
                colors: widget.colors,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const BulletPoint(
                      'Under data protection laws (GDPR, CCPA, etc.), you have specific rights regarding your personal data.',
                    ),
                    const BulletPoint(
                      'These include rights to access, correct, delete, restrict processing, and data portability.',
                    ),
                    const BulletPoint(
                      'For data concerns or complaints, contact our Data Protection Officer through our website.',
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        context.go('/legal/privacy-policy');
                      },
                      child: Text(
                        'Read Full Privacy Policy',
                        style: Font.montserratFont(
                          color: MyTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDataReportDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Text('Request Data Report', style: Font.montserratFont(color: colors.textPrimary)),
        content: Text(
          'Your data report will be prepared and sent to your registered email within 48 hours. This report contains all your personal data stored with PayFusion.',
          style: Font.montserratFont(color: colors.textPrimary),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: Font.montserratFont(color: colors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data report request submitted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: MyTheme.primaryColor),
            child: const Text('Confirm Request'),
          ),
        ],
      ),
    );
  }

  void _showSelectionDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Text('Select Data to Delete', style: Font.montserratFont(color: colors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildCheckboxListTile(context, 'Search History', 'Clears your in-app search records', true),
            _buildCheckboxListTile(context, 'Transaction Memos', 'Removes personal notes from transactions', false),
            _buildCheckboxListTile(context, 'Location History', 'Clears stored location data', false),
            _buildCheckboxListTile(context, 'Device Information', 'Removes linked device data', false),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: Font.montserratFont(color: colors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selected data deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.error),
            child: const Text('Delete Selected'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxListTile(BuildContext context, String title, String subtitle, bool value) {
    return StatefulBuilder(
        builder: (BuildContext context, setState) {
          bool isChecked = value;
          return CheckboxListTile(
            title: Text(title, style: Font.montserratFont(color: AppColors.of(context).textPrimary)),
            subtitle: Text(subtitle, style: Font.montserratFont(color: AppColors.of(context).textSecondary)),
            value: isChecked,
            onChanged: (bool? newValue) {
              setState(() {
                isChecked = newValue ?? false;
              });
            },
          );
        }
    );
  }

  void _showAccountDeletionDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Text('Delete Account', style: Font.montserratFont(color: colors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Warning: This action cannot be undone.',
              style: Font.montserratFont(color: colors.error, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Account deletion will:',
              style: Font.montserratFont(color: colors.textPrimary),
            ),
            const SizedBox(height: 5),
            Text('• Close your PayFusion account permanently', style: Font.montserratFont(color: colors.textPrimary)),
            Text('• Delete your personal profile information', style: Font.montserratFont(color: colors.textPrimary)),
            Text('• Remove your payment methods and settings', style: Font.montserratFont(color: colors.textPrimary)),
            Text('• Cancel all recurring payments', style: Font.montserratFont(color: colors.textPrimary)),
            const SizedBox(height: 10),
            Text('Note: Some information may be retained for legal and regulatory compliance.', style: Font.montserratFont(color: colors.textSecondary),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: Font.montserratFont(color: colors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              //: TODO add delete account function
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.error),
            child: const Text('Delete My Account'),
          ),
        ],
      ),
    );
  }
}
