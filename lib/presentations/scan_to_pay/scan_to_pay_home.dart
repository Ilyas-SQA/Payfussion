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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver
    implements ScreenVisibilityInterface {

  MobileScannerController? mobileScannerController;
  bool isCameraInitialized = false;
  bool isQRMode = true;
  bool isFlashlightOn = false;
  bool _nfcAvailable = false;
  bool _isNfcProcessing = false;
  bool _isProcessingCode = false;
  bool _isNfcSessionActive = false;
  late AnimationController _nfcAnimationController;
  bool _isScreenVisible = true;
  DateTime? _lastScanTime;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNfcAvailability();

    _nfcAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Initialize scanner after a small delay to ensure widget is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScanner();
    });
  }

  Future<void> _initializeScanner() async {
    if (!mounted) return;

    try {
      // Check and request camera permission
      final PermissionStatus status = await Permission.camera.status;

      if (status.isDenied) {
        final PermissionStatus newStatus = await Permission.camera.request();
        if (newStatus.isDenied || newStatus.isPermanentlyDenied) {
          _showErrorSnackBar("Camera permission is required for QR scanning");
          return;
        }
      }

      // Dispose old controller if exists
      if (mobileScannerController != null) {
        mobileScannerController!.dispose();
      }

      // Initialize new controller
      mobileScannerController = MobileScannerController(
        facing: CameraFacing.back,
        torchEnabled: false,
        formats: const [BarcodeFormat.qrCode],
        returnImage: false,
        detectionSpeed: DetectionSpeed.normal,
      );

      // Start the scanner
      await mobileScannerController!.start();

      if (mounted) {
        setState(() {
          isCameraInitialized = true;
        });
      }

      debugPrint("✅ Mobile scanner initialized successfully");
    } catch (e) {
      debugPrint('❌ Error initializing scanner: $e');
      if (mounted) {
        _showErrorSnackBar("Failed to initialize camera: ${e.toString()}");
      }
    }
  }

  @override
  void onScreenVisible() {
    debugPrint("📱 Screen became visible");
    _isScreenVisible = true;

    if (isQRMode && !isCameraInitialized) {
      _initializeScanner();
    } else if (isQRMode && mobileScannerController != null) {
      mobileScannerController!.start();
    } else if (!isQRMode && _nfcAvailable) {
      _nfcAnimationController.repeat();
      _startNfcSession();
    }
  }

  @override
  void onScreenInvisible() {
    debugPrint("📱 Screen became invisible");
    _isScreenVisible = false;

    if (mobileScannerController != null && isCameraInitialized) {
      mobileScannerController!.stop();
    }

    if (_isNfcSessionActive) {
      _stopNfcSession();
    }

    _nfcAnimationController.stop();
  }

  Future<void> _checkNfcAvailability() async {
    try {
      _nfcAvailable = await NfcManager.instance.isAvailable();
      debugPrint("NFC Available: $_nfcAvailable");

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error checking NFC: $e");
      _nfcAvailable = false;
    }
  }

  Future<void> _startNfcSession() async {
    if (!_nfcAvailable) {
      _showErrorSnackBar("NFC is not available on this device");
      return;
    }

    if (_isNfcSessionActive) {
      debugPrint("⚠️ NFC session already active");
      return;
    }

    try {
      debugPrint("🔵 Starting NFC session...");

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          debugPrint("📡 NFC Tag discovered!");
          await _handleNfcTag(tag);
        },
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
      );

      _isNfcSessionActive = true;
      debugPrint("✅ NFC session started");
    } catch (e) {
      debugPrint("❌ Failed to start NFC: $e");
      _showErrorSnackBar("Failed to start NFC: ${e.toString()}");
    }
  }

  Future<void> _stopNfcSession() async {
    if (!_isNfcSessionActive) return;

    try {
      debugPrint("🔴 Stopping NFC session...");
      await NfcManager.instance.stopSession();
      _isNfcSessionActive = false;
      debugPrint("✅ NFC session stopped");
    } catch (e) {
      debugPrint("❌ Error stopping NFC session: $e");
    }
  }

  Future<void> _handleNfcTag(NfcTag tag) async {
    if (_isNfcProcessing) {
      debugPrint("⚠️ Already processing NFC tag");
      return;
    }

    _isNfcProcessing = true;

    try {
      HapticFeedback.mediumImpact();
      debugPrint("🔍 Processing NFC tag data...");

      final Map<String, String>? paymentData = await _extractPaymentDataFromNfc(tag);

      if (!mounted) return;

      if (paymentData != null && paymentData.isNotEmpty) {
        debugPrint("✅ Valid payment data found: $paymentData");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment detected! Amount: ${paymentData['amount'] ?? 'N/A'}"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Process payment here
        _processPaymentData(paymentData);
      } else {
        debugPrint("⚠️ No valid payment data found");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No payment information found on this NFC tag"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Error handling NFC tag: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error reading NFC: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // Reset processing flag after delay
      Future.delayed(const Duration(seconds: 2), () {
        _isNfcProcessing = false;
      });
    }
  }

  Future<Map<String, String>?> _extractPaymentDataFromNfc(NfcTag tag) async {
    try {
      debugPrint("🔍 Extracting NFC data...");

      // Properly cast tag.data to Map
      final Map<String, dynamic> tagDataMap = tag.data as Map<String, dynamic>;
      debugPrint("Tag data keys: ${tagDataMap.keys.toList()}");

      // Try NDEF first
      if (tagDataMap.containsKey('ndef')) {
        final dynamic ndefData = tagDataMap['ndef'];
        debugPrint("NDEF data available: $ndefData");

        if (ndefData is Map<String, dynamic>) {
          final dynamic cachedMessage = ndefData['cachedMessage'];

          if (cachedMessage != null && cachedMessage is Map<String, dynamic>) {
            final dynamic records = cachedMessage['records'];

            if (records != null && records is List && records.isNotEmpty) {
              debugPrint("Found ${records.length} NDEF records");

              for (var i = 0; i < records.length; i++) {
                final dynamic record = records[i];
                debugPrint("Processing record $i: $record");

                if (record is Map<String, dynamic>) {
                  final dynamic payload = record['payload'];

                  if (payload != null) {
                    String payloadString;

                    if (payload is List<int>) {
                      payloadString = String.fromCharCodes(payload);
                    } else if (payload is List) {
                      // Handle List<dynamic> case
                      payloadString = String.fromCharCodes(payload.cast<int>());
                    } else if (payload is String) {
                      payloadString = payload;
                    } else {
                      continue;
                    }

                    debugPrint("Payload string: $payloadString");

                    // Check for payment data
                    if (payloadString.contains('PAY:') ||
                        payloadString.contains('amount=') ||
                        payloadString.contains('PAYMENT')) {
                      return _parseNfcPayload(payloadString);
                    }
                  }
                }
              }
            }
          }
        }
      }

      // Try NfcA for card emulation
      if (tagDataMap.containsKey('nfca')) {
        debugPrint("NfcA data available");
        final dynamic nfcaData = tagDataMap['nfca'];

        if (nfcaData is Map<String, dynamic>) {
          // Handle card emulation format if needed
          final dynamic identifier = nfcaData['identifier'];
          if (identifier != null) {
            debugPrint("NfcA identifier: $identifier");
          }
        }
      }

      // Try NfcF (FeliCa)
      if (tagDataMap.containsKey('nfcf')) {
        debugPrint("NfcF data available");
      }

      // Try ISO 15693
      if (tagDataMap.containsKey('iso15693')) {
        debugPrint("ISO 15693 data available");
      }

      debugPrint("⚠️ No payment data found in tag");
      return null;
    } catch (e, stackTrace) {
      debugPrint("❌ Error extracting NFC data: $e");
      debugPrint("Stack trace: $stackTrace");
      return null;
    }
  }

  Map<String, String> _parseNfcPayload(String payload) {
    final Map<String, String> data = {};

    try {
      // Remove 'PAY:' prefix if exists
      String cleanPayload = payload;
      if (cleanPayload.startsWith('PAY:')) {
        cleanPayload = cleanPayload.substring(4);
      }

      // Parse key=value pairs
      final parts = cleanPayload.split('&');
      for (final part in parts) {
        final keyValue = part.split('=');
        if (keyValue.length == 2) {
          data[keyValue[0].trim()] = keyValue[1].trim();
        }
      }

      debugPrint("Parsed NFC data: $data");
    } catch (e) {
      debugPrint("Error parsing NFC payload: $e");
    }

    return data;
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            if (isQRMode) {
              _initializeScanner();
            } else {
              _startNfcSession();
            }
          },
        ),
      ),
    );
  }

  Future<void> toggleFlashlight() async {
    if (mobileScannerController == null || !isCameraInitialized) return;

    try {
      await mobileScannerController!.toggleTorch();
      setState(() {
        isFlashlightOn = !isFlashlightOn;
      });
      debugPrint("Flashlight: $isFlashlightOn");
    } catch (e) {
      debugPrint('Error toggling flashlight: $e');
    }
  }

  Future<void> toggleMode() async {
    setState(() {
      isQRMode = !isQRMode;
    });

    if (isQRMode) {
      // Switching to QR mode
      debugPrint("🔄 Switching to QR mode");

      _nfcAnimationController.stop();
      if (_isNfcSessionActive) {
        await _stopNfcSession();
      }

      if (!isCameraInitialized) {
        await _initializeScanner();
      } else if (mobileScannerController != null) {
        await mobileScannerController!.start();
      }
    } else {
      // Switching to NFC mode
      debugPrint("🔄 Switching to NFC mode");

      if (mobileScannerController != null && isCameraInitialized) {
        await mobileScannerController!.stop();
      }

      if (_nfcAvailable) {
        _nfcAnimationController.repeat();
        await _startNfcSession();
      } else {
        _showErrorSnackBar("NFC is not available on this device");
      }
    }
  }

  @override
  void dispose() {
    debugPrint("🗑️ Disposing ScanToPayHomeScreen");

    WidgetsBinding.instance.removeObserver(this);

    mobileScannerController?.dispose();
    mobileScannerController = null;

    if (_isNfcSessionActive) {
      NfcManager.instance.stopSession();
    }

    _nfcAnimationController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint("App lifecycle: $state");

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (mobileScannerController != null && isCameraInitialized && isQRMode) {
        mobileScannerController!.stop();
      }

      if (_isNfcSessionActive) {
        _stopNfcSession();
      }
    } else if (state == AppLifecycleState.resumed && _isScreenVisible) {
      if (isQRMode && mobileScannerController != null && isCameraInitialized) {
        mobileScannerController!.start();
      } else if (!isQRMode && _nfcAvailable) {
        _startNfcSession();
      }
    }
  }

  void _handleScannedCode(String code) {
    // Prevent duplicate scans
    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!) < const Duration(seconds: 3)) {
      debugPrint("⚠️ Duplicate scan ignored");
      return;
    }

    if (_isProcessingCode) {
      debugPrint("⚠️ Already processing a code");
      return;
    }

    _isProcessingCode = true;
    _lastScannedCode = code;
    _lastScanTime = now;

    try {
      HapticFeedback.mediumImpact();
      debugPrint("📷 Scanned QR Code: $code");

      if (_isValidPaymentQr(code)) {
        debugPrint("✅ Valid payment QR detected");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment QR detected!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        _processPaymentQr(code);
      } else {
        debugPrint("⚠️ Invalid payment QR");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid payment QR code"),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Error processing QR: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // Reset after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _isProcessingCode = false;
      });
    }
  }

  bool _isValidPaymentQr(String code) {
    // Check for common payment QR patterns
    return code.startsWith('PAY:') ||
        code.startsWith('PAYMENT:') ||
        (code.contains('amount=') && code.contains('recipient=')) ||
        code.contains('payment://');
  }

  void _processPaymentQr(String code) {
    final paymentData = _parseQrData(code);
    debugPrint("💰 Payment Data: $paymentData");

    _processPaymentData(paymentData);
  }

  void _processPaymentData(Map<String, String> paymentData) {
    // Navigate to payment confirmation screen
    // Example:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => PaymentConfirmationScreen(
    //       amount: paymentData['amount'] ?? '0',
    //       recipient: paymentData['recipient'] ?? 'Unknown',
    //     ),
    //   ),
    // );

    debugPrint("Would navigate to payment confirmation with: $paymentData");
  }

  Map<String, String> _parseQrData(String code) {
    final Map<String, String> data = {};

    try {
      // Remove prefix if exists
      String cleanCode = code;
      if (cleanCode.startsWith('PAY:') || cleanCode.startsWith('PAYMENT:')) {
        cleanCode = cleanCode.split(':').skip(1).join(':');
      }

      // Parse parameters
      final parts = cleanCode.split('&');
      for (final part in parts) {
        final keyValue = part.split('=');
        if (keyValue.length == 2) {
          data[keyValue[0].trim()] = keyValue[1].trim();
        }
      }
    } catch (e) {
      debugPrint("Error parsing QR data: $e");
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or NFC screen
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
              children: [
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
      children: [
        // Loading indicator
        if (!isCameraInitialized)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && mounted && !_isProcessingCode) {
                final code = barcodes.first.rawValue ?? '';
                if (code.isNotEmpty) {
                  _handleScannedCode(code);
                }
              }
            },
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Camera Error: ${error.errorCode.name}",
                        style: Font.montserratFont(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
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

        // QR Scan overlay
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
                children: [
                  Positioned(top: 0, left: 0, child: _buildCornerIndicator()),
                  Positioned(top: 0, right: 0, child: _buildCornerIndicator(isRight: true)),
                  Positioned(bottom: 0, left: 0, child: _buildCornerIndicator(isBottom: true)),
                  Positioned(bottom: 0, right: 0, child: _buildCornerIndicator(isRight: true, isBottom: true)),
                ],
              ),
            ),
          ),

        // Instructions
        if (isCameraInitialized)
          Positioned(
            bottom: 200.h,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              color: Colors.black.withOpacity(0.5),
              child: Column(
                children: [
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
          children: [
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
                children: [
                  // Wave animation
                  WaveWidget(
                    config: CustomConfig(
                      colors: [
                        MyTheme.secondaryColor,
                        MyTheme.primaryColor
                      ],
                      durations: [4000, 5000],
                      heightPercentages: [0.65, 0.66],
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
                      boxShadow: [
                        BoxShadow(
                          color: MyTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.contactless_rounded,
                      size: 40.sp,
                      color: MyTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Status indicator
            if (!_nfcAvailable)
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        "NFC is not available on this device",
                        style: Font.montserratFont(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                _isNfcSessionActive ? "Ready to Pay" : "Starting NFC...",
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
                children: [
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

            // Security note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
        debugPrint('Selected card: ${card.last4}');
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
            colors: [MyTheme.primaryColor, MyTheme.secondaryColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Stack(
          children: [
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
              children: [
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