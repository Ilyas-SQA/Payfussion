import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Acceptance of Terms',
              'By accessing and using PayFusion services, you accept and agree to be bound by these Terms of Service. If you do not agree with any part of these terms, you must not use our services.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Service Description',
              'PayFusion provides digital payment and financial services including:\n\n• Mobile wallet services\n• Money transfers\n• Bill payments\n• Merchant payment processing\n• Digital receipts and invoices',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'User Accounts',
              'To use our services, you must:\n\n• Be at least 18 years of age\n• Provide accurate registration information\n• Maintain the security of your account credentials\n• Notify us immediately of unauthorized access\n• Be responsible for all activities under your account',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Fees and Charges',
              'PayFusion may charge fees for certain services. All applicable fees will be:\n\n• Clearly displayed before transaction confirmation\n• Deducted automatically from your account balance\n• Subject to change with 30 days notice\n• Non-refundable unless otherwise stated',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Transaction Limits',
              'We may impose transaction limits based on:\n\n• Your account verification level\n• Transaction type and amount\n• Regulatory requirements\n• Risk assessment factors',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Prohibited Activities',
              'You may not use PayFusion services to:\n\n• Engage in illegal activities\n• Commit fraud or money laundering\n• Violate intellectual property rights\n• Harass or harm others\n• Circumvent security measures\n• Use services in restricted jurisdictions',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Account Suspension',
              'We reserve the right to suspend or terminate your account if:\n\n• You violate these terms\n• We suspect fraudulent activity\n• Required by law or regulation\n• You provide false information',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Liability Limitations',
              'PayFusion is not liable for:\n\n• Loss of profits or data\n• Service interruptions\n• Third-party actions\n• Force majeure events\n• Unauthorized account access due to user negligence',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Dispute Resolution',
              'Any disputes shall be resolved through:\n\n1. Good faith negotiations\n2. Mediation if negotiations fail\n3. Arbitration as final remedy\n\nYou agree to arbitration in Pakistan under applicable laws.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Changes to Terms',
              'We may modify these terms at any time. Continued use of services after changes constitutes acceptance of modified terms.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Contact Information',
              'For questions about these terms, contact:\n\nEmail: support@payfusion.com\nPhone: +92-XXX-XXXXXXX\nAddress: Peshawar, Pakistan',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context,String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}