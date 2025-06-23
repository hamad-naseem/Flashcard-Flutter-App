// Copyright 2022 The Flutter Authors. All rights reserved.
// Use this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets.dart';

class AuthFunc extends StatelessWidget {
  const AuthFunc({super.key, required this.loggedIn, required this.signOut});

  final bool loggedIn;
  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'Welcome to Flashcards',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Sign in or logout button
            SizedBox(
              width: double.infinity,
              child: StyledButton(
                onPressed: () {
                  !loggedIn ? context.push('/sign-in') : signOut();
                },
                child: !loggedIn 
                    ? const Text('Sign In / Sign Up') 
                    : const Text('Logout'),
              ),
            ),
            
            // Profile button (only visible when logged in)
            if (loggedIn) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: StyledButton(
                  onPressed: () {
                    context.push('/profile');
                  },
                  child: const Text('Profile'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: StyledButton(
                  onPressed: () {
                    context.push('/home');
                  },
                  child: const Text('Go to Flashcards'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
