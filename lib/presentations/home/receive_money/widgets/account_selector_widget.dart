import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/constants/image_url.dart';
import '../../../../core/theme/theme.dart';
import '../../../../data/models/card/card_model.dart';
import '../../../../logic/blocs/add_card/card_bloc.dart';
import '../../../../logic/blocs/add_card/card_event.dart';
import '../../../../logic/blocs/add_card/card_state.dart';
import '../../../../services/payment_service.dart';
import '../../../payment_strings.dart';


class AccountSelectorWidget extends StatefulWidget {
  final Function(CardModel?)? onCardSelected;

  const AccountSelectorWidget({Key? key, this.onCardSelected}) : super(key: key);

  @override
  State<AccountSelectorWidget> createState() => _AccountSelectorWidgetState();
}

class _AccountSelectorWidgetState extends State<AccountSelectorWidget> {
  CardModel? selectedCard;

  @override
  void initState() {
    super.initState();
    // Load cards when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardBloc>().add(LoadCards());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          ReceiveMoneyPaymentStrings.selectAccount,
          style: Font.montserratFont(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        _buildCardsList(),
      ],
    );
  }

  Widget _buildCardsList() {
    return BlocConsumer<CardBloc, CardState>(
      listener: (BuildContext context, CardState state) {
        if (state is CardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (BuildContext context, CardState state) {
        if (state is CardLoading || state is AddCardInitial) {
          return _buildLoadingState();
        } else if (state is CardError) {
          return _buildErrorState(state.message);
        } else if (state is CardLoaded) {
          if (state.cards.isEmpty) {
            return _buildEmptyCardsState();
          }
          return _buildCardCards(state.cards);
        }
        return _buildEmptyCardsState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
        border: Border.all(color: MyTheme.primaryColor, width: 1.0),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
        border: Border.all(color: MyTheme.primaryColor, width: 1.0),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 48.r,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error Loading Cards',
            style: Font.montserratFont(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: Font.montserratFont(
                fontSize: 14.sp,
                color: AppColors.textSecondary
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.read<CardBloc>().add(LoadCards());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardCards(List<CardModel> cards) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: -2,
              ),
            ],
            border: Border.all(color: MyTheme.primaryColor, width: 1.0),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cards.length,
            separatorBuilder: (BuildContext context, int index) => Divider(
              color: Colors.grey[200],
              height: 1,
              indent: 16.w,
              endIndent: 16.w,
            ),
            itemBuilder: (BuildContext context, int index) {
              final CardModel card = cards[index];
              final bool isSelected = selectedCard?.id == card.id;

              return _buildCardItem(card, isSelected, index, cards.length);
            },
          ),
        ),

        SizedBox(height: 16.h),
        _buildAddCardButton(),
      ],
    );
  }

  Widget _buildCardItem(CardModel card, bool isSelected, int index, int totalCards) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedCard = card;
        });
        if (widget.onCardSelected != null) {
          widget.onCardSelected!(card);
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            _buildCardIcon(card),
            SizedBox(width: 16.w),
            _buildCardDetails(card),
            SizedBox(width: 16.w),
            _buildCardBadges(card, isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildCardIcon(CardModel card) {
    return TImageUrl.getCardBrandLogo(card.brand,);
  }

  Widget _buildCardDetails(CardModel card) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${card.brand.toUpperCase()} ${card.cardEnding}',
            style: Font.montserratFont(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Expires ${card.formattedExpiry}',
            style: Font.montserratFont(
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBadges(CardModel card, bool isSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (isSelected)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: MyTheme.primaryColor,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              'Selected',
              style: Font.montserratFont(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddCardButton() {
    return InkWell(
      onTap: () {
        PaymentService().saveCard(context);
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: -2,
            ),
          ],
          border: Border.all(color: MyTheme.primaryColor, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.add_circle_outline,
              color: MyTheme.primaryColor,
              size: 24.r,
            ),
            SizedBox(width: 12.w),
            Text(
              'Add New Card',
              style: Font.montserratFont(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: MyTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCardsState() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
        border: Border.all(color: MyTheme.primaryColor, width: 1.0),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.credit_card_outlined,
            size: 48.r,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Cards Available',
            style: Font.montserratFont(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You need to add a card before requesting payments',
            style: Font.montserratFont(
                fontSize: 14.sp,
                color: AppColors.textSecondary
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () {
              PaymentService().saveCard(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius? _getItemBorderRadius(int index, int totalCards) {
    if (index == 0 && index == totalCards - 1) {
      return BorderRadius.circular(12.r);
    } else if (index == 0) {
      return BorderRadius.vertical(top: Radius.circular(12.r));
    } else if (index == totalCards - 1) {
      return BorderRadius.vertical(bottom: Radius.circular(12.r));
    }
    return null;
  }
}