import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:payfussion/presentations/currency-exchange/calculator_history_view.dart';
import 'package:payfussion/presentations/currency-exchange/calculator_view.dart';
import 'package:payfussion/presentations/currency-exchange/currency_exchange_history_view.dart';
import 'package:payfussion/presentations/currency-exchange/currency_exchange_view.dart';
import 'package:payfussion/presentations/debug/auth_test_screen.dart';
import 'package:payfussion/presentations/home/paybill/dth_recharge/dth_recharge_screen.dart';
import 'package:payfussion/presentations/home/paybill/electricity_bill/electric_city_bill_screen.dart';
import 'package:payfussion/presentations/home/paybill/gas_bill/gas_bill_screen.dart';
import 'package:payfussion/presentations/home/paybill/internet_bill/internet_bill_screen.dart';
import 'package:payfussion/presentations/home/paybill/movies/moives_screen.dart';
import 'package:payfussion/presentations/home/paybill/postpaid_bill/postpaid_bill_screen.dart';
import 'package:payfussion/presentations/home/paybill/rent_payment/rent_payment_screen.dart';
import 'package:payfussion/presentations/pay_bills/pay_bill_details_view.dart';
import 'package:payfussion/presentations/pay_bills/receipt_view.dart';
import 'package:payfussion/presentations/setting/community_forum/community_forum_screen.dart';
import 'package:payfussion/presentations/setting/community_forum/create_forum_post.dart';
import 'package:payfussion/presentations/setting/data_and_permissions.dart';
import 'package:payfussion/presentations/setting/devices_management_screen.dart';
import 'package:payfussion/presentations/setting/faqs_screen.dart';
import 'package:payfussion/presentations/setting/profile_screens/cashbacks_and_refund_screen.dart';
import 'package:payfussion/presentations/setting/profile_screens/change_password.dart';
import 'package:payfussion/presentations/setting/submit_ticket/show_ticket_screen.dart';
import 'package:payfussion/presentations/setting/tax_and_legal_compliance.dart';

import '../../data/models/pay_bills/bill_item.dart';
import '../../logic/cubits/route_cubit/route_cubit.dart';
import '../../presentations/add_card/add_card_homescreen.dart';
import '../../presentations/auth/forget_password/forget_password_screen.dart';
import '../../presentations/auth/sign_in/sign_in.dart';
import '../../presentations/auth/sign_up/sign_up_screen.dart';
import '../../presentations/home/paybill/bill_split/bill_split_screen.dart';
import '../../presentations/home/paybill/credit_card_loan/credit_card_loan_screen.dart';
import '../../presentations/home/paybill/mobile_recharge/mobile_recharge_screen.dart';
import '../../presentations/home/receive_money/receive_money_screen.dart';
import '../../presentations/home/send_money/send_money_home.dart';
import '../../presentations/home/tickets/train/train_list_screen.dart';
import '../../presentations/main route/route_screen.dart';
import '../../presentations/setting/live_chat.dart';
import '../../presentations/setting/profile_screens/profile_screen.dart';
import '../../presentations/setting/submit_ticket/submit_a_ticket.dart';
import '../../presentations/splash_screen/splash_screen.dart';
import '../../presentations/transaction/transaction_home_screen.dart';
import '../../presentations/widgets/helper_widgets/custom_transition_widget.dart';
import 'routes_name.dart';

