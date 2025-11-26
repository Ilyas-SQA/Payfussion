import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nested/nested.dart';
import 'package:payfussion/data/repositories/insurance/insurance_repository.dart';
import 'package:payfussion/data/repositories/notification/notification_repository.dart';
import 'package:payfussion/data/repositories/ticket/movies_repository.dart';
import 'package:payfussion/logic/blocs/add_card/card_bloc.dart';
import 'package:payfussion/logic/blocs/auth/auth_bloc.dart';
import 'package:payfussion/logic/blocs/bank_transaction/bank_transaction_bloc.dart';
import 'package:payfussion/logic/blocs/currency/currency_bloc.dart';
import 'package:payfussion/logic/blocs/donation/donation_bloc.dart';
import 'package:payfussion/logic/blocs/insurance/insurance_bloc.dart';
import 'package:payfussion/logic/blocs/notification/notification_bloc.dart';
import 'package:payfussion/logic/blocs/pay_bill/bill_split/bill_split_bloc.dart';
import 'package:payfussion/logic/blocs/pay_bill/electricity_bill/electricity_bill_bloc.dart';
import 'package:payfussion/logic/blocs/pay_bill/gas_bill/gas_bill_bloc.dart';
import 'package:payfussion/logic/blocs/pay_bill/internet_bill/internet_bill_bloc.dart';
import 'package:payfussion/logic/blocs/pay_bill/mobile_recharge/mobile_recharge_bloc.dart';
import 'package:payfussion/logic/blocs/pay_bill/postpaid_bill/postpaid_bill_bloc.dart';
import 'package:payfussion/logic/blocs/pay_bill/rent_payment/rent_payment_bloc.dart';
import 'package:payfussion/logic/blocs/setting/community_forum/community_form_bloc.dart';
import 'package:payfussion/logic/blocs/setting/user_profile/profile_bloc.dart';
import 'package:payfussion/logic/blocs/theme/theme_bloc.dart';
import 'package:payfussion/logic/blocs/tickets/bus/bus_bloc.dart';
import 'package:payfussion/logic/blocs/tickets/bus/bus_event.dart';
import 'package:payfussion/logic/blocs/tickets/car/car_event.dart';
import 'package:payfussion/logic/blocs/tickets/flight/flight_event.dart';
import 'package:payfussion/logic/blocs/tickets/movies/movies_bloc.dart';
import 'package:payfussion/logic/blocs/tickets/movies/movies_event.dart';
import 'package:payfussion/logic/blocs/transaction/transaction_bloc.dart';
import 'package:payfussion/services/biometric_service.dart';
import 'package:payfussion/services/local_storage.dart';
import 'package:payfussion/services/notification_service.dart';
import 'package:payfussion/services/service_locator.dart';
import 'package:payfussion/services/session_manager_service.dart';
import 'package:payfussion/services/submit_ticket_service.dart';
import 'core/constants/routes.dart';
import 'core/theme/theme.dart';
import 'data/repositories/pay_bill/pay_bill_repository.dart';
import 'data/repositories/payment_request/payment_request_repository.dart';
import 'data/repositories/recipient/recipient_repository.dart';
import 'data/repositories/setting_repositories/device_manager/device_manager_repository.dart';
import 'data/repositories/ticket/bus_repository.dart';
import 'data/repositories/ticket/car_repository.dart';
import 'data/repositories/ticket/flight_repository.dart';
import 'data/repositories/ticket/train_repository.dart';
import 'data/repositories/transaction/transaction_repository.dart';
import 'domain/repository/auth/auth_repository.dart';
import 'logic/blocs/currency_convert/currency_convert_bloc.dart';
import 'logic/blocs/graph_currency/graph_currency_bloc.dart';
import 'logic/blocs/graph_currency/graph_currency_event.dart';
import 'logic/blocs/pay_bill/credit_card_loan/credit_card_loan_bloc.dart';
import 'logic/blocs/pay_bill/dth_bill/dth_bill_bloc.dart';
import 'logic/blocs/pay_bill/movies/movies_bloc.dart';
import 'logic/blocs/pay_bill/pay_bill_bloc.dart';
import 'logic/blocs/payment_request/payment_request_bloc.dart';
import 'logic/blocs/recipient/recipient_bloc.dart';
import 'logic/blocs/setting/change-password/change_password_bloc.dart';
import 'logic/blocs/setting/device_manager/device_manager_bloc.dart';
import 'logic/blocs/setting/live_chat/live_chat_bloc.dart';
import 'logic/blocs/setting/setting_bloc.dart';
import 'logic/blocs/submit_a_ticket/submit_a_ticket_bloc.dart';
import 'logic/blocs/theme/theme_state.dart';
import 'logic/blocs/tickets/car/car_bloc.dart';
import 'logic/blocs/tickets/flight/flight_bloc.dart';
import 'logic/blocs/tickets/train/train_bloc.dart';
import 'logic/blocs/tickets/train/train_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await ServiceLocator.init();
    await dotenv.load();
    await LocalNotificationService.initialize();
    Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
    await Stripe.instance.applySettings();
    SessionController.user.phoneNumber;
    runApp(const MyApp());
  } catch (e, stack) {
    print('App initialization error: $e');
    print(stack);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(localStorage: getIt<LocalStorage>()),
        ),
        BlocProvider<CurrencyBloc>(
          create: (_) => CurrencyBloc(localStorage: getIt<LocalStorage>()),
        ),
        BlocProvider<ChangePasswordBloc>(
          create: (_) => ChangePasswordBloc(getIt<AuthRepository>()),
        ),
        BlocProvider<DeviceBloc>(
          create: (_) => DeviceBloc(DeviceRepository()),
        ),
        BlocProvider<CommunityFormBloc>(
          create: (_) => CommunityFormBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(userId: SessionController.user.uid.toString()),
        ),
        BlocProvider<AuthBloc>(
          create: (BuildContext context) => AuthBloc(
            authRepository: getIt<AuthRepository>(),
            biometricService: getIt<BiometricService>(),
            sessionController: getIt<SessionController>(),
            deviceBloc: context.read<DeviceBloc>(),
          ),
        ),
        BlocProvider<ProfileBloc>(
          create: (BuildContext context) => ProfileBloc(
            authRepository: getIt<AuthRepository>(),
          ),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => SettingsBloc(),
        ),
        BlocProvider<SubmitATicketBloc>(
          create: (BuildContext context) => SubmitATicketBloc(ticketRepository: TicketRepository()),
        ),
        BlocProvider<CurrencyConversionBloc>(
          create: (BuildContext context) => CurrencyConversionBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) => GraphCurrencyBloc()..add(LoadCurrencies()),
        ),
        BlocProvider(
          create: (BuildContext context) => CardBloc(),
        ),
        BlocProvider<PaymentRequestBloc>(
          create: (BuildContext context) => PaymentRequestBloc(
            repository: FirestorePaymentRepository(),
          ),
        ),
        BlocProvider(
          create: (_) => RecipientBloc(
            repo: RecipientRepositoryFB(),
            userId: SessionController.user.uid.toString(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => NotificationBloc(NotificationRepository()),
        ),
        BlocProvider(
          create: (_) => TransactionBloc(
            biometricService: getIt<BiometricService>(),
            txRepo: TransactionRepository(),
            notificationRepo: NotificationRepository(),
          )
        ),
        BlocProvider(
          create: (BuildContext context) => PayBillBloc(
            PayBillRepository(),
            context.read<NotificationBloc>(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => TrainBloc(TrainRepository())..add(LoadTrains()),
        ),
        BlocProvider(
          create: (BuildContext context) => BookingBloc(
            TrainRepository(),
            context.read<NotificationBloc>(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => BusBloc(BusRepository())..add(LoadBuses()),
        ),
        BlocProvider(
          create: (BuildContext context) => BusBookingBloc(
            BusRepository(),
            context.read<NotificationBloc>(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => FlightBloc(FlightFirebaseService())..add(LoadFlights()),
        ),
        BlocProvider(
          create: (BuildContext context) => FlightBookingBloc(
            FlightFirebaseService(),
            context.read<NotificationBloc>(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => MovieBloc(MovieRepository())..add(LoadMovies()),
        ),
        BlocProvider(
          create: (BuildContext context) => MovieBookingBloc(
            MovieRepository(),
            context.read<NotificationBloc>(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => RideBloc(RideFirebaseService())..add(LoadRides()),
        ),
        BlocProvider(
          create: (BuildContext context) => RideBookingBloc(
            RideFirebaseService(),
            context.read<NotificationBloc>(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => BankTransactionBloc(
              biometricService: BiometricService(),
              notificationRepository: NotificationRepository(),
          ),
        ),
        BlocProvider(
          create: (BuildContext context) => InsurancePaymentBloc(
            InsurancePaymentRepository(),
          ),
        ),
        BlocProvider(create: (BuildContext context) => ElectricityBillBloc(NotificationBloc(NotificationRepository())),),
        BlocProvider(create: (BuildContext context) => MobileRechargeBloc(NotificationBloc(NotificationRepository()),)),
        BlocProvider(create: (BuildContext context) => GasBillBloc(NotificationBloc(NotificationRepository()),)),
        BlocProvider(create: (BuildContext context) => MoviesBloc(context.read<NotificationBloc>()),),
        BlocProvider(create: (BuildContext context) => RentPaymentBloc(PayBillRepository(), NotificationBloc(NotificationRepository()),),),
        BlocProvider(create: (BuildContext context) => PostpaidBillBloc(context.read<NotificationBloc>())),
        BlocProvider(create: (BuildContext context) => CreditCardLoanBloc(context.read<NotificationBloc>(),),),
        BlocProvider(create: (BuildContext context) => DthRechargeBloc(context.read<NotificationBloc>())),
        BlocProvider(create: (BuildContext context) => BillSplitBloc(context.read<NotificationBloc>())),
        BlocProvider(create: (BuildContext context) => InternetBillBloc(context.read<NotificationBloc>())),
        BlocProvider(create: (BuildContext context) => DonationBloc(context.read<NotificationBloc>())),

      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (BuildContext context, Widget? child) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (BuildContext context, ThemeState themeState) {
              final ThemeMode currentThemeMode = themeState.themeMode;
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'PayFussion',
                routerConfig: appRouter,
                theme: MyTheme.lightTheme(context),
                darkTheme: MyTheme.darkTheme(context),
                themeMode: themeState.themeMode,
              );
            },
          );
        },
      ),
    );
  }
}


