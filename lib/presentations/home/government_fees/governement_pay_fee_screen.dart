import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/core/widget/appbutton/app_button.dart';
import 'package:payfussion/presentations/widgets/auth_widgets/credential_text_field.dart';

class GovernmentPayFeeScreen extends StatefulWidget {
  const GovernmentPayFeeScreen({super.key});

  @override
  State<GovernmentPayFeeScreen> createState() => _GovernmentPayFeeScreenState();
}

class _GovernmentPayFeeScreenState extends State<GovernmentPayFeeScreen>
    with TickerProviderStateMixin {

  final TextEditingController _textIdController = TextEditingController();
  final FocusNode _textIdFocusNode = FocusNode();

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _contentController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _contentFade;

  List<GovernmentServiceSuggestion> filteredSuggestions = [];
  bool showSuggestions = false;

  // Government services data for suggestions
  final List<GovernmentServiceSuggestion> governmentServices = [
    // Federal Services
    GovernmentServiceSuggestion(
        id: "irs",
        name: "IRS Tax Payment",
        keywords: ["irs", "tax", "income", "federal", "revenue"],
        icon: Icons.account_balance,
        category: "Federal"
    ),
    GovernmentServiceSuggestion(
        id: "ssa",
        name: "Social Security",
        keywords: ["ssa", "social", "security", "benefits"],
        icon: Icons.security,
        category: "Federal"
    ),
    GovernmentServiceSuggestion(
        id: "medicare",
        name: "Medicare Services",
        keywords: ["medicare", "health", "medical", "premium"],
        icon: Icons.local_hospital,
        category: "Federal"
    ),
    GovernmentServiceSuggestion(
        id: "tsa",
        name: "TSA PreCheck",
        keywords: ["tsa", "precheck", "airport", "security", "flight"],
        icon: Icons.flight_takeoff,
        category: "Federal"
    ),
    GovernmentServiceSuggestion(
        id: "passport",
        name: "Passport Services",
        keywords: ["passport", "state", "department", "travel"],
        icon: Icons.library_books,
        category: "Federal"
    ),

    // State Services
    GovernmentServiceSuggestion(
        id: "dmv",
        name: "DMV Services",
        keywords: ["dmv", "license", "driving", "vehicle", "registration"],
        icon: Icons.directions_car,
        category: "State"
    ),
    GovernmentServiceSuggestion(
        id: "state_tax",
        name: "State Tax Board",
        keywords: ["state", "tax", "income", "board"],
        icon: Icons.account_balance_wallet,
        category: "State"
    ),
    GovernmentServiceSuggestion(
        id: "employment",
        name: "Employment Department",
        keywords: ["employment", "unemployment", "job", "work"],
        icon: Icons.work,
        category: "State"
    ),

    // Local Services
    GovernmentServiceSuggestion(
        id: "police",
        name: "Police Department",
        keywords: ["police", "fine", "citation", "permit"],
        icon: Icons.local_police,
        category: "Local"
    ),
    GovernmentServiceSuggestion(
        id: "traffic",
        name: "Traffic Citations",
        keywords: ["traffic", "parking", "citation", "fine", "ticket"],
        icon: Icons.traffic,
        category: "Local"
    ),
    GovernmentServiceSuggestion(
        id: "property_tax",
        name: "Property Tax",
        keywords: ["property", "tax", "real", "estate", "home"],
        icon: Icons.home,
        category: "Local"
    ),
    GovernmentServiceSuggestion(
        id: "water",
        name: "Water Department",
        keywords: ["water", "sewer", "utility", "bill"],
        icon: Icons.water_drop,
        category: "Local"
    ),

    // Court Services
    GovernmentServiceSuggestion(
        id: "court",
        name: "Court Services",
        keywords: ["court", "filing", "legal", "case"],
        icon: Icons.gavel,
        category: "Judicial"
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
    _textIdController.addListener(_onTextChanged);
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _contentController.forward();
  }

  void _onTextChanged() {
    final query = _textIdController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        showSuggestions = false;
        filteredSuggestions = [];
      });
      return;
    }

    // Filter suggestions based on text input
    final suggestions = governmentServices.where((service) {
      return service.keywords.any((keyword) =>
          keyword.toLowerCase().contains(query)) ||
          service.name.toLowerCase().contains(query);
    }).toList();

    setState(() {
      filteredSuggestions = suggestions;
      showSuggestions = suggestions.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _textIdController.dispose();
    _textIdFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(
            position: _headerSlide,
            child: const Text(
              "Government Pay Fee",
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _contentFade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_contentController),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter Service ID",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Enter your government service ID or search by service name",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor != Colors.white
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xff718096),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              // Text Input Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppTextormField(
                  controller: _textIdController,
                  prefixIcon: Icon(Icons.search),
                  isPasswordField: false,
                  helpText: "Enter Text ID or service name...",
                ),
              ),

              SizedBox(height: 10.h),

              // Suggestions List
              if (showSuggestions) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    "Suggestions",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor != Colors.white
                          ? Colors.white
                          : const Color(0xff2D3748),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Suggestions or Continue Button
              Expanded(
                child: showSuggestions ? _buildSuggestionsList(theme) : _buildContinueSection(theme),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30,horizontal: 20),
                child: AppButton(
                  text: "Continue",
                  onTap: _textIdController.text.trim().isEmpty ? null : () => _showComingSoonDialog(context),
                  color: theme.primaryColor != Colors.white ? Colors.white.withOpacity(0.2) : const Color(0xffE2E8F0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: AnimationLimiter(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: filteredSuggestions.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildSuggestionItem(
                    filteredSuggestions[index],
                    theme,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(GovernmentServiceSuggestion suggestion, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _textIdController.text = suggestion.name;
            setState(() {
              showSuggestions = false;
            });
            _textIdFocusNode.unfocus();
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  height: 45.h,
                  width: 45.w,
                  decoration: BoxDecoration(
                    color: MyTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    suggestion.icon,
                    size: 24.sp,
                    color: MyTheme.primaryColor,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor != Colors.white
                              ? Colors.white
                              : const Color(0xff2D3748),
                        ),
                      ),
                      Text(
                        suggestion.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor != Colors.white
                              ? Colors.white.withOpacity(0.6)
                              : const Color(0xff718096),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: theme.primaryColor != Colors.white
                      ? Colors.white.withOpacity(0.4)
                      : const Color(0xffA0AEC0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueSection(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance,
            size: 50.sp,
            color: theme.primaryColor != Colors.white
                ? Colors.white.withOpacity(0.3)
                : const Color(0xffE2E8F0),
          ),
          SizedBox(height: 24.h),
          Text(
            "Government Services",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primaryColor != Colors.white ? Colors.white : const Color(0xff2D3748),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Enter your service ID or search for government services above",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.primaryColor != Colors.white
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xff718096),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.construction,
              color: MyTheme.primaryColor,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              "Coming Soon",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: MyTheme.primaryColor,
              ),
            ),
          ],
        ),
        content: Text(
          "This feature is currently under development. We're working hard to bring you the best government payment experience!",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xff718096),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: MyTheme.primaryColor,
            ),
            child: Text(
              "Got it",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GovernmentServiceSuggestion {
  final String id;
  final String name;
  final List<String> keywords;
  final IconData icon;
  final String category;

  GovernmentServiceSuggestion({
    required this.id,
    required this.name,
    required this.keywords,
    required this.icon,
    required this.category,
  });
}