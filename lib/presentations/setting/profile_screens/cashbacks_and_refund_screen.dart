import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';

class CashbackAndRefundsScreen extends StatefulWidget {
  const CashbackAndRefundsScreen({super.key});

  @override
  State<CashbackAndRefundsScreen> createState() =>
      _CashbackAndRefundsScreenState();
}

class _CashbackAndRefundsScreenState extends State<CashbackAndRefundsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Style Constants (consistent with your app) ---
  static const Color _primaryColor = Color(0xFF2D9CDB);
  static const Color _textColorWhite = Color(0xFFFFFFFF);
  static const Color _warningColor = Color(0xFFF2C94C); // For specific warnings or info
  static const Color _errorColor = Color(0xFFEB5757); // For error or dispute related items

  static const String _fontFamilyHeading = 'Montserrat';
  static const String _fontFamilyBody = 'Roboto';

  TextStyle get _screenTitleStyle => const TextStyle(
        fontFamily: _fontFamilyHeading,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      );

  TextStyle get _tabLabelStyle => const TextStyle(
        fontFamily: _fontFamilyHeading,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      );

  TextStyle get _sectionTitleStyle => const TextStyle(
        fontFamily: _fontFamilyHeading,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      );

  TextStyle get _cardTitleStyle => const TextStyle(
        fontFamily: _fontFamilyBody, // Or Montserrat Bold
        fontWeight: FontWeight.bold,
        fontSize: 16,
      );

  TextStyle get _bodyTextStyle => const TextStyle(
        fontFamily: _fontFamilyBody,
        fontSize: 14,
        height: 1.5, // Good for readability
      );

  TextStyle get _listItemTextStyle => const TextStyle(
        fontFamily: _fontFamilyBody,
        fontSize: 14,
      );

  TextStyle get _buttonTextStyle => const TextStyle(
        fontFamily: _fontFamilyBody,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: _textColorWhite,
      );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final sizer = ResponsiveSizer(context); // Example

    return Scaffold(
      appBar: AppBar(
        title: Text('Cashback & Refunds', style: _screenTitleStyle),
        elevation: 1,
        // Subtle elevation for appbar with tabs
        iconTheme: IconThemeData(color: Theme.of(context).secondaryHeaderColor),
        bottom: TabBar(
          labelColor: _primaryColor,
          controller: _tabController,
          indicatorColor: _primaryColor,
          labelStyle: TextStyle(
            fontFamily: _fontFamilyHeading,
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
          unselectedLabelStyle: _tabLabelStyle,
          tabs: const [
            Tab(text: 'Cashback Program'),
            Tab(text: 'Refunds & Disputes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCashbackProgramTab(context),
          _buildRefundsAndDisputesTab(context),
        ],
      ),
    );
  }

  // --- Cashback Program Tab ---
  Widget _buildCashbackProgramTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earn Rewards with PayFusion Cashback',
            style: _sectionTitleStyle.copyWith(color: MyTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Get rewarded for your everyday transactions! Our cashback program is designed to give back to our valued users. Here’s how it works:',
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            context,
            icon: Icons.card_giftcard_rounded,
            iconColor: MyTheme.primaryColor,
            title: 'How to Earn Cashback',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                    'Earn up to 5% cashback on eligible transactions like bill payments, merchant checkouts, and specific promotions.'),
                _buildBulletPoint(
                    'Cashback rates and eligible categories are dynamic and announced periodically via in-app notifications, emails, and on our "Offers" page.'),
                _buildBulletPoint(
                    'Look for the "Cashback Eligible" badge or offers when making payments.'),
                _buildBulletPoint(
                    'Cashback is typically credited to your PayFusion Cashback Wallet within 24-48 hours of a successful and eligible transaction.'),
                _buildBulletPoint(
                    'Terms and conditions, including spending limits and expiration dates for certain offers, may apply. Please check offer details.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.account_balance_wallet_rounded,
            iconColor: MyTheme.primaryColor,
            title: 'Your Cashback Wallet',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'All earned cashback is collected in your dedicated Cashback Wallet. You can use this balance for future transactions within PayFusion or transfer it to your main wallet (subject to terms).',
                    style: _bodyTextStyle),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: Text('View Cashback Balance', style: _buttonTextStyle),
                  onPressed: () {
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.info_outline_rounded,
            iconColor: MyTheme.primaryColor,
            title: 'Important Notes',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                    'Cashback offers are subject to change and may have specific eligibility criteria.'),
                _buildBulletPoint(
                    'PayFusion reserves the right to modify or terminate the cashback program at any time with prior notice.'),
                _buildBulletPoint(
                    'Fraudulent activities related to cashback earning may lead to account suspension and forfeiture of rewards.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Refunds & Disputes Tab ---
  Widget _buildRefundsAndDisputesTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hassle-Free Refunds & Disputes',
            style: _sectionTitleStyle.copyWith(color: _primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            'We aim to make your transactions secure and provide clear processes for refunds and addressing disputes.',
            style: _bodyTextStyle,
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            context,
            icon: Icons.published_with_changes_rounded,
            iconColor: MyTheme.primaryColor,
            title: '24-Hour Instant Refund Policy',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                    'Sent money to the wrong person or made an accidental payment? You can request an instant refund for eligible P2P (peer-to-peer) transactions within 24 hours of the transaction time.'),
                _buildBulletPoint(
                  'Eligibility: Applies to direct PayFusion balance transfers between individual users. Excludes merchant payments, bill payments, and transactions involving external accounts/cards unless explicitly stated.',
                ),
                _buildBulletPoint(
                    'How to request: Go to the transaction details in your history and look for the "Request Refund" option. Funds are typically returned to your balance instantly upon successful validation.'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.history_rounded, size: 18,color: MyTheme.primaryColor),
                  label: Text('Go to Transaction History',
                      style: _buttonTextStyle),
                  onPressed: () {
                    // TODO: Navigate to Transaction History screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Navigate to Transaction History',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.gavel_rounded,
            iconColor: _errorColor,
            title: 'Disputing Other Transactions',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                    'For issues with merchant payments, services not rendered, or unauthorized transactions not covered by the 24-hour refund, you can file a dispute.'),
                _buildBulletPoint(
                    'Escrow Protection: For transactions using our Smart Escrow System, funds are held until both parties confirm fulfillment. Disputes in escrow follow a guided resolution process.'),
                _buildBulletPoint(
                    'How to file: Locate the transaction in your history and select "Report an Issue" or "File a Dispute." Provide all necessary details and evidence.'),
                _buildBulletPoint(
                    'Our support team will review your case and mediate between parties if needed. Resolution times may vary.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.security_rounded,
            iconColor: MyTheme.primaryColor,
            title: 'AI-Driven Chargeback Protection',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                    'PayFusion uses AI to monitor for suspicious activities and potentially fraudulent transactions.'),
                _buildBulletPoint(
                    'Our system may flag high-risk transactions or merchants, providing you with warnings.'),
                _buildBulletPoint(
                    'While we strive to protect you, ultimate responsibility for authorized transactions lies with the user. Always verify recipient details before sending funds.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.info_outline_rounded, // Placeholder
            iconColor: MyTheme.primaryColor,
            title: 'Important Notes on Refunds',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                    'Refund policies are subject to PayFusion\'s Terms of Service.'),
                _buildBulletPoint(
                    'For payments made via linked credit/debit cards, refund processing times may also depend on your bank\'s policies.'),
                _buildBulletPoint(
                    'Abuse of the refund system may lead to restrictions or account actions.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to full Terms of Service or Refund Policy Document
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Navigate to Full Refund Policy Document')));
              },
              child: Text(
                'Read Full Refund & Dispute Policy',
                style: _bodyTextStyle.copyWith(
                    color: _primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget content,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2.0,
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
                  child: Text(title, style: _cardTitleStyle),
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

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("•  ",
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)), // Custom bullet
          Expanded(child: Text(text, style: _listItemTextStyle)),
        ],
      ),
    );
  }
}
