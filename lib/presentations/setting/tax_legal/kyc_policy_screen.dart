import 'package:flutter/material.dart';

class AMLKYCPolicyScreen extends StatelessWidget {
  const AMLKYCPolicyScreen({Key? key}) : super(key: key);

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
          'AML & KYC Policy',
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
              'PayFusion is committed to maintaining the highest standards of Anti-Money Laundering (AML) and Know Your Customer (KYC) compliance. This policy outlines our procedures to prevent financial crimes and ensure a secure platform for all users.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Customer Identification',
              'We are required to verify the identity of all our customers. During the registration process, you must provide:\n\n• Full legal name\n• Date of birth\n• Residential address\n• Government-issued identification (e.g., passport, national ID card)\n• Proof of address (e.g., utility bill, bank statement)',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Transaction Monitoring',
              'PayFusion continuously monitors all transactions to detect suspicious activities. Our automated systems analyze:\n\n• Transaction amounts and frequency\n• Geographic locations\n• Unusual patterns or behavior\n• High-risk jurisdictions',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Reporting Obligations',
              'We are legally obligated to report suspicious transactions to relevant authorities. If we identify potentially illegal activities, we will:\n\n• Conduct internal investigations\n• File Suspicious Activity Reports (SARs)\n• Cooperate fully with law enforcement\n• Maintain confidentiality of investigations',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Enhanced Due Diligence',
              'For high-risk customers or transactions, we may require additional verification:\n\n• Source of funds documentation\n• Purpose of transaction details\n• Enhanced background checks\n• Ongoing monitoring',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Record Keeping',
              'We maintain comprehensive records of all customer information and transactions for a minimum of 5 years, in accordance with regulatory requirements.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Customer Responsibility',
              'You agree to:\n\n• Provide accurate and truthful information\n• Update your information promptly when changes occur\n• Not use our services for illegal purposes\n• Cooperate with verification requests',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Contact Us',
              'If you have questions about our AML/KYC policies, please contact our compliance team at compliance@payfusion.com',
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