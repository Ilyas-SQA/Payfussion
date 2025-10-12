import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TImageUrl {
  TImageUrl._();

  static const String iconLogo = 'assets/icons/logo.png';
  static const String iconCreditCard = 'assets/icons/credit_card.png';
  static const String iconElectricity = 'assets/icons/electricity.png';
  static const String iconGas = 'assets/icons/gas.png';
  static const String iconInternet = 'assets/icons/internet.png';
  static const String iconIphone = 'assets/icons/iphone.png';
  static const String iconNetlix = 'assets/icons/netflix.png';
  static const String iconPlay = 'assets/icons/play.png';
  static const String iconRent = 'assets/icons/rent.png';
  static const String iconPayBil = 'assets/icons/pay_bill_icon.png';
  static const String iconPostpaid = 'assets/icons/postpaid.png';

  // Home Screen Icons
  static const String iconSendMoney = 'assets/icons/send_money_icon.png';
  static const String iconReceiveMoney = 'assets/icons/recieve_money_icon.png';
  static const String iconConvert = 'assets/icons/convert_icon.png';
  static const String iconConversionTransaction = 'assets/icons/conversion_transaction.png';
  static const String iconProfile = 'assets/icons/profile_pic.png';
  static const String iconCreditCardTransaction = 'assets/icons/credit_transaction_icon.png';
  static const String iconBillSplit = 'assets/icons/bill_split.png';

  static const String iconBell = 'assets/icons/bell_icon.png';
  static const String iconCardBGBlur = 'assets/icons/card_bg_blur.png';
  static const String iconNfc = 'assets/icons/nfc_icon.png';
  static const String iconChip = 'assets/icons/chip_icon.png';
  static const String iconVisa = 'assets/icons/visa_logo.png';
  static const String iconMaster = 'assets/icons/master.png';
  static const String iconEye = 'assets/icons/eye_icon.png';

  /// Nav bar Icon
  static const String iconHome = 'assets/icons/home_icon.png';
  static const String iconAddCard = 'assets/icons/add_card_icon.png';
  static const String iconMore = 'assets/icons/more_icon.png';
  static const String iconScanner = 'assets/icons/scanner_icon.png';
  static const String iconTransaction = 'assets/icons/transaction_icon.png';
  static const String iconCreditCardBG = 'assets/icons/credit_card_bg.png';
  static const String iconMasterCard = 'assets/icons/mastercard.png';
  static const String iconCardBG = 'assets/icons/card_bg.png';

  // ticket booking
  static const String iconMovies = 'assets/icons/video-play.png';
  static const String iconTrains = "assets/icons/train.png";

  static const String iconBus = "assets/icons/bus.png";
  static const String iconCar = "assets/icons/car.png";
  static const String iconFlight = "assets/icons/flight.png";
  static const String iconFingerScanner = "assets/icons/finger_scan.png";
  static const String iconDone = "assets/icons/tick-circle.png";
  static const String iconSavingAccount = "assets/icons/icon_saving_account.png";
  static const String iconCurrentAccount = "assets/icons/current_account.png";

  static const String iconUpDown = "assets/icons/updown_icon.png";
  static const String iconDown = "assets/icons/down_icon.png";
  static const String iconBulb = "assets/icons/bulb_icon.png";
  static const String iconGraph = "assets/icons/graph.png";
  static const String iconCalulator = "assets/icons/calculator.png";

  static const String iconSearch = "assets/icons/search_icon.png";

  static const String iconFilter = "assets/icons/filter.png";

  static const String iconFlag1 = "assets/icons/flag1.png";

  static const String iconFlag2 = "assets/icons/flag2.png";

  static const String iconConvert1 = "assets/icons/convert_icon1.png";

  static const String iconNoTransaction = "assets/icons/no_transaction_image.png";

  static Widget getCardBrandLogo(String cardBrand) {
    switch (cardBrand.toLowerCase()) {
      case 'visa':
        return SvgPicture.asset(visa, height: 40.h, width: 40.w,color: Colors.white,);
      case 'mastercard':
        return SvgPicture.asset(masterCard, height: 14.h,width: 14.w,);
      case 'amex':
      case 'american express':
        return SvgPicture.asset(amex, height: 14.h,width: 14.w,);
      default:
        return const Icon(Icons.credit_card, size: 40); // fallback icon
    }
  }

  /// card
  static const String visa = 'assets/images/cards/visa-logo.svg';
  static const String masterCard = 'assets/images/cards/Mastercard.svg';
  static const String discover = 'assets/images/cards/DISC-VER.svg';
  static const String amex = 'assets/images/cards/AMEX.svg';
  static const String sim = 'assets/images/cards/card_chip_icon.svg';
  static const String nfc = 'assets/images/cards/NFC_icon.svg';


  /// bottom navigation bar
  static const String home = 'assets/images/bottom_navigation_bar/home.svg';
  static const String qrCode = 'assets/images/bottom_navigation_bar/QR_icon.svg';
  static const String transaction = 'assets/images/bottom_navigation_bar/arrow.svg';
  static const String menu = 'assets/images/bottom_navigation_bar/Menu.svg';

  /// setting
  static const String fingerPrint = 'assets/images/setting/fingerprint.svg';
  static const String communityForm = 'assets/images/setting/community_form.svg';
  static const String currency = 'assets/images/setting/currency.svg';
  static const String data = 'assets/images/setting/data.svg';
  static const String deviceManagement = 'assets/images/setting/device_management.svg';
  static const String liveChat = 'assets/images/setting/live_chat.svg';
  static const String submitTTicket = 'assets/images/setting/submit_ticket.svg';
  static const String transactionPrivacy = 'assets/images/setting/transaction_privacy.svg';
  static const String refund = 'assets/images/setting/refund.svg';
  static const String tax = 'assets/images/setting/tax.svg';
  static const String twoFactor = 'assets/images/setting/two_factor.svg';
  static const String faq = 'assets/images/setting/faq.svg';
  static const String lockAccount = 'assets/images/setting/lock_account.svg';


  /// transaction
  static const String filter = 'assets/images/transaction/filter.svg';
  static const String search = 'assets/images/transaction/search_icon.svg';
  static const String wallet = 'assets/images/transaction/items.svg';
  static const String reward = 'assets/images/reward.svg';

  /// home
  static const String sendMoney = 'assets/images/home/send_money.svg';
  static const String recivedMoney = 'assets/images/home/recived_money.svg';
  static const String payBill = 'assets/images/home/bill_pay.svg';
  static const String convertCurrency = 'assets/images/home/convert_currency.svg';
  static const String ticketBooking = 'assets/images/home/ticket_booking.svg';
  static const String insurance = 'assets/images/home/insurance.svg';
  static const String applyCard = 'assets/images/home/apply_card.svg';
  static const String governmentFee = 'assets/images/home/government_fee.svg';
  static const String bankTransfer = 'assets/images/home/bank_transfer.svg';
  static const String scanner = 'assets/images/home/scanner.svg';
  static const String otherWallet = 'assets/images/home/wallet.svg';

  /// PayBill
  static const String dth = 'assets/images/paybill/dth.svg';
  static const String billSplit = 'assets/images/paybill/bill_split.svg';
  static const String creditCardLoan = 'assets/images/paybill/credit_card_loan.svg';
  static const String electricBill = 'assets/images/paybill/electricity_bill.svg';
  static const String entertainment = 'assets/images/paybill/entertainment.svg';
  static const String gasBill = 'assets/images/paybill/gas_bill.svg';
  static const String rentBill = 'assets/images/paybill/rent_bill.svg';




}
