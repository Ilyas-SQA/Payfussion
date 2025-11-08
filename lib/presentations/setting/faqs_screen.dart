import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:payfussion/core/circular_indicator.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/fonts.dart';
import '../widgets/background_theme.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _backgroundAnimationController;


  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _contentController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FAQs",
          style: Font.montserratFont(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          AnimatedBackground(
            animationController: _backgroundAnimationController,
          ),
          Column(
            children: <Widget>[

              SizedBox(height: 10.h),

              // Animated content
              Expanded(
                child: FadeTransition(
                  opacity: _contentController,
                  child: FutureBuilder(
                    future: FirebaseFirestore.instance.collection("faqs").get(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasData) {
                        return AnimationLimiter(
                          child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 200),
                                child: SlideAnimation(
                                  verticalOffset: 20.0,
                                  child: FadeInAnimation(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(5.r),
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                                              blurRadius: 5,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ExpansionTile(
                                          backgroundColor: Theme.of(context).cardColor,
                                          collapsedBackgroundColor: Theme.of(context).cardColor,
                                          collapsedIconColor: MyTheme.primaryColor,
                                          iconColor: MyTheme.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          title: Text(
                                            snapshot.data!.docs[index]["question"],
                                            style: Font.montserratFont(
                                              fontSize: 16,
                                            ),
                                          ),
                                          children: <Widget>[
                                            ListTile(
                                              title: Text(
                                                snapshot.data!.docs[index]["answer"],
                                                style: Font.montserratFont(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return CircularIndicator.circular;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
