// vouchers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/constants/fonts.dart';
import '../widgets/background_theme.dart';

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key});

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  String selectedCategory = 'All';

  final List<String> categories = ['All', 'Food', 'Shopping', 'Entertainment', 'Travel'];

  final List<VoucherItem> vouchers = [
    VoucherItem(
      brand: 'McDonald\'s',
      discount: '20% OFF',
      description: 'Get 20% off on orders above Rs. 500',
      validTill: '31 Dec 2024',
      category: 'Food',
      points: 500,
      color: Colors.red,
    ),
    VoucherItem(
      brand: 'Daraz',
      discount: 'Rs. 200 OFF',
      description: 'Save Rs. 200 on orders above Rs. 1000',
      validTill: '15 Jan 2025',
      category: 'Shopping',
      points: 300,
      color: Colors.orange,
    ),
    VoucherItem(
      brand: 'Cinepax',
      discount: 'Buy 1 Get 1',
      description: 'Buy one ticket and get one free',
      validTill: '28 Dec 2024',
      category: 'Entertainment',
      points: 400,
      color: Colors.purple,
    ),
    VoucherItem(
      brand: 'KFC',
      discount: '15% OFF',
      description: 'Get 15% off on all menu items',
      validTill: '31 Dec 2024',
      category: 'Food',
      points: 450,
      color: Colors.red.shade700,
    ),
    VoucherItem(
      brand: 'Khaadi',
      discount: '25% OFF',
      description: 'Get 25% off on winter collection',
      validTill: '10 Jan 2025',
      category: 'Shopping',
      points: 600,
      color: Colors.teal,
    ),
  ];

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

  List<VoucherItem> get filteredVouchers {
    if (selectedCategory == 'All') return vouchers;
    return vouchers.where((v) => v.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vouchers',
          style: Font.montserratFont(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: MyTheme.secondaryColor),
      ),
      body: Stack(
        children: [
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          Column(
            children: [
              // Category Filter
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? MyTheme.secondaryColor
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? MyTheme.secondaryColor
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          category,
                          style: Font.montserratFont(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Vouchers List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredVouchers.length,
                  itemBuilder: (context, index) {
                    final voucher = filteredVouchers[index];
                    return _buildVoucherCard(voucher);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(VoucherItem voucher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with brand color
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: voucher.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: voucher.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.brand,
                        style: Font.montserratFont(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        voucher.discount,
                        style: Font.montserratFont(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: voucher.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: MyTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${voucher.points}',
                        style: Font.montserratFont(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.description,
                  style: Font.montserratFont(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Valid till ${voucher.validTill}',
                      style: Font.montserratFont(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showRedeemDialog(voucher);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Redeem Now',
                      style: Font.montserratFont(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  void _showRedeemDialog(VoucherItem voucher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Redeem Voucher',
          style: Font.montserratFont(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Do you want to redeem this ${voucher.brand} voucher for ${voucher.points} points?',
          style: Font.montserratFont(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: Font.montserratFont()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Voucher redeemed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyTheme.secondaryColor,
            ),
            child: Text('Redeem', style: Font.montserratFont(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class VoucherItem {
  final String brand;
  final String discount;
  final String description;
  final String validTill;
  final String category;
  final int points;
  final Color color;

  VoucherItem({
    required this.brand,
    required this.discount,
    required this.description,
    required this.validTill,
    required this.category,
    required this.points,
    required this.color,
  });
}