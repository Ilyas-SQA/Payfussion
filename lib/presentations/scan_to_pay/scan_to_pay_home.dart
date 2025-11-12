import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:payfussion/data/models/card/card_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wave/config.dart';
import 'dart:async';
import 'package:wave/wave.dart';
import '../../core/constants/fonts.dart';
import '../../core/theme/theme.dart';
import '../interfaces/screen_visibility_interface.dart';
import '../widgets/payment_selector_widget.dart';

class ScanToPayHomeScreen extends StatefulWidget {
  const ScanToPayHomeScreen({super.key});

  @override
  State<ScanToPayHomeScreen> createState() => _ScanToPayHomeScreenState();
}

extension ScanToPayHomeScreenExtension on GlobalKey<State<ScanToPayHomeScreen>> {
  ScreenVisibilityInterface? getVisibilityHandler() {
    final State<ScanToPayHomeScreen>? state = currentState;
    if (state is ScreenVisibilityInterface) {
      return state as ScreenVisibilityInterface;
    }
    return null;
  }
}

class _ScanToPayHomeScreenState extends State<ScanToPayHomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  // Mobile scanner controller instead of manual camera handling
  MobileScannerController? mobileScannerController;
  bool isCameraInitialized = false;
  bool isQRMode = true;
  bool isFlashlightOn = false;
  bool _nfcAvailable = false;
  bool _isNfcProcessing = false;
  bool _isProcessingCode = false;
  bool _isNfcSessionActive = false;
  late AnimationController _nfcAnimationController;
  bool _isScreenVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNfcAvailability();

    // Initialize animation controller
    _nfcAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Start with camera initialization
    _initializeScanner();
  }

  // Initialize mobile scanner
  Future<void> _initializeScanner() async {
    try {
      // Check camera permission first
      final PermissionStatus status = await Permission.camera.request();
      if (status.isDenied) {
        _showErrorSnackBar("Camera permission is required for QR scanning");
        return;
      }

      // Initialize mobile scanner controller
      mobileScannerController = MobileScannerController(
        facing: CameraFacing.back,
        torchEnabled: false,
        formats: const <BarcodeFormat>[BarcodeFormat.qrCode], // Only QR codes
        returnImage: false,
      );

      // Start the scanner
      await mobileScannerController!.start();

      setState(() {
        isCameraInitialized = true;
      });

      debugPrint("Mobile scanner initialized successfully");
    } catch (e) {
      debugPrint('Error initializing scanner: $e');
    }
  }

  @override
  void onScreenVisible() {
    _isScreenVisible = true;
    if (isQRMode && !isCameraInitialized) {
      _initializeScanner();
    } else if (!isQRMode && _nfcAvailable) {
      _nfcAnimationController.repeat();
      _startNfcSession();
    }
  }

  @override
  void onScreenInvisible() {
    _isScreenVisible = false;
    if (mobileScannerController != null) {
      mobileScannerController!.stop();
    }
    if (_isNfcSessionActive) {
      _stopNfcSession();
    }
    _nfcAnimationController.stop();
  }

  Future<void> _checkNfcAvailability() async {
    _nfcAvailable = await NfcManager.instance.isAvailable();
  }

  Future<void> _startNfcSession() async {
    if (!_nfcAvailable) {
      _showErrorSnackBar("NFC is not available on this device");
      return;
    }

    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          _handleNfcTag(tag);
        },
        pollingOptions: <NfcPollingOption>{
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
      );
      _isNfcSessionActive = true;
    } catch (e) {
      _showErrorSnackBar("Failed to start NFC: ${e.toString()}");
    }
  }

  Future<void> _stopNfcSession() async {
    if (!_isNfcSessionActive) return;

    try {
      NfcManager.instance.stopSession();
      _isNfcSessionActive = false;
    } catch (e) {
      debugPrint("Error stopping NFC session: $e");
    }
  }

  Future<void> _handleNfcTag(NfcTag tag) async {
    if (_isNfcProcessing) return;
    _isNfcProcessing = true;

    HapticFeedback.mediumImpact();

    try {
      final Map<String, String>? paymentData = await _extractPaymentDataFromNfc(tag);

      if (paymentData != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("NFC payment detected!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid payment information on NFC"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error reading NFC: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isNfcProcessing = false;
    }
  }

  Future<Map<String, String>?> _extractPaymentDataFromNfc(NfcTag tag) async {
    try {
      final Map<String, dynamic> tagData = tag.data as Map<String, dynamic>;

      if (tagData.containsKey('ndef')) {
        final Map<String, dynamic>? ndefData = tagData['ndef'] as Map<String, dynamic>?;
        if (ndefData != null && ndefData.containsKey('cachedMessage')) {
          final Map<String, dynamic>? cachedMessage = ndefData['cachedMessage'] as Map<String, dynamic>?;
          if (cachedMessage != null && cachedMessage.containsKey('records')) {
            final List? records = cachedMessage['records'] as List?;

            if (records != null && records.isNotEmpty) {
              for (final record in records) {
                final Map<String, dynamic> recordMap = record as Map<String, dynamic>;
                if (recordMap['typeNameFormat'] == 1) {
                  final List<int>? payload = recordMap['payload'] as List<int>?;
                  if (payload != null) {
                    final String payloadString = String.fromCharCodes(payload);
                    if (payloadString.startsWith('PAY:')) {
                      return _parseNfcPayload(payloadString);
                    }
                  }
                }
              }
            }
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error extracting NFC data: $e");
      return null;
    }
  }

  Map<String, String> _parseNfcPayload(String payload) {
    final Map<String, String> data = <String, String>{};
    final List<String> parts = payload.substring(4).split('&');
    for (final String part in parts) {
      final List<String> keyValue = part.split('=');
      if (keyValue.length == 2) {
        data[keyValue[0]] = keyValue[1];
      }
    }
    return data;
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _initializeScanner(),
        ),
      ),
    );
  }

  void toggleFlashlight() async {
    if (mobileScannerController == null) return;

    try {
      await mobileScannerController!.toggleTorch();
      setState(() {
        isFlashlightOn = !isFlashlightOn;
      });
    } catch (e) {
      debugPrint('Error toggling flashlight: $e');
    }
  }

  void toggleMode() async {
    setState(() {
      isQRMode = !isQRMode;

      if (isQRMode) {
        // Switching to QR mode
        _initializeScanner();
        _nfcAnimationController.stop();
        if (_isNfcSessionActive) {
          _stopNfcSession();
        }
      } else {
        // Switching to NFC mode
        if (mobileScannerController != null) {
          mobileScannerController!.stop();
          isCameraInitialized = false;
        }
        _nfcAnimationController.repeat();
        _startNfcSession();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mobileScannerController?.dispose();
    _nfcAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mobileScannerController == null) return;

    if (state == AppLifecycleState.inactive) {
      mobileScannerController!.stop();
    } else if (state == AppLifecycleState.resumed && isQRMode) {
      mobileScannerController!.start();
    }
  }

  void _handleScannedCode(String code) {
    if (_isProcessingCode) return;
    _isProcessingCode = true;

    HapticFeedback.mediumImpact();

    try {
      debugPrint("Scanned QR Code: $code");

      if (code.startsWith('PAY:') || _isValidPaymentQr(code)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment QR detected!"),
            backgroundColor: Colors.green,
          ),
        );
        _processPaymentQr(code);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid payment QR code"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error processing QR: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isProcessingCode = false;
      });
    }
  }

  bool _isValidPaymentQr(String code) {
    return code.contains('amount=') && code.contains('recipient=');
  }

  void _processPaymentQr(String code) {
    final Map<String, String> paymentData = _parseQrData(code);
    debugPrint("Payment Data: $paymentData");
    // Navigate to payment confirmation screen
  }

  Map<String, String> _parseQrData(String code) {
    final Map<String, String> data = <String, String>{};
    final List<String> parts = code.split('&');
    for (final String part in parts) {
      final List<String> keyValue = part.split('=');
      if (keyValue.length == 2) {
        data[keyValue[0]] = keyValue[1];
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          /// Camera preview or NFC screen
          isQRMode ? _buildCameraPreview() : _buildNFCScreen(),

          // Credit card indicator at the top
          Positioned(
            top: 50.h,
            left: 0,
            right: 0,
            child: _buildCreditCardIndicator(),
          ),

          // Mode switcher at the bottom
          Positioned(
            bottom: 100.h,
            left: 0,
            right: 0,
            child: Column(
              children: <Widget>[
                if (isQRMode) _buildFlashlightButton(),
                SizedBox(height: 20.h),
                _buildModeSwitcher(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      children: <Widget>[
        // Show loading until camera is ready
        if (!isCameraInitialized)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  "Initializing camera...",
                  style: Font.montserratFont(color: Colors.white),
                ),
              ],
            ),
          ),

        // Mobile Scanner
        if (isCameraInitialized && mobileScannerController != null)
          MobileScanner(
            controller: mobileScannerController,
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && mounted) {
                final String code = barcodes.first.rawValue ?? '';
                if (code.isNotEmpty) {
                  _handleScannedCode(code);
                }
              }
            },
            errorBuilder: (BuildContext context, MobileScannerException error, Widget? child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Camera Error: ${error.toString()}",
                      style: Font.montserratFont(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initializeScanner,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            },
          ),

        // QR Scan overlay with guidelines - only show when camera is ready
        if (isCameraInitialized)
          Center(
            child: Container(
              width: 250.w,
              height: 250.w,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Stack(
                children: <Widget>[
                  // Corner indicators
                  Positioned(top: 0, left: 0, child: _buildCornerIndicator()),
                  Positioned(top: 0, right: 0, child: _buildCornerIndicator(isRight: true)),
                  Positioned(bottom: 0, left: 0, child: _buildCornerIndicator(isBottom: true)),
                  Positioned(bottom: 0, right: 0, child: _buildCornerIndicator(isRight: true, isBottom: true)),
                ],
              ),
            ),
          ),

        // Scan guidelines text
        if (isCameraInitialized)
          Positioned(
            bottom: 200.h,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              color: Colors.black.withOpacity(0.5),
              child: Column(
                children: <Widget>[
                  Text(
                    "Align QR code within the frame",
                    textAlign: TextAlign.center,
                    style: Font.montserratFont(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Hold your phone steady",
                    textAlign: TextAlign.center,
                    style: Font.montserratFont(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNFCScreen() {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: <Widget>[
            SizedBox(height: 80.h),

            // NFC Animation
            Container(
              height: 240.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: MyTheme.secondaryColor, width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // Wave animation
                  WaveWidget(
                    config: CustomConfig(
                      colors: <Color>[
                        MyTheme.secondaryColor,
                        MyTheme.primaryColor
                      ],
                      durations: <int>[4000, 5000],
                      heightPercentages: <double>[0.65, 0.66],
                      blur: const MaskFilter.blur(BlurStyle.solid, 5),
                    ),
                    waveAmplitude: 0,
                    backgroundColor: Colors.transparent,
                    size: const Size(double.infinity, double.infinity),
                  ),

                  // Phone icon
                  Container(
                    padding: EdgeInsets.all(18.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: MyTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/icons/transaction_screen_icons/nfc_phone.png',
                      width: 40.w,
                      height: 40.h,
                      fit: BoxFit.contain,
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Icon(
                        Icons.contactless_rounded,
                        size: 40.sp,
                        color: MyTheme.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Instructions
            Text(
              "Ready to Pay",
              style: Font.montserratFont(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 12.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withOpacity(0.8),
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "Hold your phone near the payment terminal",
                      style: Font.montserratFont(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Transaction Amount
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[MyTheme.primaryColor, MyTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: MyTheme.secondaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Transaction Amount",
                    style: Font.montserratFont(color: Colors.white, fontSize: 14.sp),
                  ),
                  Text(
                    "\$XXX.XX",
                    style: Font.montserratFont(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Security note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.lock_outline,
                  color: Colors.white.withOpacity(0.7),
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Secure encrypted transaction",
                  style: Font.montserratFont(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerIndicator({bool isRight = false, bool isBottom = false}) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        border: Border(
          top: !isBottom
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          bottom: isBottom
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          left: !isRight
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          right: isRight
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCreditCardIndicator() {
    return PaymentCardSelector(
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      onCardSelect: (CardModel card) {
        debugPrint('Selected: ${card.last4}');
        debugPrint('Selected: ${card.expYear}');
        debugPrint('Selected: ${card.expMonth}');
        debugPrint('Selected: ${card.last4}');
      },
    );
  }

  Widget _buildFlashlightButton() {
    return GestureDetector(
      onTap: toggleFlashlight,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFlashlightOn ? Icons.flash_on : Icons.flash_off,
          color: Colors.white,
          size: 28.sp,
        ),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Center(
      child: Container(
        width: 186.w,
        height: 50.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[MyTheme.primaryColor, MyTheme.secondaryColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Stack(
          children: <Widget>[
            // Animated selected background
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isQRMode ? 3.w : 93.w,
              top: 3.h,
              child: Container(
                width: 90.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                ),
              ),
            ),

            // QR and NFC text options
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!isQRMode) toggleMode();
                    },
                    child: Center(
                      child: Text(
                        "QR Code",
                        style: Font.montserratFont(
                          color: isQRMode ? MyTheme.primaryColor : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isQRMode) toggleMode();
                    },
                    child: Center(
                      child: Text(
                        "NFC",
                        style: Font.montserratFont(
                          color: !isQRMode ? MyTheme.primaryColor : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}