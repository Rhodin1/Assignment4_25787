import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_or_register_page.dart';
import 'tab_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //User logged in
          if (snapshot.hasData) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (context) => ThemeProvider()),
                ChangeNotifierProvider(create: (context) => LocaleProvider()),
                ChangeNotifierProvider(
                    create: (context) =>
                        ConnectivityProvider()), // Add this provider
              ],
              child: MyApp(),
            );
          }
          //User not logged in
          else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
