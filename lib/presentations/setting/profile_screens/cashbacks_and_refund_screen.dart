import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/core/theme/theme.dart';

import '../../../core/constants/fonts.dart';
import '../../widgets/background_theme.dart';

class CashbackAndRefundsScreen extends StatefulWidget {
  const CashbackAndRefundsScreen({super.key});

  @override
  State<CashbackAndRefundsScreen> createState() => _CashbackAndRefundsScreenState();
}

class _CashbackAndRefundsScreenState extends State<CashbackAndRefundsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _backgroundAnimationController;


  // --- Style Constants (consistent with your app) ---
  static const Color _textColorWhite = Color(0xFFFFFFFF);
  static const Color _errorColor = Color(0xFFEB5757); // For error or dispute related items



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final sizer = ResponsiveSizer(context); // Example

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cashback & Refunds',
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).scaffoldBackgroundColor,
          labelColor: Theme.of(context).secondaryHeaderColor,
          indicatorSize: TabBarIndicatorSize.tab,
          padding: const EdgeInsets.all(10),
          indicator: BoxDecoration(
              color: MyTheme.primaryColor,
              borderRadius: BorderRadius.circular(10)
          ),
          dividerColor: Theme.of(context).scaffoldBackgroundColor,
          labelStyle: Font.montserratFont(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          tabs: <Widget>[
            const Tab(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text('Cashback Program'),
              ),
            ),
            const Tab(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text('Refunds & Disputes'),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Stack(
            children: <Widget>[
              AnimatedBackground(
                animationController: _backgroundAnimationController,
              ),
              _buildCashbackProgramTab(context),
            ],
          ),
          Stack(
            children: <Widget>[
              AnimatedBackground(
                animationController: _backgroundAnimationController,
              ),
              _buildRefundsAndDisputesTab(context),
            ],
          ),
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
        children: <Widget>[
          Text(
            'Earn Rewards with PayFusion Cashback',
            style: Font.montserratFont(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get rewarded for your everyday transactions! Our cashback program is designed to give back to our valued users. Here’s how it works:',
            style: Font.montserratFont(
              fontSize: 14,
              height: 1.5, // Good for readability
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            context,
            icon: Icons.card_giftcard_rounded,
            iconColor: MyTheme.primaryColor,
            title: 'How to Earn Cashback',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
              children: <Widget>[
                Text(
                  'All earned cashback is collected in your dedicated Cashback Wallet. You can use this balance for future transactions within PayFusion or transfer it to your main wallet (subject to terms).',
                  style: Font.montserratFont(
                    fontSize: 14,
                    height: 1.5, // Good for readability
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: Text('View Cashback Balance', style: Font.montserratFont(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _textColorWhite,
                  ),),
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
              children: <Widget>[
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
        children: <Widget>[
          Text(
            'Hassle-Free Refunds & Disputes',
            style: Font.montserratFont(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
           Text(
            'We aim to make your transactions secure and provide clear processes for refunds and addressing disputes.',
            style: Font.montserratFont(
              fontSize: 14,
              height: 1.5, // Good for readability
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            context,
            icon: Icons.published_with_changes_rounded,
            iconColor: MyTheme.primaryColor,
            title: '24-Hour Instant Refund Policy',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                    style: Font.montserratFont(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _textColorWhite,
                    ),),
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
                    ),
                  ),
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
              children: <Widget>[
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
              children: <Widget>[
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
              children: <Widget>[
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
                style: Font.montserratFont(
                  fontSize: 14,
                  height: 1.5, // Good for readability
                ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 28, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                  style: Font.montserratFont(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("•  ",
              style: Font.montserratFont(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)), // Custom bullet
          Expanded(child: Text(text, style: Font.montserratFont(
            fontSize: 14,
          ),)),
        ],
      ),
    );
  }
}
