import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocalTaxGuidanceScreen extends StatelessWidget {
  const LocalTaxGuidanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Local Tax Guidance',
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
              'Pakistan Tax Regulations',
              'PayFusion complies with all tax and legal regulations set by the Federal Board of Revenue (FBR) and State Bank of Pakistan (SBP). This section provides guidance on tax obligations for Pakistani users.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Tax Identification',
              'For Pakistani users, you may need to provide:\n\n• National Tax Number (NTN) - for businesses\n• Computerized National Identity Card (CNIC)\n• Sales Tax Registration Number (STRN) - if applicable\n\nThese are required for compliance with FBR regulations and for transaction limits above PKR 50,000 per day.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Transaction Tax (Withholding Tax)',
              'In Pakistan, certain transactions may be subject to withholding tax:\n\n• Banking transactions may have 0.6% withholding tax for non-filers\n• Digital payment services may attract advance tax\n• Commercial transactions above certain thresholds require tax deduction\n\nPayFusion automatically calculates and deducts applicable taxes as per FBR guidelines.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Sales Tax on Services',
              'For business accounts using PayFusion for commercial purposes:\n\n• Provincial Sales Tax may apply (varies by province)\n• Sindh: 13% sales tax on services\n• Punjab: 16% sales tax on services\n• Federal: 13% sales tax on services\n\nTax rates are subject to change based on provincial and federal budgets.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Annual Income Tax Filing',
              'Users conducting significant financial activity should:\n\n• File annual income tax returns with FBR\n• Maintain records of all PayFusion transactions\n• Download yearly transaction reports from the app\n• Consult with a tax advisor for proper reporting\n\nPayFusion provides detailed transaction history to support your tax filing.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Anti-Money Laundering (AML) Compliance',
              'Pakistani regulations require:\n\n• Transaction monitoring for suspicious activities\n• Reporting of transactions above PKR 500,000\n• Enhanced due diligence for high-value transactions\n• Compliance with FATF (Financial Action Task Force) guidelines',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Foreign Exchange Regulations',
              'For international transactions:\n\n• SBP regulations apply to foreign currency transactions\n• Maximum limits based on account verification level\n• Documentation required for amounts exceeding specified thresholds\n• Exchange rates as per SBP daily rates',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Business Account Requirements',
              'If you operate a business using PayFusion:\n\n• Business registration certificate\n• National Tax Number (NTN)\n• Sales Tax Registration (if applicable)\n• Bank account in business name\n• Authorized signatory documentation',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Tax Documentation',
              'PayFusion provides the following tax documents:\n\n• Monthly transaction statements\n• Annual tax summary reports\n• Withholding tax certificates\n• Receipts for all transactions\n\nAll documents are available in the "View Receipts" section.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Provincial Variations',
              'Tax regulations may vary by province:\n\n• Sindh Revenue Board (SRB) - for Sindh\n• Punjab Revenue Authority (PRA) - for Punjab\n• Khyber Pakhtunkhwa Revenue Authority (KPRA) - for KP\n• Balochistan Revenue Authority (BRA) - for Balochistan\n\nPayFusion automatically applies the correct provincial tax based on your registered address.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Regulatory Updates',
              'Tax laws and regulations change frequently. PayFusion:\n\n• Monitors all regulatory updates from FBR and SBP\n• Automatically updates tax calculations\n• Notifies users of significant regulatory changes\n• Maintains compliance with latest requirements\n\nLast regulatory update: December 2025',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Get Professional Advice',
              'For specific tax situations:\n\n• Consult with a chartered accountant\n• Contact FBR helpline: 051-111-772-772\n• Visit FBR website: www.fbr.gov.pk\n• Seek legal counsel for complex matters\n\nPayFusion provides information but not tax or legal advice.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Contact Tax Support',
              'For questions about tax compliance:\n\nEmail: tax@payfusion.com\nPhone: +92-XXX-XXXXXXX\nAddress: PayFusion Tax Compliance, Peshawar, Pakistan',
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