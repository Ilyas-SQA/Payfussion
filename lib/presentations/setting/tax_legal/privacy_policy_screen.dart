import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Introduction',
              'PayFusion ("we", "our", "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Information We Collect',
              'Personal Information:\n• Name, email address, phone number\n• Date of birth and nationality\n• Government-issued ID documents\n• Residential address\n• Bank account details\n\nTransaction Information:\n• Payment history and amounts\n• Recipient details\n• Transaction timestamps and locations\n\nDevice Information:\n• Device type and operating system\n• IP address and location data\n• App usage statistics\n• Device identifiers',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'How We Use Your Information',
              'We use your information to:\n\n• Process transactions and payments\n• Verify your identity (KYC compliance)\n• Prevent fraud and enhance security\n• Provide customer support\n• Send transaction notifications\n• Improve our services\n• Comply with legal obligations\n• Conduct data analysis and research',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Information Sharing',
              'We may share your information with:\n\n• Financial institutions for transaction processing\n• Regulatory authorities when required by law\n• Service providers who assist our operations\n• Business partners with your consent\n• Law enforcement in case of suspected fraud\n\nWe do NOT sell your personal information to third parties.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Data Security',
              'We implement industry-standard security measures:\n\n• End-to-end encryption\n• Secure server infrastructure\n• Regular security audits\n• Access controls and authentication\n• Employee confidentiality agreements\n• Secure data storage and backups',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Data Retention',
              'We retain your information for:\n\n• Active accounts: Duration of account + 5 years\n• Transaction records: 5 years minimum\n• KYC documents: As required by regulations\n• Marketing data: Until you opt-out\n\nYou may request deletion of your data subject to legal requirements.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Your Privacy Rights',
              'You have the right to:\n\n• Access your personal information\n• Correct inaccurate data\n• Request data deletion\n• Object to data processing\n• Data portability\n• Withdraw consent\n• Lodge complaints with authorities',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Cookies and Tracking',
              'We use cookies and similar technologies to:\n\n• Remember your preferences\n• Analyze app performance\n• Provide personalized experience\n• Enhance security\n\nYou can manage cookie preferences in app settings.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Children\'s Privacy',
              'PayFusion services are not intended for users under 18 years of age. We do not knowingly collect information from children.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'International Data Transfers',
              'Your information may be transferred to and processed in countries outside Pakistan. We ensure adequate protection through standard contractual clauses.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Policy Updates',
              'We may update this Privacy Policy periodically. We will notify you of significant changes via email or app notification. Last updated: December 2025',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Contact Us',
              'For privacy concerns or requests:\n\nEmail: privacy@payfusion.com\nPhone: +92-XXX-XXXXXXX\nAddress: PayFusion Privacy Office, Peshawar, Pakistan',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF334155).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF475569).withOpacity(0.5)),
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
