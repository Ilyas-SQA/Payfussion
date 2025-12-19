import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/presentations/setting/receipts_invoice_screen.dart';
import '../../core/constants/fonts.dart';
import '../../core/theme/theme.dart';
import '../widgets/background_theme.dart';
import 'annual_tax_screen.dart';


class TaxComplianceScreen extends StatefulWidget {
  const TaxComplianceScreen({super.key});

  @override
  State<TaxComplianceScreen> createState() => _TaxComplianceScreenState();
}

class _TaxComplianceScreenState extends State<TaxComplianceScreen> with TickerProviderStateMixin{

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tax & Legal Compliance',
        ),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildSectionTitle('Tax Reporting'),
                _buildTaxReportingCard(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  // Placeholder
                  title: 'Annual Tax Reports',
                  description:
                  'Generate and download annual tax reports for your business or freelance use.',
                  actionText: 'Generate Report',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnnualTaxReportScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10,),
                _buildTaxReportingCard(
                  context: context,
                  icon: Icons.picture_as_pdf_outlined,
                  // Placeholder
                  title: 'Receipts & Invoices',
                  description:
                      'Access downloadable receipts and invoices for all completed transactions.',
                  actionText: 'View Receipts',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReceiptsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Regulatory Information'),
                _buildInfoLinkCard(
                  context: context,
                  icon: Icons.policy_outlined,
                  // Placeholder
                  title: 'AML & KYC Policy',
                  description:
                      'Read about PayFusion’s Anti-Money Laundering and Know Your Customer policies to understand how we ensure a secure platform.',
                  actionText: 'View Policy',
                  onTap: () {
                    // TODO: Implement navigation to AML/KYC Policy details
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navigate to AML/KYC Policy')),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildInfoLinkCard(
                  context: context,
                  icon: Icons.gavel_outlined,
                  // Placeholder
                  title: 'Terms of Service',
                  description:
                      'Review the terms and conditions for using PayFusion services.',
                  actionText: 'Read Terms',
                  onTap: () {
                    // TODO: Implement navigation to Terms of Service
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navigate to Terms of Service')),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildInfoLinkCard(
                  context: context,
                  icon: Icons.shield_outlined,
                  // Placeholder
                  title: 'Privacy Policy',
                  description:
                      'Understand how we collect, use, and protect your personal information.',
                  actionText: 'View Policy',
                  onTap: () {
                    // TODO: Implement navigation to Privacy Policy
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navigate to Privacy Policy')),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Country-Specific Regulations'),
                _buildInfoLinkCard(
                  context: context,
                  icon: Icons.language_outlined,
                  // Placeholder
                  title: 'Local Tax Guidance',
                  description:
                      'Ensure compliance with local tax and legal regulations in your country. (e.g., [User\'s Country] if detected, or general prompt).',
                  actionText: 'Select Country / Learn More',
                  onTap: () {
                    // TODO: Implement country selection or navigation to guidance
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Navigate to Country Specific Info'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Secure Document Access'),
                const SizedBox(height: 10),
                _buildInfoLinkCard(
                  context: context,
                  icon: Icons.lock_person_outlined,
                  // Placeholder, more specific
                  title: 'Sensitive Document Protection',
                  description:
                      'Only you can access sensitive tax documents with biometric or PIN authentication. Manage your preferences in Security Settings.',
                  actionText: 'Manage Access Settings',
                  onTap: () {
                    // TODO: Navigate to relevant security settings page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Navigate to Security Settings for Document Access',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                _buildDisclaimer(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Font.montserratFont(
          fontSize: 14,
          fontWeight: FontWeight.w600, // Slightly bolder for section headers
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTaxReportingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 28,color: MyTheme.primaryColor,),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
            ],
          ),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Text(actionText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLinkCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 26,color: MyTheme.primaryColor,),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title),
                  const SizedBox(height: 4),
                  Text(description),
                  const SizedBox(height: 8),
                  Text(actionText), // Styled as a link
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18,color: MyTheme.primaryColor,),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).cardColor.withOpacity(0.3)),
      ),
      child: Text(
        'Disclaimer: PayFusion provides information and tools for your convenience. The content herein is for informational purposes only and does not constitute financial, tax, or legal advice. Please consult with a qualified professional for advice tailored to your specific situation.',
        textAlign: TextAlign.center,
        style: Font.montserratFont(
          fontSize: 14.sp,
          color: Colors.grey, // Lighter color for disclaimer
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