final GoRouter appRouter = GoRouter(
  // initialLocation: '/',
  initialLocation: RouteNames.splash,
  routes: <RouteBase>[
    GoRoute(
      path: RouteNames.splash,
      builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.signIn,
      builder: (BuildContext context, GoRouterState state) => const SignInScreen(),
    ),
    GoRoute(
      path: RouteNames.signUp,
      builder: (BuildContext context, GoRouterState state) => const SignUpScreen(),
    ),
    GoRoute(
      path: RouteNames.transactionHistory,
      builder: (BuildContext context, GoRouterState state) => const TransactionHomeScreen(),
    ),
    GoRoute(
      path: RouteNames.forgetPassword,
      builder: (BuildContext context, GoRouterState state) => const ForgetPasswordScreen(),
    ),
    GoRoute(
      path: RouteNames.faqs,
      builder: (BuildContext context, GoRouterState state) => const FaqsScreen(),
    ),
    GoRoute(
      path: RouteNames.homeScreen,
      builder: (BuildContext context, GoRouterState state) => BlocProvider(create: (_) => RouteCubit(), child: const RouteScreen()),
    ),

    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider(create: (_) => RouteCubit(), child: const RouteScreen()),
    ),
    GoRoute(
      path: RouteNames.addCard,
      builder: (BuildContext context, GoRouterState state) {
        return const AddCardHomeScreen();
      },
    ),
    //setting screens
    GoRoute(
      path: RouteNames.submitATicket,
      builder: (BuildContext context, GoRouterState state) => const SubmitATicket(),
    ),
    GoRoute(
      path: RouteNames.showTicket,
      builder: (BuildContext context, GoRouterState state) => const ShowTicketScreen(),
    ),
    GoRoute(
      path: RouteNames.liveChat,
      builder: (BuildContext context, GoRouterState state) => const LiveChatScreen(),
    ),
    GoRoute(
      path: RouteNames.communityForum,
      builder: (BuildContext context, GoRouterState state) => const CommunityForumScreen(),
    ),
    GoRoute(
      path: RouteNames.createPost,
      builder: (BuildContext context, GoRouterState state) => CreatePostScreen(),
    ),
    GoRoute(
      path: RouteNames.profile,
      // Use pageBuilder for custom transitions
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey, // Important for GoRouter
          child: const ProfileHomeScreen(), // Your ProfileScreen widget
        );
      },
    ),
    GoRoute(
      path: RouteNames.changePass,
      // Use pageBuilder for custom transitions
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey, // Important for GoRouter
          child: const ChangePasswordScreen(), // Your ProfileScreen widget
        );
      },
    ),
    GoRoute(
      path: RouteNames.deviceManagement,
      // Use pageBuilder for custom transitions
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey, // Important for GoRouter
          child: const DevicesManagementScreen(), // Your ProfileScreen widget
        );
      },
    ),
    GoRoute(
      path: RouteNames.taxAndLegalCompliance,
      // Use pageBuilder for custom transitions
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey, // Important for GoRouter
          child: const TaxComplianceScreen(), // Your ProfileScreen widget
        );
      },
    ),
    GoRoute(
      path: RouteNames.refundAndCashback,
      // Use pageBuilder for custom transitions
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey, // Important for GoRouter
          child: const CashbackAndRefundsScreen(), // Your ProfileScreen widget
        );
      },
    ),
    GoRoute(
      path: RouteNames.dataAndPermissions,
      // Use pageBuilder for custom transitions
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey, // Important for GoRouter
          child: const DataAndPermissionsScreen(), // Your ProfileScreen widget
        );
      },
    ),
    GoRoute(
      path: RouteNames.sendMoneyHome,
      // Use pageBuilder for custom transitions
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey, // Important for GoRouter
          child: const SendMoneyHome(), // Your ProfileScreen widget
        );
      },
    ),
    GoRoute(
      path: RouteNames.receiveMoneyScreen,
      // Use pageBuilder for custom transitions
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey, // Important for GoRouter
          child: const ReceiveMoneyScreen(), // Your ProfileScreen widget
        );
      },
    ),
    // GoRoute(
    //   path: RouteNames.payBillsHome,
    //   // Use pageBuilder for custom transitions
    //   pageBuilder: (BuildContext context, GoRouterState state) {
    //     return CustomFadeTransitionPage(
    //       key: state.pageKey, // Important for GoRouter
    //       child: const PayBillsHome(), // Your ProfileScreen widget
    //     );
    //   },
    // ),

    GoRoute(
      path: RouteNames.payBillsDetailView,
      pageBuilder: (BuildContext context, GoRouterState state) {
        // Extract the extra data passed from the previous screen
        final Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;

        return CustomFadeTransitionPage(
          key: state.pageKey,
          child: PayBillDetailsView(
            billType: extra?['billType'] as String?,
            companyName: extra?['companyName'] as String?,
          ),
        );
      },
    ),

    GoRoute(
      path: RouteNames.receiptView,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final PayBillModel? payBillData = state.extra as PayBillModel?;

        return CustomFadeTransitionPage(
          key: state.pageKey,
          child: ReceiptView(payBillData: payBillData),
        );
      },
    ),

    GoRoute(
      path: RouteNames.currencyExchangeView,
      // Use pageBuilder for custom transitions
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey, // Important for GoRouter
          child: const CurrencyExchangeView(), // Your ProfileScreen widget
        );
      },
    ),

    GoRoute(
      path: RouteNames.currencyExchangeHistoryView,
      // Use pageBuilder for custom transitions
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey, // Important for GoRouter
          child:
              const CurrencyExchangeHistoryView(), // Your ProfileScreen widget
        );
      },
    ),

    GoRoute(
      path: RouteNames.calculatorView,
      // Use pageBuilder for custom transitions
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey, // Important for GoRouter
          child: const CalculatorView(), // Your ProfileScreen widget
        );
      },
    ),

    GoRoute(
      path: RouteNames.calculatorHistoryView,
      // Use pageBuilder for custom transitions
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey, // Important for GoRouter
          child: const CalculatorHistoryView(), // Your ProfileScreen widget
        );
      },
    ),
    // Debug route for testing authentication
    GoRoute(
      path: '/auth-test',
      builder: (BuildContext context, GoRouterState state) => const AuthTestScreen(),
    ),

    GoRoute(
      path: RouteNames.mobileRechargeScreen,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey,
          child: const MobileRechargeScreen(),
        );
      }
    ),

    GoRoute(
      path: RouteNames.electricCityBillScreen,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomFadeTransitionPage(
          key: state.pageKey,
          child: const ElectricCityBillScreen(),
        );
      }
    ),

    GoRoute(
        path: RouteNames.internetBillScreen,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomFadeTransitionPage(
            key: state.pageKey,
            child: const InternetBillScreen(),
          );
        }
    ),

    GoRoute(
        path: RouteNames.dthRechargeScreen,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomFadeTransitionPage(
            key: state.pageKey,
            child:  const DTHRechargeScreen(),
          );
        }
    ),

    GoRoute(
        path: RouteNames.splitBill,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomFadeTransitionPage(
            key: state.pageKey,
            child: const BillSplitScreen(),
          );
        }
    ),

    GoRoute(
        path: RouteNames.postpaidBillScreen,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomFadeTransitionPage(
            key: state.pageKey,
            child: const PostpaidBillScreen(),
          );
        }
    ),

    GoRoute(
        path: RouteNames.rentPaymentScreen,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomFadeTransitionPage(
            key: state.pageKey,
            child: const RentPaymentScreen(),
          );
        }
    ),

    GoRoute(
        path: RouteNames.moviesScreen,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomFadeTransitionPage(
            key: state.pageKey,
            child: const MoviesScreen(),
          );
        }
    ),

    GoRoute(
        path: RouteNames.gasBillScreen,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomFadeTransitionPage(
            key: state.pageKey,
            child: const GasBillScreen(),
          );
        }
    ),

    GoRoute(
        path: RouteNames.creditCardLoanScreen,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomFadeTransitionPage(
            key: state.pageKey,
            child: const CreditCardLoanScreen(),
          );
        }
    ),

    GoRoute(
        path: RouteNames.trainListScreen,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomFadeTransitionPage(
            key: state.pageKey,
            child: const TrainListScreen(),
          );
        }
    ),
  ],
);
