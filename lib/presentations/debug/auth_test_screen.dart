import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/utils/auth_debug_utils.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _status = 'Ready';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testFirebaseAuth();
  }

  Future<void> _testFirebaseAuth() async {
    final isWorking = await AuthDebugUtils.testFirebaseAuth();
    setState(() {
      _status = isWorking
          ? 'Firebase Auth initialized'
          : 'Firebase Auth failed';
    });
  }

  Future<void> _testSignIn() async {
    setState(() {
      _isLoading = true;
      _status = 'Signing in...';
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Please enter email and password');
      }

      AuthDebugUtils.logAuthAttempt(email);

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      AuthDebugUtils.logAuthSuccess(userCredential.user);

      setState(() {
        _status = 'Sign in successful: ${userCredential.user?.email}';
      });
    } catch (e) {
      AuthDebugUtils.logAuthError(e);
      setState(() {
        _status = 'Sign in failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestUser() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating test user...';
    });

    try {
      await AuthDebugUtils.createTestUser();
      setState(() {
        _status = 'Test user created successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Test user creation failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      setState(() {
        _status = 'Signed out successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Sign out failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _testSignIn,
                    child: const Text('Test Sign In'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _createTestUser,
                    child: const Text('Create Test User'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Sign Out'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testFirebaseAuth,
                    child: const Text('Test Firebase Auth'),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current User:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text('UID: ${user.uid}'),
                          Text('Email: ${user.email}'),
                          Text('Verified: ${user.emailVerified}'),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No user signed in'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
