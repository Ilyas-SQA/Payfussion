import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/theme.dart';
import '../../widgets/background_theme.dart';

class ApplyCardScreen extends StatefulWidget {
  const ApplyCardScreen({super.key});

  @override
  State<ApplyCardScreen> createState() => _ApplyCardScreenState();
}

class _ApplyCardScreenState extends State<ApplyCardScreen> with TickerProviderStateMixin {
  int currentView = -1;
  int? selectedAccountType;
  int? selectedCardOption;
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
    // TODO: implement dispose
    super.dispose();
    _backgroundAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: MyTheme.secondaryColor,
        ),
      ),
      body: _getCurrentView(),
    );
  }

  String _getAppBarTitle() {
    if (currentView == -1) return 'Choose Your Account';
    if (currentView == 4) return 'Choose Your Card';
    return _getAccountTitle();
  }

  Widget _getCurrentView() {
    if (currentView == -1) return _buildAccountSelectionView();
    if (currentView == 4) return _buildCardOptionsView();
    return _buildAccountDetailView();
  }

  String _getAccountTitle() {
    switch (currentView) {
      case 0: return 'Checking Account';
      case 1: return 'Savings Account';
      case 2: return 'Money Market Account';
      case 3: return 'Certificate of Deposit';
      default: return 'Account Details';
    }
  }

  Widget _buildAccountSelectionView() {
    return Stack(
      children: [
        AnimatedBackground(
          animationController: _backgroundAnimationController,
        ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Open Your Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Select the account type that fits your needs', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildAccountCard(
                title: 'Checking Account', subtitle: 'Everyday banking made easy',
                description: 'Perfect for daily transactions, bill payments, and direct deposits',
                features: ['Free debit card', 'Unlimited transactions', 'ATM access nationwide', 'No minimum balance'],
                icon: Icons.account_balance_wallet, color: MyTheme.primaryColor, monthlyFee: '\$0', index: 0,
              ),
              _buildAccountCard(
                title: 'Savings Account', subtitle: 'Grow your money',
                description: 'Earn interest while keeping your money safe and accessible',
                features: ['Competitive APY rate', 'FDIC insured up to \$250,000', 'Easy online transfers', 'Monthly statements'],
                icon: Icons.savings, color: MyTheme.secondaryColor, monthlyFee: '\$0', apy: '4.50%', index: 1,
              ),
              _buildAccountCard(
                title: 'Money Market Account', subtitle: 'Higher returns, more flexibility',
                description: 'Premium savings with check-writing privileges',
                features: ['Higher interest rates', 'Check writing available', 'Debit card included', 'Limited monthly transactions'],
                icon: Icons.trending_up, color: MyTheme.primaryColor, monthlyFee: '\$10', apy: '5.25%', minBalance: '\$2,500', index: 2,
              ),
              _buildAccountCard(
                title: 'Certificate of Deposit', subtitle: 'Lock in high rates',
                description: 'Fixed-term deposit with guaranteed returns',
                features: ['Fixed interest rate', 'Terms: 3, 6, 12, 24 months', 'FDIC insured', 'Early withdrawal penalty applies'],
                icon: Icons.lock_clock, color: MyTheme.secondaryColor, monthlyFee: '\$0', apy: '5.50%', minBalance: '\$1,000', index: 3,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard({
    required String title, required String subtitle, required String description, required List<String> features,
    required IconData icon, required Color color, required String monthlyFee, String? apy, String? minBalance, required int index,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => setState(() => currentView = index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                ],
              ),
              const SizedBox(height: 16),
              Text(description, style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip('Monthly Fee', monthlyFee, Colors.grey[700]!),
                  if (apy != null) ...[const SizedBox(width: 12), _buildInfoChip('APY', apy, color)],
                  if (minBalance != null) ...[const SizedBox(width: 12), _buildInfoChip('Min. Balance', minBalance, Colors.grey[700]!)],
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 16),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: color, size: 18),
                    const SizedBox(width: 12),
                    Expanded(child: Text(f, style: TextStyle(fontSize: 13))),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(1, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAccountDetailView() {
    final Map<String, dynamic> d = _getAccountData(currentView);
    return Stack(
      children: [
        AnimatedBackground(
          animationController: _backgroundAnimationController,
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: d['gradientColors']),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: d['gradientColors'][0].withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50, right: -50,
                      child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d['cardTitle'], style: const TextStyle( fontSize: 18, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(d['bankName'], style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                                ],
                              ),
                              Icon(d['icon'],size: 36),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Account Number', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, letterSpacing: 1)),
                              const SizedBox(height: 6),
                              const Text('•••• •••• •••• 4729', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 2)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Available Balance', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                                  const SizedBox(height: 4),
                                  const Text('\$0.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              if (currentView != 3)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                                  child: const Text('VISA', style: TextStyle(color: Color(0xFF1A1F71), fontSize: 14, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(5.r),
                  boxShadow: [
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
                    Text(d['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(d['description'], style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                    const SizedBox(height: 20),
                    ...d['features'].map<Widget>((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildFeatureRow(f['icon'], f['title'], f['subtitle'], d['gradientColors'][0]),
                    )),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: d['gradientColors'][0].withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildRateInfo('Monthly Fee', d['monthlyFee']),
                          if (d['apy'] != null) _buildRateInfo('APY', d['apy']),
                          if (d['minBalance'] != null) _buildRateInfo('Min Balance', d['minBalance']),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildOptionButton('Account Benefits & Rewards'),
              _buildOptionButton('Fee Schedule'),
              _buildOptionButton('Terms & Conditions'),
              _buildOptionButton('FDIC Insurance Information'),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      selectedAccountType = currentView;
                      currentView = 4;
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: d['gradientColors'][0],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 2,
                    ),
                    child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRateInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOptionButton(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(5.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardOptionsView() {
    return Stack(
      children: [
        AnimatedBackground(
          animationController: _backgroundAnimationController,
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Choose Your Card', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Select the card type and shipping option that works best for you', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [MyTheme.primaryColor.withOpacity(0.1), MyTheme.secondaryColor.withOpacity(0.1)]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MyTheme.primaryColor.withOpacity(0.3), width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.celebration, color: MyTheme.primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('First-Time User Promo!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Get your Standard Card free on your first order', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCardOptionCard(
                title: 'Standard Card',
                description: 'Perfect for everyday use with reliable service',
                features: ['Durable plastic design', 'Contactless payment', 'Standard shipping (5-7 days)', 'Full account access'],
                originalPrice: '\$7.99',
                currentPrice: 'FREE',
                isPromo: true,
                icon: Icons.credit_card,
                color: MyTheme.primaryColor,
                index: 0,
              ),
              _buildCardOptionCard(
                title: 'Premium Card',
                description: 'Stand out with a sleek metal design',
                features: ['Premium metal card', 'Laser-engraved details', 'Enhanced durability', 'Priority customer support'],
                originalPrice: null,
                currentPrice: '\$14.99',
                isPromo: false,
                icon: Icons.stars,
                color: MyTheme.secondaryColor,
                badge: 'POPULAR',
                index: 1,
              ),
              _buildCardOptionCard(
                title: 'Express Delivery',
                description: 'Get your card fast with expedited shipping',
                features: ['Standard card design', 'Express FedEx/UPS shipping', '2-day delivery guarantee', 'Tracking included'],
                originalPrice: null,
                currentPrice: '\$19.99',
                isPromo: false,
                icon: Icons.local_shipping,
                color: const Color(0xFFFF6B6B),
                index: 2,
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(5.r),
                  boxShadow: [
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
                    const Text('Additional Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildAdditionalOption(icon: Icons.palette, title: 'Custom Card Design', subtitle: 'Personalize with your own image', price: '+\$4.99'),
                    const SizedBox(height: 12),
                    _buildAdditionalOption(icon: Icons.phone_android, title: 'Virtual Card', subtitle: 'Instant access, use while you wait', price: 'FREE', isFree: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildInfoCard(icon: Icons.shield, title: 'Secure & Protected', description: 'All cards are FDIC insured and include fraud protection'),
                    const SizedBox(height: 12),
                    _buildInfoCard(icon: Icons.refresh, title: 'Easy Replacement', description: 'Lost or stolen? Order a replacement for just \$5.99-\$10.99'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (selectedCardOption != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showOrderConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 2,
                      ),
                      child: Text('Continue - ${_getCardPrice(selectedCardOption!)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardOptionCard({
    required String title, required String description, required List<String> features,
    String? originalPrice, required String currentPrice, required bool isPromo,
    required IconData icon, required Color color, String? badge, required int index,
  }) {
    final sel = selectedCardOption == index;
    return GestureDetector(
      onTap: () => setState(() => selectedCardOption = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: sel ? color : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: sel ? color.withOpacity(0.3) : Colors.black26, blurRadius: sel ? 8 : 5, offset: const Offset(1, 1))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            if (badge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (isPromo && originalPrice != null)
                          Row(
                            children: [
                              Text(originalPrice, style: TextStyle(fontSize: 12, color: Colors.grey[500], decoration: TextDecoration.lineThrough)),
                              const SizedBox(width: 8),
                              Text(currentPrice, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
                            ],
                          )
                        else
                          Text(currentPrice, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Icon(sel ? Icons.check_circle : Icons.radio_button_unchecked, color: sel ? color : Colors.grey[400], size: 28),
                ],
              ),
              const SizedBox(height: 16),
              Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 16),
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 16),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check, color: color, size: 18),
                    const SizedBox(width: 12),
                    Expanded(child: Text(f, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalOption({required IconData icon, required String title, required String subtitle, required String price, bool isFree = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Icon(icon, color: MyTheme.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
        Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isFree ? Colors.green : Colors.grey[700])),
      ],
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: MyTheme.secondaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 12,)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCardPrice(int i) => i == 0 ? 'FREE' : i == 1 ? '\$14.99' : '\$19.99';

  String _getCardOptionName(int i) => i == 0 ? 'Standard Card' : i == 1 ? 'Premium Metal Card' : 'Express Delivery';

  void _showOrderConfirmation() {
    final d = _getAccountData(selectedAccountType ?? 0);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: Icon(Icons.check_circle, color: MyTheme.primaryColor, size: 48),
            ),
            const SizedBox(height: 20),
            const Text('Coming Soon!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Account opening and card ordering will be available soon. Stay tuned!', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Account Type:', style: TextStyle(fontSize: 10,)),
                      Text(d['title'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Card Option:', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      Text(_getCardOptionName(selectedCardOption ?? 0), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(_getCardPrice(selectedCardOption ?? 0), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: MyTheme.primaryColor)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: Text('Got it', style: TextStyle(color: MyTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getAccountData(int type) {
    switch (type) {
      case 0:
        return {
          'title': 'Checking Account',
          'cardTitle': 'Everyday Checking',
          'bankName': 'YourBank USA',
          'description': 'Perfect for your daily banking needs with unlimited transactions and easy access to your money.',
          'icon': Icons.account_balance_wallet,
          'gradientColors': [MyTheme.primaryColor, MyTheme.primaryColor.withOpacity(0.7)],
          'monthlyFee': '\$0',
          'apy': null,
          'minBalance': null,
          'features': [
            {'icon': Icons.credit_card, 'title': 'Free Debit Card', 'subtitle': 'Visa debit card with contactless payment'},
            {'icon': Icons.swap_horiz, 'title': 'Unlimited Transactions', 'subtitle': 'No limits on deposits, withdrawals, or transfers'},
            {'icon': Icons.atm, 'title': 'ATM Access', 'subtitle': 'Use 60,000+ fee-free ATMs nationwide'},
            {'icon': Icons.phone_android, 'title': 'Mobile Banking', 'subtitle': 'Manage your account on the go'},
          ],
        };
      case 1:
        return {
          'title': 'Savings Account',
          'cardTitle': 'High-Yield Savings',
          'bankName': 'YourBank USA',
          'description': 'Grow your savings with competitive interest rates while keeping your money secure and accessible.',
          'icon': Icons.savings,
          'gradientColors': [MyTheme.secondaryColor, MyTheme.secondaryColor.withOpacity(0.7)],
          'monthlyFee': '\$0',
          'apy': '4.50%',
          'minBalance': null,
          'features': [
            {'icon': Icons.trending_up, 'title': 'Competitive APY', 'subtitle': 'Earn 4.50% annual percentage yield'},
            {'icon': Icons.security, 'title': 'FDIC Insured', 'subtitle': 'Protected up to \$250,000 per depositor'},
            {'icon': Icons.sync, 'title': 'Easy Transfers', 'subtitle': 'Link to your checking account seamlessly'},
            {'icon': Icons.description, 'title': 'Monthly Statements', 'subtitle': 'Track your savings growth over time'},
          ],
        };
      case 2:
        return {
          'title': 'Money Market Account',
          'cardTitle': 'Premium Money Market',
          'bankName': 'YourBank USA',
          'description': 'Enjoy higher interest rates with the flexibility of check-writing and debit card access.',
          'icon': Icons.trending_up,
          'gradientColors': [MyTheme.primaryColor, MyTheme.primaryColor.withOpacity(0.7)],
          'monthlyFee': '\$10',
          'apy': '5.25%',
          'minBalance': '\$2,500',
          'features': [
            {'icon': Icons.attach_money, 'title': 'Higher Interest Rate', 'subtitle': 'Earn up to 5.25% APY on your balance'},
            {'icon': Icons.check, 'title': 'Check Writing', 'subtitle': 'Write checks directly from your account'},
            {'icon': Icons.credit_card, 'title': 'Debit Card Included', 'subtitle': 'Access your funds with ease'},
            {'icon': Icons.account_balance, 'title': 'FDIC Protected', 'subtitle': 'Your deposits are fully insured'},
          ],
        };
      case 3:
        return {
          'title': 'Certificate of Deposit',
          'cardTitle': 'Fixed-Term CD',
          'bankName': 'YourBank USA',
          'description': 'Lock in a guaranteed rate for a fixed term and watch your savings grow risk-free.',
          'icon': Icons.lock_clock,
          'gradientColors': [MyTheme.secondaryColor, MyTheme.secondaryColor.withOpacity(0.7)],
          'monthlyFee': '\$0',
          'apy': '5.50%',
          'minBalance': '\$1,000',
          'features': [
            {'icon': Icons.lock, 'title': 'Fixed Interest Rate', 'subtitle': 'Guaranteed 5.50% APY for the entire term'},
            {'icon': Icons.calendar_today, 'title': 'Flexible Terms', 'subtitle': 'Choose from 3, 6, 12, or 24 month terms'},
            {'icon': Icons.verified_user, 'title': 'FDIC Insured', 'subtitle': 'Protected up to \$250,000'},
            {'icon': Icons.autorenew, 'title': 'Auto-Renewal Option', 'subtitle': 'Automatically renew at maturity'},
          ],
        };
      default:
        return {};
    }
  }
}