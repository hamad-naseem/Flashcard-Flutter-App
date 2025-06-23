// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/home_screen.dart';
import 'screens/deck_details_screen.dart';
import 'screens/flashcard_quiz_screen.dart';
import 'screens/progress_screen.dart';
import 'src/authentication.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase before running the app
  await Firebase.initializeApp();
  
  // Configure Firebase UI Auth providers
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
  ]);
  
  // Now run the app
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const App()),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ApplicationState>(context, listen: false);
    
    return MaterialApp.router(
      title: 'Flashcards App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Base colors
        primaryColor: Color(0xFF6B1FB1),
        scaffoldBackgroundColor: Color(0xFF121212),
        
        // AppBar theme
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF6B1FB1),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Color(0xFFFFFF00),
          ),
        ),
        
        // Text themes
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF00FFFF),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF00FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Square corners
            ),
            side: BorderSide(
              color: Colors.white,
              width: 2,
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Input decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero, // Square corners
            borderSide: BorderSide(
              color: Color(0xFF00FF00),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero, // Square corners
            borderSide: BorderSide(
              color: Color(0xFF00FF00),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero, // Square corners
            borderSide: BorderSide(
              color: Color(0xFF00FFFF),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero, // Square corners
            borderSide: BorderSide(
              color: Color(0xFFFF0000),
              width: 2,
            ),
          ),
          labelStyle: TextStyle(
            color: Color(0xFF00FF00),
          ),
          hintStyle: TextStyle(
            color: Color(0xFF00FF00).withOpacity(0.5),
          ),
        ),
        
        // Card theme
        cardTheme: CardTheme(
          color: Color(0xFF1D1D1D),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Square corners
            side: BorderSide(
              color: Color(0xFF00FFFF),
              width: 2,
            ),
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        ),
        
        // Dialog theme
        dialogTheme: DialogTheme(
          backgroundColor: Color(0xFF1D1D1D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Square corners
            side: BorderSide(
              color: Color(0xFFFF00FF),
              width: 3,
            ),
          ),
          titleTextStyle: TextStyle(
            color: Color(0xFFFF00FF),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        
        // Snackbar theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF1D1D1D),
          contentTextStyle: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Square corners
            side: BorderSide(
              color: Color(0xFF00FF00),
              width: 2,
            ),
          ),
        ),
        
        // Icon theme
        iconTheme: IconThemeData(
          color: Color(0xFFFFFF00),
        ),
        
        // Divider theme
        dividerTheme: DividerThemeData(
          color: Color(0xFF00FF00),
          thickness: 2,
        ),
      ),
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return Consumer<ApplicationState>(
                builder: (context, appState, _) {
                  // Show loading indicator while initializing
                  if (!Firebase.apps.isNotEmpty) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  // Use the AuthPage for authentication
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Flashcards App'),
                    ),
                    body: Center(
                      child: AuthFunc(
                        loggedIn: appState.loggedIn,
                        signOut: () {
                          appState.logout();
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => HomeScreen(appState: Provider.of<ApplicationState>(context, listen: false)),
          ),
          GoRoute(
            path: '/sign-in',
            builder: (context, state) {
              return AuthScreenWrapper();
            },
            routes: [
              GoRoute(
                path: 'forgot-password',
                builder: (context, state) {
                  final email = state.uri.queryParameters['email'];
                  return Scaffold(
                    backgroundColor: Color(0xFF121212),
                    appBar: AppBar(
                      title: Text(
                        'RESET PASSWORD',
                        style: TextStyle(
                          color: Color(0xFF00FF00),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Color(0xFF6B1FB1),
                    ),
                    body: ForgotPasswordScreen(
                      email: email,
                      headerBuilder: (context, constraints, _) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1D1D1D),
                                  border: Border.all(
                                    color: Color(0xFF00FF00),
                                    width: 4,
                                  ),
                                ),
                                child: Icon(
                                  Icons.lock_reset,
                                  size: 80,
                                  color: Color(0xFF00FF00),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) {
              return Scaffold(
                backgroundColor: Color(0xFF121212),
                appBar: AppBar(
                  title: Text(
                    'PROFILE',
                    style: TextStyle(
                      color: Color(0xFF00FF00),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Color(0xFF6B1FB1),
                ),
                body: ProfileScreen(
                  providers: const [],
                  actions: [
                    SignedOutAction((context) {
                      context.go('/');
                    }),
                  ],
                ),
              );
            },
          ),
          GoRoute(
            path: '/deckDetails',
            builder: (context, state) {
              return DeckDetailsScreen(appState: Provider.of<ApplicationState>(context, listen: false));
            },
          ),
          GoRoute(
            path: '/flashcardQuiz',
            builder: (context, state) {
              return FlashcardQuizScreen(appState: Provider.of<ApplicationState>(context, listen: false));
            },
          ),
          GoRoute(
            path: '/progressStats',
            builder: (context, state) => ProgressStatsScreen(appState: Provider.of<ApplicationState>(context, listen: false)),
          ),
        ],
      ),
    );
  }
}

class CustomSignInScreen extends StatefulWidget {
  final Function(bool)? onAuthModeChanged;
  
  const CustomSignInScreen({Key? key, this.onAuthModeChanged}) : super(key: key);

  @override
  State<CustomSignInScreen> createState() => _CustomSignInScreenState();
}

class _CustomSignInScreenState extends State<CustomSignInScreen> {
  bool isSignIn = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isSignIn = !isSignIn;
      _errorMessage = null;
    });
  
    // Notify parent about auth mode change
    widget.onAuthModeChanged?.call(isSignIn);
  }

  Future<void> _submitForm() async {
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password';
      });
      return;
    }

    // Validate passwords match in sign-up mode
    if (!isSignIn && _passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    try {
      if (isSignIn) {
        // Sign in
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Sign up
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        // Update display name
        await userCredential.user!.updateDisplayName(_emailController.text.split('@')[0]);
        
        // Create user document in Firestore
        try {
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'email': _emailController.text.trim(),
            'displayName': _emailController.text.split('@')[0],
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Error creating user document: $e');
        }
      }
      
      // Navigate to home on success
      if (mounted) {
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  void _forgotPassword() {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }
    
    context.push('/sign-in/forgot-password?email=${_emailController.text.trim()}');
  }

  @override
  Widget build(BuildContext context) {
    // Update the app bar title based on auth mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Find the nearest Scaffold
      final ScaffoldState? scaffold = Scaffold.maybeOf(context);
      if (scaffold != null) {
        // We can't directly update the AppBar, so we'll use a workaround
        // by rebuilding the entire screen when the mode changes
      }
    });

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Icon(
                Icons.style,
                size: 100,
                color: Color(0xFF00FF00),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                isSignIn ? 'Welcome back to Flashcards App!' : 'Create an account to save your flashcards',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Email field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Color(0xFF00FF00)),
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Color(0xFF00FF00)),
              ),
              
              const SizedBox(height: 16),
              
              // Password field
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF00FF00)),
                ),
                obscureText: true,
                style: TextStyle(color: Color(0xFF00FF00)),
              ),
              
              // Confirm Password field (only in sign-up mode)
              if (!isSignIn) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF00FF00)),
                  ),
                  obscureText: true,
                  style: TextStyle(color: Color(0xFF00FF00)),
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Forgot password and Register row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isSignIn)
                    TextButton(
                      onPressed: _forgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFFFF00FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  TextButton(
                    onPressed: _toggleAuthMode,
                    child: Text(
                      isSignIn ? 'Don\'t have an account? Register' : 'Already have an account? Sign in',
                      style: TextStyle(
                        color: Color(0xFFFF00FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Error message
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF1D1D1D),
                    border: Border.all(color: Color(0xFFFF0000), width: 2),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Color(0xFFFF0000)),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Submit button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF00FF),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isSignIn ? 'SIGN IN' : 'REGISTER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthScreenWrapper extends StatefulWidget {
  const AuthScreenWrapper({Key? key}) : super(key: key);

  @override
  State<AuthScreenWrapper> createState() => _AuthScreenWrapperState();
}

class _AuthScreenWrapperState extends State<AuthScreenWrapper> {
  bool isSignIn = true;

  void updateAuthMode(bool signInMode) {
    if (isSignIn != signInMode) {
      setState(() {
        isSignIn = signInMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          isSignIn ? 'SIGN IN' : 'SIGN UP',
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF6B1FB1),
      ),
      body: CustomSignInScreen(
        onAuthModeChanged: updateAuthMode,
      ),
    );
  }
}
