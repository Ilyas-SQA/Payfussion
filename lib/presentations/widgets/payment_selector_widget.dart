import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/image_url.dart';
import '../../core/theme/theme.dart';

class PaymentCard {
  final String id;
  final String brand;
  final String last4;
  final String expMonth;
  final String expYear;
  final DateTime createDate;
  final String paymentMethodId;
  final String stripeCustomerId;

  PaymentCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.createDate,
    required this.paymentMethodId,
    required this.stripeCustomerId,
  });

  factory PaymentCard.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PaymentCard(
      id: doc.id,
      brand: data['brand'] ?? '',
      last4: data['last4'] ?? '',
      expMonth: data['exp_month'] ?? '',
      expYear: data['exp_year'] ?? '',
      createDate: (data['create_date'] as Timestamp).toDate(),
      paymentMethodId: data['payment_method_id'] ?? '',
      stripeCustomerId: data['stripe_customer_id'] ?? '',
    );
  }
}

class PaymentCardSelector extends StatefulWidget {
  final String userId;
  final Function(PaymentCard) onCardSelect;

  const PaymentCardSelector({
    super.key,
    required this.userId,
    required this.onCardSelect,
  });

  @override
  State<PaymentCardSelector> createState() => _PaymentCardSelectorState();
}

class _PaymentCardSelectorState extends State<PaymentCardSelector> {
  PaymentCard? selectedCard;
  bool isExpanded = false;

  /// Stream to get user's payment cards
  Stream<List<PaymentCard>> getPaymentCardsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('card')
        .orderBy('create_date', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => PaymentCard.fromFirestore(doc))
        .toList());
  }

  void _toggleDropdown() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void _selectCard(PaymentCard card) {
    setState(() {
      selectedCard = card;
      isExpanded = false;
    });
    widget.onCardSelect(card);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return StreamBuilder<List<PaymentCard>>(
      stream: getPaymentCardsStream(),
      builder: (BuildContext context, AsyncSnapshot<List<PaymentCard>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerCard(theme);
        }

        if (snapshot.hasError) {
          return _buildErrorCard(theme, snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCard(theme);
        }

        final List<PaymentCard> cards = snapshot.data!;

        // Set selected card to first card if not already selected
        if (selectedCard == null && cards.isNotEmpty) {
          selectedCard = cards.first;
        }

        return Column(
          children: <Widget>[
            _buildMainCard(theme, selectedCard!, cards),
            if (isExpanded) _buildCardsList(theme, cards),
          ],
        );
      },
    );
  }

  Widget _buildMainCard(ThemeData theme, PaymentCard card, List<PaymentCard> allCards) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        width: double.infinity,
        height: 55.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
          color: MyTheme.primaryColor,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectCard(card),
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: TImageUrl.getCardBrandLogo(card.brand),
                  ),
                  Text(
                    "**** **** **** ${card.last4}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24.sp,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: allCards.length > 1 ? _toggleDropdown : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardsList(ThemeData theme, List<PaymentCard> cards) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Container(
          margin: EdgeInsets.only(top: 5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: theme.colorScheme.surface,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: cards.map((PaymentCard card) {
              final bool isSelected = selectedCard?.id == card.id;
              return _buildCardItem(theme, card, isSelected);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem(ThemeData theme, PaymentCard card, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectCard(card),
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: <Widget>[
              TImageUrl.getCardBrandLogo(card.brand),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  "**** **** **** ${card.last4}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.blue : Colors.black,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              Text(
                "${card.expMonth}/${card.expYear}",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 8.w),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 16.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity,
          height: 55.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  height: 16.h,
                  width: 49.w,
                  color: Colors.white,
                ),
              ),
              Container(
                height: 14.h,
                width: 120.w,
                color: Colors.white,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  height: 24.h,
                  width: 24.w,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String error) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        width: double.infinity,
        height: 55.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.red.withOpacity(0.1),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "Failed to load cards",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        width: double.infinity,
        height: 55.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add_card,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "No cards found",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}