// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class SessionManager extends StatefulWidget {
//   final Widget child;
//   const SessionManager({super.key, required this.child});
//
//   @override
//   State<SessionManager> createState() => _SessionManagerState();
// }
//
// class _SessionManagerState extends State<SessionManager> {
//   Timer? _inactivityTimer;
//
//   void _resetTimer() {
//     _inactivityTimer?.cancel();
//     _inactivityTimer = Timer(const Duration(minutes: 5), _logout);
//   }
//
//   void _logout() {
//     FirebaseAuth.instance.signOut();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _resetTimer();
//   }
//
//   @override
//   void dispose() {
//     _inactivityTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _resetTimer,
//       onPanDown: (_) => _resetTimer(),
//       child: widget.child,
//     );
//   }
// }
